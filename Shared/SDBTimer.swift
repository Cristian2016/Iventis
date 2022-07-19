//
//  SDBTimer.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 12.07.2022.
//

import Foundation

class SDBTimer {
    lazy var dispatchQueue = DispatchQueue(label: "sdbTimer", attributes: .concurrent)
    
    deinit { killTimer() }
    
    ///event handler called every second
    private let updateFrequency:Double = 1 /* every second */
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource(queue: dispatchQueue)
        t.schedule(deadline: .now(), repeating: updateFrequency)
        t.setEventHandler(handler: eventHandler)
        return t
    }()
    
    private var eventHandler: (() -> Void)? = {
        let notification = Notification(name: .sdbTimer)
        NotificationCenter.default.post(notification)
    }
    
    enum State {
        case suspended
        case resumed
    }
    private(set) var state: State = .suspended
    
    //1
    private func resume() {
        if state == .resumed {return}
        state = .resumed
        timer.resume()
    }
    
    //2
    private func suspend() {
        if state == .suspended {return}
        state = .suspended
        timer.suspend()
    }
    
    //3
    private func killTimer() {
        timer.setEventHandler {}
        timer.cancel()
        resume()
        eventHandler = nil
    }
    
    enum Action {
        case start
        case pause
    }
    
    // MARK: - Public
    func perform(_ action:Action) {
        switch action {
            case .start:
                if state == .suspended { resume() } else { return }
            case .pause: suspend()
        }
    }
}
