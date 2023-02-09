import SwiftUI
import MyPackage

//button in toolbar
struct AutoLockButton: View {
    @EnvironmentObject var viewModel:ViewModel
    
    let metrics = Metrics()
    
    private let secretary = Secretary.shared
    @State private var addNoteButton_bRank:Int?
    
    var body: some View {
            Button {
                secretary.showAlert_AlwaysOnDisplay.toggle()
                UIApplication.shared.isIdleTimerDisabled.toggle()
                
                secretary.confirm_AlwaysOnDisplay = true
                delayExecution(.now() + 2) { secretary.confirm_AlwaysOnDisplay = false }
            }
        label: { label }
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
        ZStack {
            Image(systemName: "sun.max.fill")
                .foregroundColor(metrics.symbolColor)
            Image(systemName: "line.diagonal")
                .foregroundColor(metrics.diagonalLineColor)
                .fontWeight(.bold)
        }
        .font(metrics.font)
    }
    
    private var enterSymbol:some View {
        Image(systemName: "sun.max")
            .foregroundColor(metrics.symbolColor)
            .font(metrics.font)
    }
    
    // MARK: -
    private var isDisplayAlwaysON:Bool { get { UIApplication.shared.isIdleTimerDisabled } }
    
    struct Metrics {
        let font = Font.system(.title3)
        let symbolColor = Color.label
        let diagonalLineColor = Color.red
    }
}

struct DisplayAlwaysOnSymbol_Previews: PreviewProvider {
    static var previews: some View {
        AutoLockButton()
    }
}
