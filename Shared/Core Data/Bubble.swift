//
//  Bubble+CoreDataClass.swift
//  Timers
//
//  Created by Cristian Lapusan on 15.04.2022.
//
//

import Foundation
import CoreData
import SwiftUI

public class Bubble: NSManagedObject {
    enum State {
        case brandNew //0
        case running //1
        case paused //2
        case finished //3 timers only
    }
    
    var state_:State {
        get {
            switch state {
                case 0: return .brandNew
                case 1: return .running
                case 2: return .paused
                case 3: return .finished ///timers only
                default: return .brandNew
            }
        }
        
        set {
            switch newValue {
                case .brandNew: state = 0
                case .running: state = 1
                case .paused: state = 2
                case .finished: state = 3 //timers only
            }
        }
    }
    
    @Published var receivedValue = 0 {willSet{ self.objectWillChange.send() }}
    
    func startObservingBackgroundTimer() {
        NotificationCenter.default.addObserver(forName: .valueUpdated, object: nil, queue: nil) { [weak self] notification in
            guard let self = self else { return }
            
            guard let value = notification.userInfo?[NSNotification.Name.valueUpdated] as? Int else { fatalError() }
            
            DispatchQueue.main.async { self.receivedValue = value }
        }
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
}
