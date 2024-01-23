//
//  DPOKCircle.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 22.03.2023.
//1 sets timer duration and dismisses DPV
// shown if display has 6 digits of display shows '48'

import SwiftUI

extension DurationPickerOverlay {
    struct BigCheckmark: View {
        let manager:Manager
        let action:() -> () //1
        
        var body: some View {
            ZStack {
                if show {
                    ClearSaveHintView()
                        .offset(y: -30)
                }
            }
        }
        
        private var show:Bool {
            let digits = manager.digits
            return digits.count == 6 || digits == [4,8]
        }
    }
}
