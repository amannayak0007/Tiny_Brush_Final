//
//  HomeLandingCollectionViewCell.swift
// Kids Coloring Drawing Game
//
//  Created by Aman Jain on 03/03/20.
//  Copyright © 2020 Aman Jain. All rights reserved.
//

import UIKit

protocol HomeLandingCollectionViewCellDelegate: AnyObject {
    func didSelectCell(withCategory category: Categories)
    func didSelectLockedCell()
}

class HomeLandingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var featuredImageView: UIImageView!
    @IBOutlet weak var overLayView: UIView!
    
    var interest: Categories? {
        didSet {
            self.updateUI()
        }
    }
    
    weak var delegate: HomeLandingCollectionViewCellDelegate?
    
    private func updateUI() {
        if let interest = interest {
            contentView.layer.cornerRadius = 60
            contentView.layer.borderWidth = 15
            contentView.layer.borderColor = UIColor.white.cgColor
            contentView.layer.masksToBounds = true
            contentView.backgroundColor = interest.color
            
            featuredImageView.image = interest.featuredImage
        } else {
            featuredImageView.image = nil
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 3.0
        layer.shadowRadius = 20
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 2, height: 10)
        self.clipsToBounds = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(
        withDuration: 0.3,
        delay: 0,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 0.9,
        options: [.allowUserInteraction, .beginFromCurrentState],
        animations: { self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)},
        completion: nil)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(
        withDuration: 0.5,
        delay: 0,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 0.9,
        options: [.allowUserInteraction, .beginFromCurrentState],
        animations: { self.transform = .identity },
        completion: { success in
            if let interest = self.interest {
                if self.overLayView.isHidden {
                    self.delegate?.didSelectCell(withCategory: interest)
                } else{
                    self.delegate?.didSelectLockedCell()
                }
            }
        })
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(
        withDuration: 0.8,
        delay: 0,
        usingSpringWithDamping: 0.4,
        initialSpringVelocity: 0.8,
        options: [.allowUserInteraction, .beginFromCurrentState],
        animations: { self.transform = .identity },
        completion: nil)
    }
        
}
