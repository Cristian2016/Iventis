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
        timer.activate()
    }
    
    private var handler: (() -> Void)?
    
    deinit {
        print("PrecisionTimer deinit")
    }
}
