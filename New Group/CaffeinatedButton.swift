import SwiftUI
import MyPackage

//button in toolbar
struct CaffeinatedButton: View {
    @Environment(Secretary.self) private var secretary
    @State private var isDisplayCaffeinated = false
    
    var body: some View {
        label
            .onTapGesture { buttonAction() }
    }
    
    // MARK: - Lego
    @ViewBuilder
    private var label:some View {
        if isDisplayCaffeinated {
            if secretary.addNoteButton_bRank == nil { FusedLabel(content: .caffeinated) }
        }
        else { sunSymbol }
    }
    
    private var sunSymbol:some View {
        Label("Prevent Display Sleep", systemImage: "sun.horizon")
    }
    
    // MARK: - methods
    private func buttonAction() {
        //alerts each time AutoLockButton is tapped, until user chooses not to display anymore
        
        if !secretary.showCaffeinatedHint && !isDisplayCaffeinated {
            secretary.showCaffeinatedHint = true
        }
        
        UIApplication.shared.isIdleTimerDisabled.toggle()
        isDisplayCaffeinated = UIApplication.shared.isIdleTimerDisabled ? true : false
        
        //displays confirmation for 2 seconds
        secretary.confirmCaffeinated = true
        delayExecution(.now() + 2) { secretary.confirmCaffeinated = false }
    }
}

struct DisplayAlwaysOnSymbol_Previews: PreviewProvider {
    static var previews: some View {
        CaffeinatedButton()
    }
}
