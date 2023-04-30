import SwiftUI
import MyPackage

//button in toolbar
struct CaffeinatedButton: View {
    let metrics = Metrics()
    
    private let secretary = Secretary.shared
    @State private var addNoteButton_bRank:Int?
    @State private var isDisplayAlwaysON = false
    
    var body: some View {
        Button { buttonAction() } label: { label }
            .onReceive(secretary.$addNoteButton_bRank) { addNoteButton_bRank = $0 }
    }
    
    // MARK: - Lego
    @ViewBuilder
    private var label:some View {
        if isDisplayAlwaysON {
            HStack {
                if addNoteButton_bRank == nil { FusedLabel(content: .autoLockOff) }
                exitSymbol
            }
        }
        else { enterSymbol }
    }
    
    private var exitSymbol:some View {
        Image(systemName: "cup.and.saucer.fill")
            .foregroundColor(metrics.symbolColor)
            .font(metrics.font)
    }
    
    private var enterSymbol:some View {
        Image(systemName: "cup.and.saucer")
            .foregroundColor(metrics.symbolColor)
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
        let symbolColor = Color.label
        let diagonalLineColor = Color.red
    }
}

struct DisplayAlwaysOnSymbol_Previews: PreviewProvider {
    static var previews: some View {
        CaffeinatedButton()
    }
}
