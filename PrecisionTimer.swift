//
//  PrecisionTimer.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 13.03.2023.
//

import Foundation

class PrecisionTimer {
    private var timer:DispatchSourceTimer = {
        let queue = DispatchQueue(label: "precisionTimer", qos: .userInteractive)
        let timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
        return timer
    }()
    
    // MARK: - Public API
    func setHandler(with deadline:DispatchTime, handler: @escaping () -> Void) {
        timer.setEventHandler { handler() }
        timer.schedule(deadline: deadline, leeway: .nanoseconds(0))
        perform(.start)
    }
    
    private var handler: (() -> Void)?
    
    deinit {
        perform(.kill)
        print("PrecisionTimer deinit")
    }
    
    enum Action {
        case start
        case kill
    }
    
    enum State {
        case suspended
        case resumed
    }
    private(set) var state: State = .suspended
    
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
}
