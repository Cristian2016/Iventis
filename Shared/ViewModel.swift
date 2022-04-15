//
//  ViewModel.swift
//  Timers
//
//  Created by Cristian Lapusan on 15.04.2022.
//

import Foundation


class ViewModel: ObservableObject {
    private let timer = BackgroundTimer(DispatchQueue(label: "BackgroundTimer", attributes: .concurrent))
    
    func timer(_ action:BackgroundTimer.Action) {
        switch action {
            case .start: timer.perform(.start)
            case .pause: timer.perform(.pause)
        }
    }
    
    init() {
        let request = Bubble.fetchRequest()
        if let bubbles = try? PersistenceController.shared.container.viewContext.fetch(request) {
            bubbles.forEach { $0.observeBackgroundTimer()
            }
        }
    }
}
