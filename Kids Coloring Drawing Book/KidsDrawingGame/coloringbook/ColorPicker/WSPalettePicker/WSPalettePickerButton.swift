import UIKit

@IBDesignable public class WSPalettePickerButton: UIButton {
    
    public weak var pickerDelegate: WSPalettePickerDelegate?
       public weak var pickerDataSource: WSPalettePickerDataSource?
       
       public var currentColor = UIColor.systemBlue {
           didSet {
               self.backgroundColor = currentColor
           }
       }
       
       let circleLayer = CAShapeLayer()
       

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    public override func prepareForInterfaceBuilder() {
        setup()
        super.prepareForInterfaceBuilder()
    }
    
    func setup() {
        // Add tap action
        self.addTarget(self, action: #selector(shouldPresent), for: .touchUpInside)
    }
    
    @objc func shouldPresent(sender: WSPalettePickerButton) {
        let controller = WSPalettePickerController()
        controller.sender = sender
        controller.delegate = pickerDelegate
        controller.dataSource = pickerDataSource
        
        controller.delegate?.palettePickerShouldPresent(pickerController: controller)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.height/2
        
        // Draw circle around the button
        let w = self.frame.size.width/2
        let circlePath = UIBezierPath(arcCenter: CGPoint(x:w, y:w), radius: w+2, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.label.cgColor
        circleLayer.lineWidth = 1
        layer.addSublayer(circleLayer)
    }
    
    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        circleLayer.strokeColor = UIColor.label.cgColor
    }
}
