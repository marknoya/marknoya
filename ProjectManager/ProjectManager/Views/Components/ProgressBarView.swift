import SwiftUI

struct ProgressBarView: View {
    let percentage: Double
    var height: CGFloat = 6

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: height)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(barColor)
                    .frame(width: geo.size.width * CGFloat(min(percentage, 100) / 100), height: height)
                    .animation(.easeInOut(duration: 0.3), value: percentage)
            }
        }
        .frame(height: height)
    }

    var barColor: Color {
        switch percentage {
        case 100: return .green
        case 50...: return .blue
        default: return .orange
        }
    }
}
