//
//  bTimer.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 30.05.2023.
//
//
//  BTimer.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 30.05.2023.
// maybe too many backrgound timers. BackgroundTimer and PrecisionTimer and now this one :))
// TODO: Reduce number of timers maybe?
// used by Views to receive notifications to do shit

import Foundation

///repeat frequency defaults to one second
class bTimer {
    // MARK: - Private
    deinit {
        killTimer()
        print("bTimer deinit")
    }
    
    ///event handler called every second
    let frequency:Double /* every second? */
    let repeatCount:Int
    let deadLine:DispatchTime
    
    init(deadLine:DispatchTime, frequency:Double = 1.0, repeatCount: Int) {
        self.deadLine = deadLine
        self.frequency = frequency
        self.repeatCount = repeatCount
    }
        
    let queue = DispatchQueue(label: "bTimer", attributes: .concurrent)
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource(queue: queue)
        t.schedule(deadline: deadLine, repeating: frequency)
        t.setEventHandler(handler: eventHandler)
        return t
    }()
    
    var eventHandler: (() -> Void)?
    
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
        case kill
    }
    
    // MARK: - Public
    func perform(_ action:Action) {
        switch action {
            case .start:
                if state == .suspended { resume() } else { return }
            case .pause:
                suspend()
            case .kill:
                killTimer()
        }
    }
}
