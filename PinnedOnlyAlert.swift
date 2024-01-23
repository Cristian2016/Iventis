//
//  PinnedOnlyAlert.swift
//  Eventify (iOS)
//
//  Created by Cristian Lapusan on 10.02.2024.
//

import SwiftUI

struct PinnedOnlyAlert: View {
    @Environment(Secretary.self) private var secretary
    @AppStorage(Storagekey.userFavoritedOnce) private var userFavoritedOnce = false
    
    var body: some View {
        if !userFavoritedOnce && secretary.showFavoritesOnly {
            AlertOverlay("\(Image.pin) Pinned Bubbles", "Pull down on list to toggle pinned") {
            } dismiss: {
                
            } leftAction: {
                
            }
        }
    }
}

#Preview {
    PinnedOnlyAlert()
}
