import SwiftUI

/// Slide-to-unlock control. SwiftUI replacement for the Android sample's
/// `slide-to-unlock` component used on the custom paywall.
///
/// Apple-style: solid (opaque) black track, white label, white knob.
/// Self-contained: to reset it after a failed action, change its SwiftUI `.id(...)`.
public struct SlideToUnlock: View {
    private let text: String
    private let isLoading: Bool
    private let onUnlock: () -> Void

    @State private var dragX: CGFloat = 0
    @State private var completed = false

    public init(text: String = "Slide to subscribe", isLoading: Bool = false, onUnlock: @escaping () -> Void) {
        self.text = text
        self.isLoading = isLoading
        self.onUnlock = onUnlock
    }

    private let knob: CGFloat = 56

    public var body: some View {
        GeometryReader { geo in
            let maxX = max(0, geo.size.width - knob)
            ZStack(alignment: .leading) {
                Capsule().fill(.black)

                Text(isLoading ? "Processing…" : text)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)

                Circle()
                    .fill(.white)
                    .overlay {
                        if isLoading {
                            ProgressView().tint(.black)
                        } else {
                            Image(systemName: completed ? "checkmark" : "arrow.right")
                                .font(.headline.bold())
                                .foregroundStyle(.black)
                        }
                    }
                    .frame(width: knob, height: knob)
                    .offset(x: dragX)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                guard !isLoading, !completed else { return }
                                dragX = min(max(0, value.translation.width), maxX)
                            }
                            .onEnded { _ in
                                if dragX >= maxX * 0.9 {
                                    dragX = maxX
                                    completed = true
                                    onUnlock()
                                } else {
                                    withAnimation(.spring) { dragX = 0 }
                                }
                            }
                    )
            }
        }
        .frame(height: knob)
    }
}
