import SwiftUI
import AVFoundation

struct CColorPicker: View {
    let colors:  [Color] = [Color(red: 0.20, green: 0.68, blue: 0.90), Color(red: 0.19, green: 0.69, blue: 0.78) ,.blue, .green, .yellow, .orange, .red, .purple, Color(red: 0.64, green: 0.52, blue: 0.37), .white, .gray, .black]
    
    @Binding var selectedColor: Color
    
    var body: some View {
        Spacer()
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .center, spacing: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 15) {
                colorPickerImage
                    .background(
                        ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                            .labelsHidden().opacity(0)
                    )
                
                ForEach(colors, id: \.self) { c in
                    colorCircle(for: c)
                }
            }
            .padding()
            
            Spacer()
        }
    }

    private var colorPickerImage: some View {
        Image("ellipse")
            .resizable()
            .frame(
                width: UIScreen.main.bounds.height * (UIDevice.current.userInterfaceIdiom == .pad ? 0.075 : 0.099),
                height: UIScreen.main.bounds.height * (UIDevice.current.userInterfaceIdiom == .pad ? 0.075 : 0.099)
            )
            .onTapGesture {
                handleColorPickerImageTap()
            }
    }

    private func handleColorPickerImageTap() {
        AudioServicesPlaySystemSound(SystemSoundID(1105))
        UIColorWellHelper.helper.execute?()
        addHapticFeedbackWithStyle(style: .medium)
    }

    private func colorCircle(for color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(
                width: UIScreen.main.bounds.height * circleSizeMultiplier(for: color),
                height: UIScreen.main.bounds.height * circleSizeMultiplier(for: color)
            )
            .overlay(Circle().stroke(selectedColor == color ? .white : Color.clear, lineWidth: UIDevice.current.userInterfaceIdiom == .pad ? 5 : 3))
            .onTapGesture {
                handleColorCircleTap(for: color)
            }
    }

    private func circleSizeMultiplier(for color: Color) -> CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? (selectedColor == color ? 0.085 : 0.075) : (selectedColor == color ? 0.11 : 0.099)
    }

    private func handleColorCircleTap(for color: Color) {
        AudioServicesPlaySystemSound(SystemSoundID(1105))
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.25)) {
            selectedColor = color
            addHapticFeedbackWithStyle(style: .medium)
        }
    }
    
    func addHapticFeedbackWithStyle(style : UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

struct CColorPicker_Previews: PreviewProvider {
    @State static private var slectedColor = Color.purple
    static var previews: some View {
        CColorPicker(selectedColor: $slectedColor)
    }
}

extension UIColorWell {
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let uiButton = self.subviews.first?.subviews.last as? UIButton {
            UIColorWellHelper.helper.execute = {
                uiButton.sendActions(for: .touchUpInside)
            }
        }
    }
}

class UIColorWellHelper: NSObject {
    static let helper = UIColorWellHelper()
    var execute: (() -> ())?
    @objc func handler(_ sender: Any) {
        execute?()
    }
}

