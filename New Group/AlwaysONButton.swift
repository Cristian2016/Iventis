import SwiftUI
import MyPackage

//button in toolbar
struct AlwaysONButton: View {
    let metrics = Metrics()
    
    @Environment(Secretary.self) private var secretary
    @State private var isDisplayAlwaysON = false
    
    var body: some View {
        label
            .onTapGesture { buttonAction() }
    }
    
    // MARK: - Lego
    @ViewBuilder
    private var label:some View {
        if isDisplayAlwaysON {
            if secretary.addNoteButton_bRank == nil { FusedLabel(content: .alwaysON) }
        }
        else { sunSymbol }
    }
    
    private var sunSymbol:some View {
        Label("Prevent Display Sleep", systemImage: "sun.max")
            .font(metrics.font)
    }
    
    // MARK: - methods
    private func buttonAction() {
        //alerts each time AutoLockButton is tapped, until user chooses not to display anymore
        
        secretary.showAlert_AlwaysOnDisplay.toggle()
        UIApplication.shared.isIdleTimerDisabled.toggle()
        isDisplayAlwaysON = UIApplication.shared.isIdleTimerDisabled ? true : false
        
        //displays confirmation for 2 seconds
        secretary.displayAutoLockConfirmation = true
        delayExecution(.now() + 2) { secretary.displayAutoLockConfirmation = false }
    }
    
    // MARK: -
    struct Metrics {
        let font = Font.system(size: 18)
    }
}

struct DisplayAlwaysOnSymbol_Previews: PreviewProvider {
    static var previews: some View {
        AlwaysONButton()
    }
}
