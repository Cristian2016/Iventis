//
//  LayoutViewModel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 24.01.2023.
//

import SwiftUI
import MyPackage

class LayoutViewModel: ObservableObject {
    ///DeleteActionView uses bubbleCellFrame to position itself within the ViewHierarchy. bubbleCellFrame is set using .readFrame($bubbleCellFrame) modifier
    var bubbleCellFrame:CGRect? {didSet{
        set_deleteActionViewOffset(for: bubbleCellFrame)
    }}
    
    @Published var deleteActionViewOffset:CGFloat?
    
    private(set) var orientation = UIDevice.current.orientation {didSet{
        print(orientationDescription)
    }}
    
    // MARK: - Methods
    private func set_deleteActionViewOffset(for frame:CGRect?) {
        guard let frame = frame else { return }
        print(frame)
    }
    
    private var orientationDescription:String {
        switch orientation {
            case .portrait, .portraitUpsideDown: return "portrait"
            case .landscapeLeft, .landscapeRight: return "landscape"
            default: return "does not matter"
        }
    }
    
    // MARK: - Init/deinit
    init() {
        let notification = UIDevice.orientationDidChangeNotification
        NotificationCenter.default.addObserver(forName: notification, object: nil, queue: nil) { [weak self] notification in
            self?.orientation = UIDevice.current.orientation
        }
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
}
