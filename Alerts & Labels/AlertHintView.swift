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
    @Environment(ViewModel.self) var viewModel
    
    let alertContent:AlertHintContent
    let dismissAction:() -> ()
    let buttonAction:() -> ()
    
    var body: some View {
        ZStack {
            MaterialLabel("Always-ON") {
                ScrollView {
                    VStack(spacing: 8) {
                        VStack {
                            Text("Sets Auto-Lock to 'Never'")
                            Text("*Settings App > Display & Brightness > Auto-Lock*")
                                .foregroundStyle(.secondary)
                        }
                        VStack {
                            Text("Display will not sleep until ***Always-ON*** is switched off again")
                        }
                    }
                }
                .frame(maxHeight: 180)
                .forceMultipleLines()
            } _: { buttonAction() } _: { }
        }
        .onTapGesture { dismissAction() }
    }
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertHintView(alertContent: AlertHint.colorChange, dismissAction: {}, buttonAction: {})
    }
}
