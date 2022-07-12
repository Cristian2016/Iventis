//
//  SDBTimer.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 12.07.2022.
//

import Foundation

class SDBTimer {
    deinit {
        print("SDBTimer deinit")
        killTimer()
    }
    
    ///event handler called every second
    private let updateFrequency:Double = 1.0 /* every second */
        
    let queue:DispatchQueue
    init(_ queue:DispatchQueue) {
        print("SDBTimer init")
        self.queue = queue
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource(queue: queue)
        t.schedule(deadline: .now(), repeating: updateFrequency)
        t.setEventHandler(handler: eventHandler)
        return t
    }()
    
    private var eventHandler: (() -> Void)? = {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .sdbTimerSignal, object: nil)
        }
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
