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
//14 ThreeLabels + HundredthsLabel (hr, min, sec, hundredths)
//15 ThreeCircles opacity
//16 ThreeCircles color
//17 start delay button YOffset
//18 start delay button delete triggered
//19 init called only for visible bubbles. on iPhone 12 max 4 bubbles are displayed, the 5th and so on are not visible. so init called only 4 times. As the user scrolls exposing more bubbles, more initializers get called

import SwiftUI
import Combine
import MyPackage

extension BubbleCellCoordinator {
    typealias Publisher = CurrentValueSubject
}

@Observable class BubbleCellCoordinator {
    weak private(set) var bubble:Bubble?
    
    var isTimer:Bool
    
    internal var precisionTimer = PrecisionTimer()
    
    // MARK: - Publishers
    var components = Components("-1", "-1", "-1", "00") //14
    var showHundredths:Bool { cancellable == [] }
    internal var opacity = Opacity() //15
    var color:Color //16
    var timerProgress = "OK" //8 Timers only
    
    // MARK: -
    //called each time user changes timer duration or changes to stopwatch
    func updateOnBubbleChanged() {
        guard let bubble = bubble else { return }
        
        isTimer = bubble.isTimer
        update(.automatic)
    }
    
    private func shouldKill(_ bubble:Bubble) -> Bool {
        if bubble.isTimer,
            bubble.isRunning,
            let mostRecentStart = bubble.lastSession?.lastPair?.start {
            
            let elapsed = Float(Date.now.timeIntervalSince(mostRecentStart))
            let shouldBeFinished = bubble.currentClock - elapsed <= 0
            
            if shouldBeFinished {
                return true
            }
        }
        return false
    }
    
    private var doNotAllowRefreshOnAppear = false
    
    //running bubbles only! update time components and opacity, update once, before bubble is visible again
    func refreshBubble(on moment:RefreshMoment) {
        guard let bubble = bubble else { return }
        
        //prevent appLaunch and onAppear to get called at the same time
//        if moment == .appLaunch { doNotAllowRefreshOnAppear = true }
//        if doNotAllowRefreshOnAppear && moment == .appear {
//            doNotAllowRefreshOnAppear = false
//            return
//        }
        
        //do not refresh notRunning bubbles at onAppear
        if moment == .appear && !bubble.isRunning {  return }
                
        let bContext = PersistenceController.shared.bContext
        let objID = bubble.objectID
        
        bContext.perform {
            let bBubble = PersistenceController.shared.grabObj(objID) as! Bubble
                        
            switch bBubble.isRunning {
                case false: //NOT running
                    let updatedCurrentClock = bBubble.currentClock
                    let comp = updatedCurrentClock.componentsAsString
                    
                    //update time components, opacity, timerProgress
                    DispatchQueue.main.async {
                        self.components = Components(comp.hr, comp.min, comp.sec, comp.hundredths)
                        self.opacity.update(for: updatedCurrentClock)
                        
                        //compute timer progress
                        if bBubble.isTimer {
                            switch bBubble.state {
                                case .finished:
                                    self.timerProgress = "Done"
                                case .brandNew:
                                    self.timerProgress = "OK"
                                default:
                                    if moment == .change {
                                        self.timerProgress = "OK"
                                        return
                                    }
                                    let progress = self.computeTimerProgress(for: bBubble, and: updatedCurrentClock)
                                    self.timerProgress = String(format: "%.2f", progress)
                            }
                        }
                    }
                    
                case true: //running
                    guard let lastStart = bBubble.lastPair?.start else { return }
                    
                    let currentClock = bBubble.currentClock
                    let elapsedSinceLastStart = Float(Date().timeIntervalSince(lastStart))
                    var updatedCurrentClock = self.isTimer ? currentClock - elapsedSinceLastStart : currentClock + elapsedSinceLastStart
                    
                    updatedCurrentClock.round(.toNearestOrEven)
                    let intUpdatedCurrentClock = Int(updatedCurrentClock)
                    let intMin = intUpdatedCurrentClock/60%60
                    
                    let hr = String(intUpdatedCurrentClock/3600)
                    let min = String(intMin)
                    let sec = String(intUpdatedCurrentClock%60)
                    
                    //do I need this? I don't get any kind of warning if I don't dispatch to mainQueue
                    DispatchQueue.main.async {
                        //refresh hr, min, sec time components & hr, min opacities
                        if self.components.hr != hr { self.components.hr = hr }
                        if self.components.min != min { self.components.min = min }
                        if self.components.sec != sec { self.components.sec = sec }
                        
                        self.opacity.update(for: updatedCurrentClock)
                    }
            }
        }
    }
    
    enum RefreshMoment {
        case appear
        case phaseChange
        case appLaunch //BubbleCell is initialized
        case change
    }
    
    // MARK: - Public API
    func update(_ moment:Moment) { //main Thread ⚠️
        guard let bubble = bubble else { return }
        
        let bContext = PersistenceController.shared.bContext
        let objID = bubble.objectID
        
        bContext.perform {
            let theBubble = PersistenceController.shared.grabObj(objID) as! Bubble
            
            switch moment {
                case .automatic: //ignore paused bubbles
                    if !theBubble.isRunning { return }
                    
                    let initialValue = self.updatedCurrentClock(theBubble)
                    
                    DispatchQueue.main.async {
                        if bubble.isTimer {
                            let progress = self.computeTimerProgress(for: theBubble, and: initialValue)
                            self.timerProgress = String(format: "%.2f", progress)
                        }
                    }
                    
                    //resume running
                    self.publisher = NotificationCenter.Publisher(center: .default, name: .bubbleTimerSignal)
                    self.publisher?
                        .sink { [weak self] _ in
                            self?.task(theBubble)
                        }
                        .store(in: &self.cancellable) //connect
                    
                case .killTimer:
                    print("update.killTimer bubble \(bubble.color ?? "No color")")
                    self.stopRepetitiveTask()
                    DispatchQueue.main.async {
                        self.components = Components("0", "0", "0", "✕")
                        self.opacity = .init(hr: 0, min: 0)
                        self.timerProgress = "Done"
                    }
                    
                default: break
            }
        }
    }
    
    // MARK: -
    internal func computeTimerProgress(for bubble:Bubble, and value:Float) -> Double {
        1 - Double(value/(bubble.initialClock))
    }
    
    // MARK: - Publishers 1
    internal var publisher:NotificationCenter.Publisher?
    
    internal var cancellable = Set<AnyCancellable>()
    
    ///do not use bubble from viewContext! read bubble from bContext
    internal func updatedCurrentClock(_ bubble:Bubble) -> Float { //bThread
        let currentClock = bubble.currentClock
        
        if bubble.state == .running {
            let Δ = Date().timeIntervalSince(bubble.lastPair?.start ?? Date())
            let initialValue = isTimer ?  currentClock - Float(Δ) : currentClock + Float(Δ)
            return initialValue
        }
        else { return currentClock }
    }
    
    ///notifies ViewModel to finish bubble. refresh components when app active again
    internal func requestKillTimer(_ overspill:Float? = nil) {
        guard let bubble = bubble else { return }
        
        reportBlue(bubble, "coordinator.requestKillTimer")
        
        let info:[String : Any] = ["rank" : bubble.rank, "overspill" : overspill ?? 0.0]
        NotificationCenter.default.post(name: .killTimer, object: nil, userInfo: info)
    }
    
    private func updatedCurrentClock(for bubble:Bubble, _ lastStart:Date) -> Float {
        let currentClock = bubble.currentClock
        
        let elapsedSinceLastStart = Float(Date().timeIntervalSince(lastStart)) //2
        
        var updatedCurrentClock = isTimer ? currentClock - elapsedSinceLastStart : currentClock + elapsedSinceLastStart //ex: 2345.87648
        
        updatedCurrentClock.round(.toNearestOrEven) //ex: 2346
        return updatedCurrentClock
    }
    
    // MARK: - Init Deinit
    init(for bubble:Bubble) { //19
        self.bubble = bubble
        self.color = Color.bubbleColor(forName: bubble.color)
        self.isTimer = bubble.kind != .stopwatch
        
        self.refreshBubble(on: .appLaunch)
        self.update(.automatic)
    }
    
    internal func stopRepetitiveTask() { cancellable = [] }
    
    deinit {
        stopRepetitiveTask()
        NotificationCenter.default.removeObserver(self)
    }
}

extension BubbleCellCoordinator {
    ///automatic means handled by the system. ex. when app launches
    enum Moment {
        case automatic
        case showAll //show all bubbles, including the ordinary ones
        case killTimer
    }
    
    struct Components:Equatable {
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
        
        mutating func update(for value:Float) {
            min = value < 60 ? 0.001 : 1
            hr = value < 3600 ? 0.001 : 1
        }
    }
}

