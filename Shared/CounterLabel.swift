//
//  CounterLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 19.11.2023.
//

import SwiftUI

struct CounterLabel: View {
    var kind = Kind.stopwatch
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .font(.system(size: 30))
            Text(text)
                .font(.system(size: 14))
        }
    }
    
    private var text:String {
        switch kind {
            case .stopwatch: return "Stpwtch"
            case .timer: return "Timer"
        }
    }
    
    private var imageName:String {
        switch kind {
            case .stopwatch: return "stopwatch"
            case .timer: return "timer"
        }
    }
    
    enum Kind {
        case stopwatch
        case timer
    }
}

#Preview {
    CounterLabel()
}
