import SwiftUI

struct AlwaysOnDisplaySymbol: View {
    @EnvironmentObject var viewModel:ViewModel
    
    var body: some View {
        HStack {
            Button {
                viewModel.showAlert_AlwaysOnDisplay.toggle()
                UIApplication.shared.isIdleTimerDisabled.toggle()
                
                viewModel.confirm_AlwaysOnDisplay = true
                delayExecution(.now() + 0.5) {
                    viewModel.confirm_AlwaysOnDisplay = false
                }
            }
        label: {
            Label {
                Text(isDisplayAlwaysON ? "Exit" : "")
                    .font(.system(size:20).weight(.bold))
            } icon: {
                if isDisplayAlwaysON { exitAlwaysONDisplay_Symbol }
                else { displayONSymbol }
            }
        }
        .tint(.red)
        .padding([.leading, .trailing], 12)
        .background {
            if isDisplayAlwaysON {
                RoundedRectangle(cornerRadius: 10).stroke(.red, lineWidth: 4)
            }
        }
        }
    }
    
    // MARK: -
    private var exitAlwaysONDisplay_Symbol:some View {
        ZStack {
            Image(systemName: "sun.max")
            Image(systemName: "line.diagonal")
                .foregroundColor(.label)
        }
        .fontWeight(.semibold)
        .foregroundColor(.red)
        .padding([.top, .bottom], 3)
        .padding([.leading, .trailing], 10)
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
        AlwaysOnDisplaySymbol()
    }
}
