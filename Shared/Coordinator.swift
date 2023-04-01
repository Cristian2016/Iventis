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

import SwiftUI
import Combine
import MyPackage

extension BubbleCellCoordinator {
    typealias Publisher = CurrentValueSubject
}

class BubbleCellCoordinator {
    weak private(set) var bubble:Bubble?
    private let isTimer:Bool
    
    // MARK: - Public API
    func update(_ moment:Moment, refresh:Bool = false) { //main Thread ⚠️
        guard let bubble = bubble else { return }
        
        let bContext = PersistenceController.shared.bContext
        let objID = bubble.objectID
        
        bContext.perform {
            let theBubble = PersistenceController.shared.grabObj(objID) as! Bubble
            let theInitialValue = self.initialValue(theBubble)
            
            switch moment {
                case .create: //bubble is created [ViewModel.createBubble]
                    if self.timeComponents.hr == "-1" {
                        let comp = theInitialValue.timeComponentsAsStrings
                        DispatchQueue.main.async {
                            self.timeComponents = Components(comp.hr, comp.min, comp.sec, comp.hundredths)
                            self.timeComponentsOpacity.updateOpacity(theInitialValue)
                        }
                    }
                    
                case .showAll:
                    if theBubble.state == .running && !theBubble.isPinned { self.refresh = true }
                    
                case .automatic:
                    DispatchQueue.main.async { self.timeComponents.hundredths = "" }
                    self.refresh = true
                    self.publisher
                        .sink { [weak self] _ in self?.task(theBubble.currentClock, theBubble.lastPair?.start) }
                        .store(in: &self.cancellable) //connect
                    
                case .user(let action):
                    switch action {
                        case .pause:
                            self.cancellable = []
                            let components = theInitialValue.timeComponentsAsStrings
                            
                            DispatchQueue.main.async {
                                self.timeComponents = Components(components.hr,
                                                             components.min,
                                                             components.sec,
                                                             components.hundredths)
                            }
                            
                        case .start:
                            self.refresh = true
                            
                            let cuurentClock = theBubble.currentClock
                            let lastPairStart = theBubble.lastPair!.start!
                            
                            self.publisher
                                .sink { [weak self] _ in self?.task(cuurentClock, lastPairStart) }
                                .store(in: &self.cancellable) //connect
                            DispatchQueue.main.async { self.timeComponents.hundredths = "" }
                            
                        case .endSession, .reset, .deleteCurrentSession:
                            self.cancellable = []
                            let stringComponents = theBubble.initialClock.timeComponentsAsStrings
                            
                            DispatchQueue.main.async {
                                self.timerProgress = 0.0
                                
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
    
    @Published var timerProgress = 0.0 //8
    @Published var timeComponents = Components("-1", "-1", "-1", "-1")
    @Published private(set) var timeComponentsOpacity = Opacity()
    var colorChangePublisher:Publisher<Color, Never>
      
    // MARK: - Private API
    private var refresh = false //5
    
    private func task(_ currentClock:Float, _ lastStart:Date?) { //bThread ⚠️
        guard let lastPairStart = lastStart else { return }
        let refresh = self.refresh
                                
        let Δ = Float(Date().timeIntervalSince(lastPairStart)) //2
        
        var value = isTimer ? currentClock - Δ : currentClock + Δ //ex: 2345.87648
        
        value.round(.toNearestOrEven) //ex: 2346
        
        if isTimer {
            DispatchQueue.main.async { [weak self] in
                self?.timerProgress = 1 - Double(value/(self?.bubble?.initialClock ?? 1))
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
    
    // MARK: - Observers
    private func observeActivePhase() {
        let center = NotificationCenter.default
        center.addObserver(forName: .didBecomeActive, object: nil, queue: nil) {
            [weak self] _ in //mainQueue 🟢
            guard let bubble = self?.bubble else { return }
            
            self?.activePhaseCalled = true
            
            print(#function)
            
            let bContext = PersistenceController.shared.bContext
            let objID = bubble.objectID
            
            bContext.perform {//bQueue 🔴
                let theBubble = PersistenceController.shared.grabObj(objID) as! Bubble
                
                guard let initialValue = self?.initialValue(theBubble) else { return }
                let comp = initialValue.timeComponentsAsStrings //components
                
                if theBubble.state == .running { self?.update(.automatic) }
                DispatchQueue.main.async {//mainQueue 🟢
                    self?.timeComponents = Components(comp.hr, comp.min, comp.sec, comp.hundredths)
                    self?.timeComponentsOpacity.updateOpacity(initialValue)
                }
            }
        }
    } //11
    
    private var activePhaseCalled = false
    
    func makeSureBubbleCellUpdates() {
        guard
            activePhaseCalled == false,
            let bubble = bubble else { return }
        
        activePhaseCalled = true
        
        print(#function)
        
        let bContext = PersistenceController.shared.bContext
        let objID = bubble.objectID
        
        bContext.perform {
            let theBubble = PersistenceController.shared.grabObj(objID) as! Bubble
            if theBubble.state == .running { self.update(.automatic) }
        }
    }
    
    // MARK: - Init Deinit
    init(for bubble:Bubble) {
        self.bubble = bubble
        self.colorChangePublisher = .init(Color.bubbleColor(forName: bubble.color))
        self.isTimer = bubble.kind != .stopwatch
        
        self.observeActivePhase() //10
        self.update(.create)
    }
    
    deinit {
        cancellable = []
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Testing
    private func update(_ moment:Moment) {
        guard let bubble = bubble else { return }
        print(#function, " create")
        
        let bContext = PersistenceController.shared.bContext
        let objID = bubble.objectID
        
        bContext.perform {
            let bBubble = PersistenceController.shared.grabObj(objID) as! Bubble
            let bInitialValue = self.initialValue(bBubble)
            let components = bInitialValue.timeComponentsAsStrings
            
            DispatchQueue.main.async {
                self.timeComponents
                = Components(components.hr, components.min, components.sec, components.hundredths)
                self.timeComponentsOpacity.updateOpacity(bInitialValue)
            }
        }
        
        switch moment {
            case .create: break
            default: break
        }
    }
}

extension BubbleCellCoordinator {
    ///automatic means handled by the system. ex. when app launches
    enum Moment {
        case create
        case user(Action)
        case automatic
        case showAll //show all bubbles, including the ordinary ones
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
