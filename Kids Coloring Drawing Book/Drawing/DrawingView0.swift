import SwiftUI
import PencilKit
import AVFAudio
import UIKit

struct DrawingView0: View {
    
    @State private var canvas = PKCanvasView()
    @State private var isDraw = true
    @State private var color: Color = .black
    @State private var type: PKInkingTool.InkType = .pen
    @State private var selctedColor: Color = .blue
    @State private var lines = [Line]()
    @State private var undoLines = [Line]()
    @State private var selectedItem: Int = 0
    @State private var buttonScale: CGFloat = 1.0
    @State private var selectedColor = Color.red
    @State private var strokeWidth: CGFloat = 8.0
    @State private var savedStrokes: [PKStroke] = []
    @State private var currentStrokeIndex: Int = 0
    @State private var animationParametricValue: CGFloat = 0
    @State private var animationLastFrameTime: Date = Date()
    @State private var animationTimer: Timer?
    @State private var showStrokeWidthMenu = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.undoManager) private var undoManager
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            
            //Background Color
            Color(red: 0.73, green: 0.65, blue: 1.00).ignoresSafeArea(.all)
            
            HStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center, spacing: UIDevice.current.userInterfaceIdiom == .pad ? 15 : 6) {
                        
                        Button {
                            withAnimation {
                                type = .pencil
                                isDraw = true
                                selectedItem = 1
                                showStrokeWidthMenu.toggle()
                                AudioServicesPlaySystemSound(SystemSoundID(1105))
                                addHapticFeedbackWithStyle(style: .medium)
                            }
                        } label: {
                            Image(systemName: "highlighter")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.height * (UIDevice.current.userInterfaceIdiom == .pad ? 0.06 : 0.08),
                                       height: UIScreen.main.bounds.height * (UIDevice.current.userInterfaceIdiom == .pad ? 0.06 : 0.08))
                                .padding(8)
                                .scaleEffect(selectedItem == 1 ? 1.4 : 1.0)
                        }
                        .foregroundColor(selectedItem == 1 ? Color(red: 0.73, green: 0.65, blue: 1.00) : .white)
                        
                        if showStrokeWidthMenu && selectedItem == 1 {
                            VStack(spacing: 12) {
                                ForEach([4.0, 8.0, 12.0, 16.0], id: \.self) { width in
                                    Button {
                                        withAnimation {
                                            strokeWidth = width
                                            AudioServicesPlaySystemSound(SystemSoundID(1105))
                                            addHapticFeedbackWithStyle(style: .light)
                                        }
                                    } label: {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: width * 2, height: width * 2)
                                            .overlay(
                                                Circle()
                                                    .stroke(strokeWidth == width ? Color(red: 0.73, green: 0.65, blue: 1.00) : Color.clear, lineWidth: 2)
                                            )
                                    }
                                }
                            }
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.00)))
                            )
                            .padding(.vertical, 4)
                        }
                        
                        Button {
                            withAnimation {
                                type = .pen
                                isDraw = true
                                selectedItem = 2
                                showStrokeWidthMenu.toggle()
                                AudioServicesPlaySystemSound(SystemSoundID(1105))
                                addHapticFeedbackWithStyle(style: .medium)
                            }
                        } label: {
                            Image(systemName: "pencil.tip")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.height * (UIDevice.current.userInterfaceIdiom == .pad ? 0.06 : 0.08),
                                       height: UIScreen.main.bounds.height * (UIDevice.current.userInterfaceIdiom == .pad ? 0.06 : 0.08))
                                .padding(8)
                                .scaleEffect(selectedItem == 2 ? 1.4 : 1.0)
                        }
                        .foregroundColor(selectedItem == 2 ? Color(red: 0.73, green: 0.65, blue: 1.00) : .white)
                        
                        if showStrokeWidthMenu && selectedItem == 2 {
                            VStack(spacing: 12) {
                                ForEach([4.0, 8.0, 12.0, 16.0], id: \.self) { width in
                                    Button {
                                        withAnimation {
                                            strokeWidth = width
                                            AudioServicesPlaySystemSound(SystemSoundID(1105))
                                            addHapticFeedbackWithStyle(style: .light)
                                        }
                                    } label: {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: width * 2, height: width * 2)
                                            .overlay(
                                                Circle()
                                                    .stroke(strokeWidth == width ? Color(red: 0.73, green: 0.65, blue: 1.00) : Color.clear, lineWidth: 2)
                                            )
                                    }
                                }
                            }
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.00)))
                            )
                            .padding(.vertical, 4)
                        }
                        
                        Button {
                            withAnimation {
                                isDraw = false
                                selectedItem = 3
                                showStrokeWidthMenu = false
                                AudioServicesPlaySystemSound(SystemSoundID(1105))
                                addHapticFeedbackWithStyle(style: .medium)
                            }
                        } label: {
                            Image("custom.eraser.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.height * (UIDevice.current.userInterfaceIdiom == .pad ? 0.06 : 0.08),
                                       height: UIScreen.main.bounds.height * (UIDevice.current.userInterfaceIdiom == .pad ? 0.06 : 0.08))
                                .padding(8)
                                .scaleEffect(selectedItem == 3 ? 1.4 : 1.0)
                        }
                        .foregroundColor(selectedItem == 3 ? Color(red: 0.73, green: 0.65, blue: 1.00) : .white)
                        
                        Button {
                            withAnimation {
                                undoManager?.undo()
                                selectedItem = 4
                                AudioServicesPlaySystemSound(SystemSoundID(1105))
                                addHapticFeedbackWithStyle(style: .medium)
                            }
                        } label: {
                            Image(systemName: "arrow.uturn.left")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.height * (UIDevice.current.userInterfaceIdiom == .pad ? 0.05 : 0.06),
                                       height: UIScreen.main.bounds.height * (UIDevice.current.userInterfaceIdiom == .pad ? 0.05 : 0.06))
                                .padding(8)
                                .scaleEffect(selectedItem == 4 ? 1.4 : 1.0)
                        }
                        .foregroundColor(selectedItem == 4 ? Color(red: 0.73, green: 0.65, blue: 1.00) : .white)
                        
                        Button {
                            withAnimation {
                                undoManager?.redo()
                                selectedItem = 5
                                AudioServicesPlaySystemSound(SystemSoundID(1105))
                                addHapticFeedbackWithStyle(style: .medium)
                            }
                        } label: {
                            Image(systemName: "arrow.uturn.right")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.height * (UIDevice.current.userInterfaceIdiom == .pad ? 0.06 : 0.06),
                                       height: UIScreen.main.bounds.height * (UIDevice.current.userInterfaceIdiom == .pad ? 0.06 : 0.06))
                                .padding(8)
                                .scaleEffect(selectedItem == 5 ? 1.4 : 1.0)
                        }
                        .foregroundColor(selectedItem == 5 ? Color(red: 0.73, green: 0.65, blue: 1.00) : .white)
                        
                        Button {
                            withAnimation {
                                selectedItem = 6
                                AudioServicesPlaySystemSound(SystemSoundID(1108))
                                saveDrawing()
                                addHapticFeedbackWithStyle(style: .medium)
                            }
                        } label: {
                            Image(systemName: "camera.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.height * (UIDevice.current.userInterfaceIdiom == .pad ? 0.06 : 0.08),
                                       height: UIScreen.main.bounds.height * (UIDevice.current.userInterfaceIdiom == .pad ? 0.06 : 0.08))
                                .padding(8)
                                .scaleEffect(selectedItem == 6 ? 1.4 : 1.0)
                        }
                        .foregroundColor(selectedItem == 6 ? Color(red: 0.73, green: 0.65, blue: 1.00) : .white)
                        
                        Button {
                            withAnimation {
                                canvas.drawing = PKDrawing()
                                selectedItem = 7
                                AudioServicesPlaySystemSound(SystemSoundID(1105))
                                addHapticFeedbackWithStyle(style: .medium)
                            }
                        } label: {
                            Image(systemName: "trash")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.height * (UIDevice.current.userInterfaceIdiom == .pad ? 0.06 : 0.08),
                                       height: UIScreen.main.bounds.height * (UIDevice.current.userInterfaceIdiom == .pad ? 0.06 : 0.08))
                                .padding(8)
                                .scaleEffect(selectedItem == 7 ? 1.4 : 1.0)
                        }
                        .foregroundColor(selectedItem == 7 ? Color(red: 0.73, green: 0.65, blue: 1.00) : .white)
                        
                        Button {
                            withAnimation {
                                selectedItem = 8
                                replayStrokes()
                                AudioServicesPlaySystemSound(SystemSoundID(1105))
                                addHapticFeedbackWithStyle(style: .medium)
                            }
                        } label: {
                            Image(systemName: "play.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.height * (UIDevice.current.userInterfaceIdiom == .pad ? 0.06 : 0.08),
                                       height: UIScreen.main.bounds.height * (UIDevice.current.userInterfaceIdiom == .pad ? 0.06 : 0.08))
                                .padding(8)
                                .scaleEffect(selectedItem == 8 ? 1.4 : 1.0)
                        }
                        .foregroundColor(selectedItem == 8 ? Color(red: 0.73, green: 0.65, blue: 1.00) : .white)
                    }
                    .padding(.vertical, 8)
                }
                .frame(width: UIScreen.main.bounds.height * 0.15, height: UIScreen.main.bounds.height * 0.65)
                .background(
                    RoundedRectangle(cornerRadius: UIScreen.main.bounds.height * 0.15 / 2)
                        .foregroundColor(Color(UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.00)))
                        .frame(width: UIScreen.main.bounds.height * 0.15, height: UIScreen.main.bounds.height * 0.65)
                )
                .padding()
                .padding(.top, 40) // Add padding to avoid overlap with left toolbar
                
                DrawingConfig(canvas: $canvas, isDraw: $isDraw, type: $type, color: $selctedColor, strokeWidth: $strokeWidth)
                    .cornerRadius(20)
                    .padding()
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let delta = value / lastScale
                                lastScale = value
                                scale = min(max(scale * delta, 0.5), 3.0)
                            }
                            .onEnded { _ in
                                lastScale = 1.0
                            }
                    ).zIndex(-10)
                
                VStack(alignment: .center) {
                    CColorPicker(selectedColor: $selctedColor)
                }
                .frame(width: UIScreen.main.bounds.height * 0.15, height: UIScreen.main.bounds.height * 0.8)
                .cornerRadius(UIScreen.main.bounds.height * 0.15 / 2)
                .background(
                    RoundedRectangle(cornerRadius: UIScreen.main.bounds.height * 0.15 / 2)
                        .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.12))
                        .frame(width: UIScreen.main.bounds.height * 0.15, height: UIScreen.main.bounds.height * 0.8)
                )
                .padding()
            }
            
            // Home button overlay at the top left corner
            VStack {
                HStack {
                    Button(action: {
                        addHapticFeedbackWithStyle(style: .medium)
                        AudioServicesPlaySystemSound(SystemSoundID(1105))
                        buttonScale = 0.5
                        withAnimation(.spring()) {
                            buttonScale = 1.4
                        }
                        withAnimation(.spring().delay(0.1)) {
                            buttonScale = 1.0
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                            presentationMode.wrappedValue.dismiss()
                        })
                    }) {
                        Image("button-home")
                            .resizable()
                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.height * 0.095 : UIScreen.main.bounds.height * 0.13,
                                   height: UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.height * 0.095 : UIScreen.main.bounds.height * 0.13)
                    }
                    .scaleEffect(buttonScale)
                    .padding(.leading, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 20) // Add padding to avoid overlap with left toolbar
                    .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 20)
                    
                    Spacer()
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    
    func addHapticFeedbackWithStyle(style : UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func saveDrawing() {
        // Get current user interface style from the active window
        let userInterfaceStyle: UIUserInterfaceStyle
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            userInterfaceStyle = window.traitCollection.userInterfaceStyle
        } else {
            // Fallback to system default
            userInterfaceStyle = UITraitCollection.current.userInterfaceStyle
        }
        
        // Determine background color based on current mode
        let backgroundColor: UIColor
        let drawingTrait: UITraitCollection
        
        switch userInterfaceStyle {
        case .dark:
            backgroundColor = .black
            drawingTrait = UITraitCollection(userInterfaceStyle: .dark)
        default:
            backgroundColor = .white
            drawingTrait = UITraitCollection(userInterfaceStyle: .light)
        }
        
        let scale = UIScreen.main.scale
        var bounds = canvas.drawing.bounds
        
        // If drawing bounds are empty, use canvas bounds as fallback
        if bounds.isEmpty || bounds.width == 0 || bounds.height == 0 {
            bounds = canvas.bounds
        }
        
        // Ensure we have a valid size
        if bounds.width <= 0 || bounds.height <= 0 {
            // If still invalid, use a default size
            bounds = CGRect(x: 0, y: 0, width: 1024, height: 1024)
        }
        
        let size = CGSize(width: bounds.width, height: bounds.height)
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            // Fill with background color matching current mode
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Draw the PKDrawing with the same trait collection to preserve appearance
            drawingTrait.performAsCurrent {
                let drawingImage = canvas.drawing.image(from: bounds, scale: scale)
                drawingImage.draw(at: .zero)
            }
        }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func createPath(for line: [CGPoint]) -> Path {
        var path = Path()
        if let firstPoint = line.first {
            //use scaling factor
            path.move(to:firstPoint)
        }
        if line.count > 2 {
            for index in 1..<line.count {
                let mid = calculateMidPoint(line[index - 1], line[index])
                path.addQuadCurve(to: mid, control: line[index - 1])
            }
        }
        if let last = line.last {
            path.addLine(to: last)
        }
        return path
    }
    
    func calculateMidPoint(_ point1: CGPoint, _ point2: CGPoint) -> CGPoint {
        let newMidPoint = CGPoint(x: (point1.x + point2.x)/2, y: (point1.y + point2.y)/2)
        return newMidPoint
    }
    
    func replayStrokes() {
        savedStrokes = canvas.drawing.strokes
        canvas.drawing = PKDrawing()
        
        guard !savedStrokes.isEmpty else { return }
        
        currentStrokeIndex = 0
        animationParametricValue = 0
        animationLastFrameTime = Date()
        
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60, repeats: true) { _ in
            self.stepAnimation()
        }
    }
    
    func stepAnimation() {
        guard currentStrokeIndex < savedStrokes.count else {
            animationTimer?.invalidate()
            return
        }
        
        let stroke = savedStrokes[currentStrokeIndex]
        let path = stroke.path
        let currentTime = Date()
        let delta = currentTime.timeIntervalSince(animationLastFrameTime)
        animationLastFrameTime = currentTime
        
        animationParametricValue = path.parametricValue(animationParametricValue, offsetBy: .time(delta))
        
        // Create a new path up to the current parametric value
        var newPathPoints: [PKStrokePoint] = []
        for i in 0..<Int(animationParametricValue) {
            if i < path.count {
                newPathPoints.append(path[i])
            }
        }
        
        let newStrokePath = PKStrokePath(controlPoints: newPathPoints, creationDate: path.creationDate)
        let newStroke = PKStroke(ink: stroke.ink, path: newStrokePath)
        
        // Update the drawing incrementally
        var currentDrawing = canvas.drawing
        if currentStrokeIndex < currentDrawing.strokes.count {
            currentDrawing.strokes[currentStrokeIndex] = newStroke
        } else {
            currentDrawing.strokes.append(newStroke)
        }
        canvas.drawing = currentDrawing
        
        // Move to the next stroke if the current one is fully drawn
        if animationParametricValue >= CGFloat(path.count - 1) {
            animationParametricValue = 0
            currentStrokeIndex += 1
        }
    }
}

struct PencilKitRepresentable : UIViewRepresentable {
    let canvas = PKCanvasView(frame: .init(x: 0, y: 0, width: 400, height: 80))
    func makeUIView(context: Context) -> PKCanvasView {
        return canvas
    }
    func updateUIView(_ uiView: PKCanvasView, context: Context) { }
}
