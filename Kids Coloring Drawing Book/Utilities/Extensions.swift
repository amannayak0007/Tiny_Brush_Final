
import Foundation
import UIKit

extension UIView {
    
    func addShadow() {
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = .zero
        layer.shadowRadius = 3
        layer.masksToBounds = false
    }
    
    func animateLabel() {
        self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 4.0,
                       options: .allowUserInteraction,
                       animations: { [weak self] in
            self?.transform = .identity
        },
                       completion: nil)
    }
    
    
    func animateLabel1() {
        self.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 3.0,
                       options: .allowUserInteraction,
                       animations: { [weak self] in
            self?.transform = .identity
        },
                       completion: nil)
    }
}
