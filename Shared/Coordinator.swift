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
//8 the tiny label that a timer has on seconds
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
        
        //⚠️ do not access bubble on bThread. extract properties here!!!
        let isPinned = bubble.isPinned
        let state = bubble.state
        let initialClock = bubble.initialClock
        let currentClock = bubble.currentClock
        let lastPairStart = bubble.lastPair?.start
        
        DispatchQueue.global().async {
            switch moment {
                case .create: //bubble is created [ViewModel.createBubble]
                    print(#function, " create")
                    if self.components.hr == "-1" {
                        self.bInitialValue { [weak self] in
                            let comp = $0.timeComponentsAsStrings
                            self?.components = Components(comp.hr, comp.min, comp.sec, comp.hundredths)
                            self?.opacity.updateOpacity($0)
                        }
                    }
                    
                case .showAll:
                    if state == .running && !isPinned { self.refresh = true }
                    print(#function, " show all")
                    
                case .automatic:
                    DispatchQueue.main.async { self.components.hundredths = "" }
                    self.refresh = true
                    self.publisher
                        .sink { [weak self] _ in self?.task(currentClock, lastPairStart) }
                        .store(in: &self.cancellable) //connect
                    print(#function, " automatic")
                    
                case .user(let action):
                    switch action {
                        case .pause:
                            self.cancellable = []
                            
                            self.bInitialValue {
                                let components = $0.timeComponentsAsStrings
                                
                                DispatchQueue.main.async {
                                    self.components = Components(components.hr,
                                                                 components.min,
                                                                 components.sec,
                                                                 components.hundredths)
                                }
                                print(#function, " automatic")
                            }
                            
                        case .start:
                            self.refresh = true
                            self.publisher
                                .sink { [weak self] _ in self?.task(currentClock, lastPairStart) }
                                .store(in: &self.cancellable) //connect
                            DispatchQueue.main.async { self.components.hundredths = "" }
                            print(#function, " start")
                            
                        case .endSession, .reset, .deleteCurrentSession:
                            self.cancellable = []
                            let stringComponents = initialClock.timeComponentsAsStrings
                            
                            DispatchQueue.main.async {
                                self.timerProgress = 0.0
                                self.components.hr = stringComponents.hr
                                self.components.min = stringComponents.min
                                self.components.sec = stringComponents.sec
                                self.components.hundredths = stringComponents.hundredths
                                
                                if bubble.kind == .stopwatch {
                                    self.opacity.updateOpacity(0)
                                } else {
                                    self.opacity.updateOpacity(bubble.initialClock)
                                }
                            }
                            
                        case .deleteBubble:
                            self.cancellable = []
                            NotificationCenter.default.removeObserver(self)
                    }
            }
        }
    }
    
    @Published var sdButtonYOffset = CGFloat(0)
    @Published var sdbDeleteTriggered = false
    @Published var timerProgress = 0.0 //8
        
    @Published  var components = Components("-1", "-1", "-1", "-1")
    @Published private(set) var opacity = Opacity()
    var colorPublisher:Publisher<Color, Never>
    
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
                self.components.min = minValue
                if intValue == 60 || refresh { self.opacity.updateOpacity(value) }
            }
            
            if (giveMeAName%60) == 0 || refresh || refreshForTimer {
                let hrValue = String(intValue/3600)
                
                DispatchQueue.main.async { //send hour
                    self.components.hr = hrValue
                    if intValue == 3600 || refresh || refreshForTimer { self.opacity.updateOpacity(value) }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.components.sec = String(secValue) //send second
            self.refresh = false
        }
    } //4
    
    // MARK: - Publishers 1
    private lazy var publisher =
    NotificationCenter.Publisher(center: .default, name: .bubbleTimerSignal)
    
    private var cancellable = Set<AnyCancellable>()
        
    private func bInitialValue(completion: @escaping (Float) -> Void) {
        guard let bubble = bubble else { fatalError() }
        
        //extract properties to use inside bQueue. do not use bubble within bQueue!
        let isRunning = bubble.state == .running
        let lastPairStart = bubble.lastPair?.start
        let currentClock = bubble.currentClock
        let isTimer = bubble.isTimer
        
        //use extracted properties here
        DispatchQueue.global().async {
            if isRunning {
                let Δ = Date().timeIntervalSince(lastPairStart!)
                let initialValue = isTimer ?  currentClock - Float(Δ) : currentClock + Float(Δ)
                completion(initialValue)
            }
            else { completion(currentClock) }
        }
    }
    
    // MARK: - Observers
    private func observeActivePhase(_ initialValue:Float) {
        let center = NotificationCenter.default
        center.addObserver(forName: .didBecomeActive, object: nil, queue: nil) {
            [weak self] _ in //mainQueue 🟢
            guard let bubble = self?.bubble else { return }
            let isRunning = bubble.state == .running
            
            DispatchQueue.global().async { //bQueue 🔴
                let comp = initialValue.timeComponentsAsStrings //components
                
                DispatchQueue.main.async {//mainQueue 🟢
                    self?.components = Components(comp.hr, comp.min, comp.sec, comp.hundredths)
                    self?.opacity.updateOpacity(initialValue)
                    if isRunning { self?.update(.automatic) }
                    print(#function, " observeActivePhase")
                }
            }
        }
    } //11
    
    // MARK: - Init Deinit
    init(for bubble:Bubble) {
        print(#function)
        self.bubble = bubble
        self.colorPublisher = .init(Color.bubbleColor(forName: bubble.color))
        self.isTimer = bubble.kind != .stopwatch
        
        bInitialValue { [weak self] in
            self?.observeActivePhase($0) //10
            self?.update(.create)
        }
    }
    
    deinit {
        cancellable = []
        NotificationCenter.default.removeObserver(self)
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
