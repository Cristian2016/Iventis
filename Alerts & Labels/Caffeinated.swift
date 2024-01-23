import SwiftUI

struct AlertHintContent {
    var symbol:String?
    var titleSymbol:String?
    let title:String
    var content:String?
}

struct CaffeinatedAlert: View {
    @Environment(Secretary.self) private var secretary
    @State private var showAlert_AlwaysOnDisplay = false
    @AppStorage(Storagekey.showEachTimeCaffeinatedHint) var showEachTimeCaffeinatedHint = true
    
    var body: some View {
        if secretary.showCaffeinatedHint && showEachTimeCaffeinatedHint {
            AlertOverlay("\(Image(systemName: "sun.horizon")) Caffeinated") {
                VStack(spacing: 8) {
                    Text("...sets Auto-Lock to 'Never'")
                    Text("*Settings App > Display & Brightness > Auto-Lock*")
                        .foregroundStyle(.secondary)
                    Text("Turn off 'Caffeinated' to allow display sleep")
                }
                .forceMultipleLines()
            } dismiss: {
                //dismiss hint
                { secretary.showCaffeinatedHint = false }()
            } leftAction : {
                //never show hint again
                { showEachTimeCaffeinatedHint = false }()
            }
        }
    }
}

struct CaffeinatedConfirmation: View {
    @Environment(Secretary.self) private var secretary
    @State var confirm_AlwaysOnDisplay = false
    
    var body: some View {
        ZStack {
            if confirm_AlwaysOnDisplay {
                ConfirmOverlay(content: UIApplication.shared.isIdleTimerDisabled ? .appCaffeinated : .appCanSleep)
            }
        }
        .onChange(of: secretary.confirmCaffeinated) {
            confirm_AlwaysOnDisplay = $1
        }
    }
}

struct AlwaysOnDisplayConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        CaffeinatedConfirmation()
    }
}

