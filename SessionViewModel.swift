//
//  SessionViewModel.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import Foundation
import SwiftUI
import CoreData
import Combine

class SessionViewModel: ObservableObject {
    @Published var sessions = [Session]()
    
    lazy var viewContext = PersistenceController.shared.viewContext
    let bubbleRank:Int
    
    init(_ bubbleRank:Int) {
        self.bubbleRank = bubbleRank
        refreshSessions()
    }
    
    func refreshSessions() {
        let request = Session.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "created", ascending: false)]
        request.predicate = NSPredicate(format: "bubble.rank = %i", bubbleRank)
        
        guard let sessions = try? viewContext.fetch(request) else { return }
        self.sessions = sessions
    }
}
