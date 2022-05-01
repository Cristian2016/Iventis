//
//  CalendarView.swift
//  Timers
//
//  Created by Cristian Lapusan on 01.05.2022.
//

import SwiftUI

struct CalendarView: View {
    let calRatio:CGFloat = 98.0/91.0
    
    var body: some View {
        ZStack {
            Image(systemName: "calendar")
                .foregroundColor(.calendar)
                .font(.system(size: 50))
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
