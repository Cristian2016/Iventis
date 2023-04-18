//
//  Coordinator.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 10.02.2023.
//⚠️ task { bThread }, update { mainThread }. task method runs on bThread and update method on UI Thread. be careful when accessing bubble.properties since bubble is MSManagedObject and these objects are not thread safe!!! use bubble.objID property to "grab" bubble and use is on a bThread. theBubble is the bThread version of bubble. bubble is tied to viewContext. theBubble is tied to bContext
//1 publishers emit their initial value, without .send()! ⚠️
//2 delta is the elapsed duration between last pair.start and signal date
//3 create means initialization. 1.user creates a bubble or 2.bubble created already but app relaunches
//4 repetitive task() called each second on bThread. every second publisher sends out bTimer signal and this is the task to run. bubble.currentClock + ∆. maybe in the future I decide to call this task every 0.5 seconds.. maybe :)
//5 lets continuous update do one pass to refresh all time components. for ex: when user starts bubble, there is no need for a refresh
//6 evaluate before creating a new session, otherwise the value will be alwatys false
//7 read currentClock on the mainThread. do not access bubble on a backgroundThread!
//8 the tiny label that a timer has above seconds
//9 ⚠️ I made a copy because I'm not sure it's safe to read bubble.properties from a background thread, since initialValue is reading bubble.properties
//10 observeActivePhase updates bubbleCell.timeComponnets on self.init. not calling observeActivePhase, components [hr, min, sec, hundredths] would show -1 -1 -1 -1
//11 notification received on mainQueue
//12 refreshOnAppActive() no idea why didBecomeActive notification received twice when I pull dow notification center. This method ensures that all components will be updated when app returns from the background
//13 elapsed beyond zero. timers only

import SwiftUI
import Combine
import MyPackage

extension BubbleCellCoordinator {
    typealias Publisher = CurrentValueSubject
}

class BubbleCellCoordinator {
    weak private(set) var bubble:Bubble?
    private let isTimer:Bool
    
    private var precisionTimer = PrecisionTimer()
    
    // MARK: - Public API
    func update(_ moment:Moment, refresh:Bool = false) { //main Thread ⚠️
        guard let bubble = bubble else { return }
        
        let bContext = PersistenceController.shared.bContext
        let objID = bubble.objectID
        
        bContext.perform {
            let theBubble = PersistenceController.shared.grabObj(objID) as! Bubble
            let theInitialValue = self.initialValue(theBubble)
            
            switch moment {
                    
                case .finishTimer:
                    self.cancellable = []
                    DispatchQueue.main.async {
                        self.timeComponents = Components("0", "0", "0", "✕")
                        self.timerProgress = "Done"
                    }
                    
                case .showAll:
                    if theBubble.state == .running && !theBubble.isPinned { self.refresh = true }
                    
                case .automatic:
                    let comp = theInitialValue.timeComponentsAsStrings
                    let progress = self.computeTimerProgress(for: theBubble, and: theInitialValue)
                    
                    DispatchQueue.main.async {
                        self.timeComponents = Components(comp.hr, comp.min, comp.sec, comp.hundredths)
                        self.timeComponentsOpacity.updateOpacity(theInitialValue)
                        
                        switch bubble.state {
                            case .finished:
                                self.timerProgress = "Done"
                            case .brandNew:
                                self.timerProgress = "OK"
                            default:
                                self.timerProgress = String(format: "%.2f", progress)
                        }
                        
//                        if bubble.state == .finished {
//                            self.timerProgress = "Done"
//                        } else {
//                            self.timerProgress = String(format: "%.2f", progress)
//                        }
                    }
                    
                    if theBubble.state == .running {
                        DispatchQueue.main.async { self.timeComponents.hundredths = "" }
                        self.refresh = true
                        self.publisher
                            .sink { [weak self] _ in self?.task(theBubble) }
                            .store(in: &self.cancellable) //connect
                    }
                    
                case .user(let action):
                    switch action {
                        case .pause:
                            self.cancellable = []
                            
                            let components = theInitialValue.timeComponentsAsStrings
                            let hr = components.hr
                            let min = components.min
                            let sec = components.sec
                            let hundredths = components.hundredths
                            
                            DispatchQueue.main.async {
                                self.timeComponents = Components(hr, min, sec, hundredths)
                            }
                            
                        case .start:
                            self.refresh = true
                            
                            self.publisher
                                .sink { [weak self] _ in self?.task(theBubble) }
                                .store(in: &self.cancellable) //connect
                            
                            DispatchQueue.main.async { self.timeComponents.hundredths = "" }
                                                        
                        case .endSession, .reset, .deleteCurrentSession:
                            self.cancellable = []
                            let stringComponents = theBubble.initialClock.timeComponentsAsStrings
                            
                            DispatchQueue.main.async {
                                self.timerProgress = "OK"
                                
                                self.timeComponents.hr = stringComponents.hr
                                self.timeComponents.min = stringComponents.min
                                self.timeComponents.sec = stringComponents.sec
                                self.timeComponents.hundredths = stringComponents.hundredths
                                
                                self.timeComponentsOpacity.updateOpacity(bubble.isTimer ? bubble.initialClock : 0)
                            }
                            
                        case .deleteBubble:
                            self.cancellable = []
                            NotificationCenter.default.removeObserver(self)
                    }
            }
        }
    }
    
    @Published var sdbOffset = CGFloat(0) //start delay button YOffset
    @Published var sdbDeleteTriggered = false //start delay button delete triggered
    
    @Published var timerProgress = "0.00" //8
    @Published var timeComponents = Components("-1", "-1", "-1", "-1")
    var timeComponentsSet:Bool { timeComponents.hr != "-1" }
    @Published private(set) var timeComponentsOpacity = Opacity()
    var colorPublisher:Publisher<Color, Never>
    
    private func computeTimerProgress(for bubble:Bubble, and value:Float) -> Double {
        1 - Double(value/(bubble.initialClock))
    }
      
    // MARK: - Private API
    private var refresh = false //5
    
    private func task(_ bubble:Bubble) { //bThread ⚠️
        guard let lastStart = bubble.lastPair?.start else { return }
        
        let refresh = self.refresh
        let currentClock = bubble.currentClock
                                
        let elapsedSinceLastStart = Float(Date().timeIntervalSince(lastStart)) //2
        
        var value = isTimer ? currentClock - elapsedSinceLastStart : currentClock + elapsedSinceLastStart //ex: 2345.87648
        
        value.round(.toNearestOrEven) //ex: 2346
        
        if isTimer {
            //compute progress
            let progress = self.computeTimerProgress(for: bubble, and: value)
            DispatchQueue.main.async {
                self.timerProgress = String(format: "%.2f", progress)
            }
            
            //check if timer should finish
            let totalDuration = bubble.lastSession!.totalDuration
            let elapsedSinceFirstStart = totalDuration + elapsedSinceLastStart
            let overspill = bubble.initialClock - elapsedSinceFirstStart //
            
            if (Float(0)...1).contains(overspill) {
                let deadline:DispatchTime = .now() + .milliseconds(Int(overspill * 1000))
                
                precisionTimer.executeAction(after: deadline) { [weak self] in
                    self?.finishBubble() //at exactly 0.0 overspill
                    DispatchQueue.main.async { self?.timerProgress = "Done" }
                    self?.update(.finishTimer)
                }
            } else {
                if overspill < 0 {
                    self.finishBubble(overspill)
                    DispatchQueue.main.async { self.timerProgress = "Done" }
                    self.update(.finishTimer)
                }
            }
        }
        
        let intValue = Int(value)
        let secValue = intValue%60
        
        let refreshForTimer = isTimer && secValue == 59
        
        if secValue == 0 || refresh || refreshForTimer { //send minute and hour
            let giveMeAName = intValue/60%60
            let minValue = String(giveMeAName)
            
            DispatchQueue.main.async { //send min
                self.timeComponents.min = minValue
                if intValue == 60 || refresh { self.timeComponentsOpacity.updateOpacity(value) }
            }
            
            if (giveMeAName%60) == 0 || refresh || refreshForTimer {
                let hrValue = String(intValue/3600)
                
                DispatchQueue.main.async { //send hour
                    self.timeComponents.hr = hrValue
                    if intValue == 3600 || refresh || refreshForTimer { self.timeComponentsOpacity.updateOpacity(value) }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.timeComponents.sec = String(secValue) //send second
            self.refresh = false
        }
    } //4
    
    // MARK: - Publishers 1
    private lazy var publisher =
    NotificationCenter.Publisher(center: .default, name: .bubbleTimerSignal)
    
    private var cancellable = Set<AnyCancellable>()
            
    ///do not use bubble from viewContext! read bubble from bContext
    private func initialValue(_ bBubble:Bubble) -> Float {
        let currentClock = bBubble.currentClock
        
        if bBubble.state == .running {
            let Δ = Date().timeIntervalSince(bBubble.lastPair!.start!)
            let initialValue = isTimer ?  currentClock - Float(Δ) : currentClock + Float(Δ)
            return initialValue
        }
        else { return currentClock }
    }
    
    private var activePhaseCalled = false
    
    ///set refresh to true
    private func observeAppActive() {
        NotificationCenter.default.addObserver(forName: .didBecomeActive, object: nil, queue: nil) { [weak self] _ in
            if self?.refresh == false { self?.refresh = true }
            print(#function, " \(self?.bubble?.color ?? "pula")")
        }
    } //12
    
    ///notifies ViewModel to finish bubble
    private func finishBubble(_ overspill:Float? = nil) {
        guard let bubble = bubble else { return }
        
        let info:[String : Any] = ["rank" : bubble.rank, "overspill" : overspill ?? 0.0]
        
        NotificationCenter.default.post(name: .killTimer, object: nil, userInfo: info)
    }
        
    // MARK: - Init Deinit
    init(for bubble:Bubble) {
        self.bubble = bubble
        self.colorPublisher = .init(Color.bubbleColor(forName: bubble.color))
        self.isTimer = bubble.kind != .stopwatch
        
        print(#function, " \(bubble.color ?? "pula")")
        
        //refresh components when app active again
        observeAppActive()
    }
    
    deinit {
        cancellable = []
        NotificationCenter.default.removeObserver(self)
    }
}

extension BubbleCellCoordinator {
    ///automatic means handled by the system. ex. when app launches
    enum Moment {
        case user(Action)
        case automatic
        case showAll //show all bubbles, including the ordinary ones
        case finishTimer
    }
    
    enum Action {
        case start
        case pause
        case reset
        case endSession
        case deleteCurrentSession
        case deleteBubble
    }
    
    struct Components {
        var hr:String
        var min:String
        var sec:String
        var hundredths:String
        
        init(_ hr:String, _ min:String, _ sec:String, _ hundredths:String) {
            self.hr = hr
            self.min = min
            self.sec = sec
            self.hundredths = hundredths
        }
    }
    
    struct Opacity {
        var hr = CGFloat(0)
        var min = CGFloat(0)
        
        mutating func updateOpacity(_ value:Float) {
            min = value > 59 ? 1 : 0.001
            hr = value > 3599 ?  1 : 0.001
        }
    }
}
