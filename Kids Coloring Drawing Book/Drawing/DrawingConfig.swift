import SwiftUI
import PencilKit

struct DrawingConfig: UIViewRepresentable {
    
    @Binding var canvas: PKCanvasView
    @Binding var isDraw: Bool
    @Binding var type: PKInkingTool.InkType
    @Binding var color: Color
    @Binding var strokeWidth: CGFloat
    
    // updating inkType
    var ink: PKInkingTool {
        PKInkingTool(type, color: UIColor(color), width: strokeWidth)
    }
    
    let eraser = PKEraserTool(.bitmap)
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.drawingPolicy = .anyInput
        canvas.tool = isDraw ? ink : eraser
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // updating tool whenever main View updates
        uiView.tool = isDraw ? ink : eraser
    }
}
