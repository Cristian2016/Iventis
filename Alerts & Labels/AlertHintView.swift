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
    
    static let scrollToTop = AlertHintContent(title: "", content: "Scroll to Top along screen edges")
}

struct AlertHintView: View {
    @EnvironmentObject var viewModel:ViewModel
    
    let alertContent:AlertHintContent
    let dismissAction:() -> ()
    let buttonAction:() -> ()
    
    var body: some View {
        ZStack {
            ThinMaterialLabel("Caffeinated", "App had a cup of coffee and will not sleep!") {
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading) {
                        Text("This option overrides Auto-Lock option")
                        Text("*Settings App > Display & Brightness > Auto-Lock*")
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Regardless of the current device settings, Auto-Lock for this app is now set to 'Never'. Display will not sleep, unless 'Caffeinated' is switched off")
                    }
                }
                .forceMultipleLines()
            } action: {
                buttonAction()
            }
        }
        .onTapGesture { dismissAction() }
    }
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertHintView(alertContent: AlertHint.scrollToTop, dismissAction: {}, buttonAction: {})
    }
}
