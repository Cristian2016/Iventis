import SwiftUI
import MyPackage

struct AutoLockSymbol: View {
    var showLabel:Bool =  false
    @EnvironmentObject var viewModel:ViewModel
    let metrics = Metrics()
    
    var body: some View {
        HStack {
            Button {
                viewModel.showAlert_AlwaysOnDisplay.toggle()
                UIApplication.shared.isIdleTimerDisabled.toggle()
                
                viewModel.confirm_AlwaysOnDisplay = true
                delayExecution(.now() + 2) { viewModel.confirm_AlwaysOnDisplay = false }
            }
        label: { label }
        }
    }
    
    // MARK: - Lego
    @ViewBuilder
    private var label:some View {
        if isDisplayAlwaysON {
            HStack {
                if showLabel { FusedLabel(content: .autoLockOff) }
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
        AutoLockSymbol()
    }
}
