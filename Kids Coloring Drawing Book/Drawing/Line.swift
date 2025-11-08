import Foundation
import SwiftUI

struct Line: Identifiable {
    var points: [CGPoint]
    var linewidth: CGFloat
    var color: Color
    let id = UUID()
}
