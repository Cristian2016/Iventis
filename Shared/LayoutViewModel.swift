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
    
    private(set) var orientation = UIDevice.current.orientation
    
    // MARK: - Methods
    private func set_deleteActionViewOffset(for frame:CGRect?) {
        guard let frame = frame else { return }
        
        let verticalSpace = isPortrait ? UIScreen.main.bounds.height : UIScreen.main.bounds.width
        let deleteActionViewHeight = DeleteActionView.height
        
        //prefered position of deleteActionView is under the bubbleCell, but only if it has enough room
        let deleteActionViewFitsUnderneath = verticalSpace - (frame.origin.y + frame.height) > deleteActionViewHeight
        
        print("deleteActionViewFitsUnderneath \(deleteActionViewFitsUnderneath)")
    }
    
    private var isPortrait:Bool {
        switch orientation {
            case .portrait, .portraitUpsideDown: return true
            case .landscapeLeft, .landscapeRight: return false
            default: return false
        }
    }
    
    // MARK: - Init/deinit
    init() {
        delayExecution(.now() + 0.1) {
            print(#function)
            let notification = UIDevice.orientationDidChangeNotification
            NotificationCenter.default.addObserver(forName: notification, object: nil, queue: nil) { [weak self] notification in
                self?.orientation = UIDevice.current.orientation
                print("isPortrait \(self!.orientation.isPortrait)")
            }
        }
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
}
