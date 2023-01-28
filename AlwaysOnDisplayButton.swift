import SwiftUI
import MyPackage

struct AlwaysOnDisplayButton: View {
    @EnvironmentObject var viewModel:ViewModel
    
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
                Text("Always-On Display")
                    .foregroundColor(.secondary)
                    .font(.footnote)
                    .padding([.leading, .trailing])
                    .padding([.top, .bottom], 4)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary, lineWidth: 1)
                    }
                exitAlwaysONDisplay_Symbol
            }
        }
        else { displayONSymbol }
    }
    private var exitAlwaysONDisplay_Symbol:some View {
        ZStack {
            Image(systemName: "sun.max.fill")
                .foregroundColor(.label)
            Image(systemName: "line.diagonal")
                .fontWeight(.black)
                .foregroundColor(.red)
        }
        .fontWeight(.semibold)
        .font(.system(size: fontSize))
    }
    
    private var displayONSymbol:some View {
        Image(systemName: "sun.max")
            .foregroundColor(.label)
            .font(.system(size: fontSize))
    }
    
    // MARK: -
    private var isDisplayAlwaysON:Bool { get { UIApplication.shared.isIdleTimerDisabled } }
    let fontSize = CGFloat(30)
}

struct DisplayAlwaysOnSymbol_Previews: PreviewProvider {
    static var previews: some View {
        AlwaysOnDisplayButton()
    }
}
