import SwiftUI

struct PairCellPlaceholder: View {
    var body: some View {
        VStack {
            Text("Session")
                .font(.headline)
            Text("...contains Laps. A session keeps adding laps, until the user touch and hold occurs")
                .foregroundStyle(.secondary)
                .font(.caption2)
            
            Color.clear
                .overlay(alignment: .top) {
                    HStack {
                        VStack (alignment: .leading, spacing: 6) {
                            Text("Lap")
                                .fontWeight(.medium)
                            
                            Rectangle()
                                .fill(.clear)
                                .stroke(.gray, style: .init(dash: [2], dashPhase: 0))
                                .overlay(alignment: .leading) {
                                    Text("Start")
                                        .padding(.leading, 8)
                                }
                            Rectangle()
                                .fill(.clear)
                                .stroke(.gray, style: .init(dash: [2], dashPhase: 0))
                                .overlay(alignment: .leading) {
                                    Text("Pause Date")
                                        .padding(.leading, 8)
                                }
                            Rectangle()
                                .fill(.clear)
                                .stroke(.gray, style: .init(dash: [2], dashPhase: 0))
                                .overlay(alignment: .leading) {
                                    Text("Duration")
                                        .padding(.leading, 8)
                                }
                        }
                        .font(.system(size: 18))
                        .monospaced()
                        .padding(10)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 5))
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        .frame(height: 120)
                        .foregroundStyle(.secondary)
                        .padding()
                        Spacer()
                    }
                    .padding(.init(top: 14, leading: 10, bottom: 14, trailing: 0))
                    .frame(maxWidth: .infinity)
                }
        }
    }
}

#Preview {
    PairCellPlaceholder()
}
