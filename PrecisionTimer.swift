//
//  PrecisionTimer.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 13.03.2023.
//

import Foundation

///executes handler only once [at a specified dealine] and then it deinits immediately
class PrecisionTimer {
    private var timer:DispatchSourceTimer = {
        let queue = DispatchQueue(label: "precisionTimer", qos: .userInteractive)
        let timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
        return timer
    }()
    private(set) var state: State = .suspended
    
    private var handler: (() -> Void)?
    
    // MARK: - Public API
    func executeAction(after deadline:DispatchTime, handler: @escaping () -> Void) {
        timer.setEventHandler { handler() }
        timer.schedule(deadline: deadline, leeway: .nanoseconds(0))
        perform(.start)
    }
    
    // MARK: -
    private func perform(_ action:Action) {
        switch action {
            case .start:
                if state == .suspended { resume() } else { return }
            case .kill:
                timer.setEventHandler {}
                timer.cancel()
                resume()
                handler = nil
        }
    }
    
    private func resume() {
        if state == .resumed {return}
        state = .resumed
        timer.resume()
    }
    
    deinit {
        perform(.kill)
    }
}

extension PrecisionTimer {
    enum Action {
        case start
        case kill
    }
    
    enum State {
        case suspended
        case resumed
    }
}
