import SwiftUI

struct ProgressCircle: View {
    var progress: Double // 0.0 to 1.0
    var label: String
    var accentColor: Color = .purple
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 16)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(accentColor, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
            VStack {
                Text(label)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("\(Int(progress * 100))% Calories")
                    .font(.headline)
                    .foregroundColor(accentColor)
            }
        }
        .frame(width: 180, height: 180)
        .shadow(color: accentColor.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct ProgressCircle_Previews: PreviewProvider {
    static var previews: some View {
        ProgressCircle(progress: 0.31, label: "Food Diary")
    }
} 