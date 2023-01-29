//
//  LayoutViewModel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 24.01.2023.
//1 DeleteActionView uses bubbleCell.frame to position itself. bubbleCell.frame is set using .readFrame modifier
//2 the size of BubbleCell above the DetailView that is wrapped inside a List. DetailView must be placed right below the List containing the BubbleCell and therefore List must have same height as BubbleCell
//3 ⚠️ never set size to .zero. it will not work. no fucking idea why!

import SwiftUI
import MyPackage

class LayoutViewModel: ObservableObject {
    var bubbleCellFrame:CGRect? {didSet{
        print(bubbleCellFrame!)
//        set_deleteActionViewOffset(for: bubbleCellFrame)
    }} //1
    
    @Published var bubbleCellSize:CGSize = .zero //2
    
    @Published var deleteActionViewOffset:CGFloat?
    
    // MARK: - Public API
    private(set) var orientation = UIDevice.current.orientation
    var isPortrait:Bool {
        switch orientation {
            case .portrait, .portraitUpsideDown: return true
            case .landscapeLeft, .landscapeRight: return false
            default: return false
        }
    }
    
    // MARK: - Methods
    private func set_deleteActionViewOffset(for frame:CGRect?) {
        guard let frame = frame else { return }
        
        let verticalSpace = isPortrait ? UIScreen.main.bounds.height : UIScreen.main.bounds.width
        let deleteActionViewHeight = DeleteActionView.height
        
        //prefered position of deleteActionView is under the bubbleCell, but only if it has enough room
        let deleteActionViewFitsUnderneath = verticalSpace - (frame.origin.y + frame.height) > deleteActionViewHeight
        
        print("deleteActionViewFitsUnderneath \(deleteActionViewFitsUnderneath)")
    }
    
    private func observeOrientationChanges() {
        let notification = UIDevice.orientationDidChangeNotification
        NotificationCenter.default.addObserver(forName: notification, object: nil, queue: nil) { [weak self] notification in
            self?.orientation = UIDevice.current.orientation
        }
    }
    
    // MARK: - Init/deinit
    init() { delayExecution(.now() + 0.1) { self.observeOrientationChanges() } }
    
    deinit { NotificationCenter.default.removeObserver(self) }
}

struct SizePreferenceKey:PreferenceKey {
    static var defaultValue = CGSize(width: 1, height: 1) //3 ⚠️
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}
