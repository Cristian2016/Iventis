//
//  BackgroundTimer.swift
//  BubblesSwiftUI
//
//  Created by Cristian Lapusan on 14.04.2022.
//

import Foundation
import SwiftUI

class BackgroundTimer {
    deinit {
        killTimer()
//        print("background timer deinit")
    }
    
    private let updateFrequency:Double = 1
    
    private(set) static var value = 0
    
    let queue:DispatchQueue
    init(_ queue:DispatchQueue) {
        self.queue = queue
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource(queue: queue)
        t.schedule(deadline: .now(), repeating: updateFrequency)
        t.setEventHandler(handler: eventHandler)
        return t
    }()
    
    private var eventHandler: (() -> Void)? = {
        //posts value
        //increases value
        //post again and so on
        
        let info = [NSNotification.Name.valueUpdated : value]
        NotificationCenter.default.post(name: .valueUpdated, object: nil, userInfo: info)
        value += 1
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
            case .start: resume()
            case .pause:
                suspend()
                BackgroundTimer.value = 0 //reset value always
        }
    }
}
