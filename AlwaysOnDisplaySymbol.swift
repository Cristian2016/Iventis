import SwiftUI

struct AlwaysOnDisplaySymbol: View {
    @EnvironmentObject var vm:ViewModel
    let fontSize = CGFloat(30)
    
    var body: some View {
        HStack {
            Button {
                vm.showAlert_AlwaysOnDisplay.toggle()
                UIApplication.shared.isIdleTimerDisabled.toggle()
            }
        label: {
            Label {
                Text(UIApplication.shared.isIdleTimerDisabled ? "Exit" : "")
                    .font(.system(size:20).weight(.bold))
            } icon: {
                if UIApplication.shared.isIdleTimerDisabled { exitAlwaysONDisplay_Symbol }
                else { displayONSymbol }
            }
        }
        .tint(.red)
        .padding([.leading, .trailing], 12)
        .background {
            if UIApplication.shared.isIdleTimerDisabled {
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
}

struct DisplayAlwaysOnSymbol_Previews: PreviewProvider {
    static var previews: some View {
        AlwaysOnDisplaySymbol()
    }
}
