

import UIKit

class WSPalettePickerSwachCell: UICollectionViewCell {
    
    let circleLayer = CAShapeLayer()
    var color = UIColor.systemBlue {
        didSet{
            self.backgroundColor = color
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        let buttonWidth = self.frame.size.width
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: buttonWidth / 2,y: buttonWidth / 2), radius: 14, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.white.cgColor
        circleLayer.lineWidth = 4
        circleLayer.isHidden = true
        layer.addSublayer(circleLayer)
        layer.cornerRadius = self.frame.size.height/2
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            circleLayer.strokeColor = UIColor.white.cgColor
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            circleLayer.isHidden = !isSelected
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
        
}
