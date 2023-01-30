import SwiftUI

struct AlertHintContent {
    var symbol:String?
    var titleSymbol:String?
    let title:String
    var content:String?
}

struct AlertHint {
    static let deviceAutoLock = AlertHintContent(symbol: "exclamationmark.triangle.fill", titleSymbol: "sun.max", title: "Always-On\nDisplay", content: "This option prevents the display from sleeping. Battery may drain faster")
    static let calendarOn = AlertHintContent(title: "Calendar")
    
    //Hints
    static let colorChange = AlertHintContent(symbol: "info.circle.fill", titleSymbol: "paintbrush.fill", title: "Change Color", content: "Change the color of a bubble")
    
    static let scrollToTop = AlertHintContent(symbol: "info.circle.fill", title: "Scroll To Top?", content: "Scroll along screen edge")
}

struct AlertHintView: View {
    @EnvironmentObject var viewModel:ViewModel
    
    let alertContent:AlertHintContent
    let dismissAction:() -> ()
    let buttonAction:() -> ()
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.9)
            VStack(spacing: 10) {
                Image(systemName: alertContent.symbol ?? "")
                    .foregroundColor(.yellow)
                    .font(.system(size: 50))
                HStack {
                    Image(systemName: alertContent.titleSymbol ?? "")
                    Text(alertContent.title)
                }
                .font(.system(size: 26))
                .fontWeight(.medium)
                Text(alertContent.content ?? "")
                    .foregroundColor(.secondary)
                    .padding([.leading, .trailing])
                Button("Do not show again") { buttonAction() }
                .buttonStyle(.bordered)
                .fontWeight(.medium)
                .tint(.red)
                .padding()
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.background2)
                    .standardShadow()
            )
            .frame(maxWidth: 320)
        }
        .onTapGesture { dismissAction() }
    }
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertHintView(alertContent: AlertHint.deviceAutoLock, dismissAction: {}, buttonAction: {})
    }
}
