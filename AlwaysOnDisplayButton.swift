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
                delayExecution(.now() + 2) {
                    viewModel.confirm_AlwaysOnDisplay = false
                }
            }
        label: { label }
        .padding([.leading, .trailing], 12)
        }
    }
    
    // MARK: - Lego
    @ViewBuilder
    private var label:some View {
        if isDisplayAlwaysON {
            HStack {
                Text("Always-on Display")
                    .foregroundColor(.white)
                    .font(.footnote)
                    .padding([.leading, .trailing])
                    .background {
                        RoundedRectangle(cornerRadius: 4).fill(.red)
                    }
                exitAlwaysONDisplay_Symbol
            }
        }
        else { displayONSymbol }
    }
    private var exitAlwaysONDisplay_Symbol:some View {
        ZStack {
            Image(systemName: "sun.max.fill")
            Image(systemName: "line.diagonal")
                .foregroundColor(.label)
        }
        .fontWeight(.semibold)
        .foregroundColor(.red)
//        .padding([.top, .bottom], 3)
//        .padding([.leading, .trailing], 10)
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
