

import UIKit
import PopupDialog
import RevenueCatUI
import RevenueCat

class CollectionViewController: UICollectionViewController {
    
    fileprivate let reuseIdentifier = "PhotoCell"
    fileprivate var thumbnailSize:CGSize = CGSize.zero
    fileprivate let itemSpacing:CGFloat = 10
    fileprivate var freeImagesCount:Int = 0
    fileprivate var isPurchased:Bool = false
    var categoryIndex:Int = 0
    
    var collectionViewDidScroll:((UIScrollView)->Void)? = nil
    var collectionViewWillEndDragging:((UIScrollView, CGPoint, UnsafeMutablePointer<CGPoint>)->Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CollectionViewController.purchasedSuccess(notification:)), name: Notification.Name("isPurchased"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CollectionViewController.purchasedFailed(notification:)), name: Notification.Name("isFailed"), object: nil)
    }
    
    @objc private func purchasedSuccess(notification: NSNotification) {
        collectionView.reloadData()
        let alert = UIAlertController(title: NSLocalizedString("thank_You", comment: ""), message: NSLocalizedString("thank_you_message", comment: ""), preferredStyle: .alert)
        let OKAction = UIAlertAction(title: NSLocalizedString("ok_button_title", comment: ""), style: .default, handler: nil)
        alert.addAction(OKAction)
        dismiss(animated: false, completion: nil)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func purchasedFailed(notification: NSNotification) {
        dismiss(animated: false, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.reloadData()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension CollectionViewController: PaywallViewControllerDelegate {
    
    func paywallViewController(_ controller: PaywallViewController, didFinishPurchasingWith customerInfo: CustomerInfo) {
        collectionView.reloadData()
//        IAPManager.shared.purchasedSuccess()
        NotificationCenter.default.post(name: Notification.Name("isPurchased"), object: nil)
    }
    
    func paywallViewController(_ controller: PaywallViewController, didFinishRestoringWith customerInfo: CustomerInfo) {
        print("Restored: \(customerInfo)")
//        IAPManager.shared.purchasedSuccess()
        NotificationCenter.default.post(name: Notification.Name("isPurchased"), object: nil)
    }
    
    func paywallViewController(_ controller: PaywallViewController, didFailPurchasingWith error: NSError) {
        print("Error failed purchase: \(error)")
        NotificationCenter.default.post(name: Notification.Name("isFailed"), object: nil)
    }
    
    func paywallViewController(_ controller: PaywallViewController, didFailRestoringWith error: NSError) {
        print("Error failed restore purchase: \(error)")
        NotificationCenter.default.post(name: Notification.Name("isFailed"), object: nil)
    }
    
    func paywallViewControllerDidStartRestore(_ controller: PaywallViewController) {
        Purchases.shared.restorePurchases { customerInfo, error in
            // ... check customerInfo to see if entitlement is now active
            if customerInfo?.entitlements.active.isEmpty == true {
                let alert = UIAlertController(title: "Nothing to Restore", message: "There is nothing to restore.", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(OKAction)
                UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension CollectionViewController {

    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // Return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        freeImagesCount = DataManager.sharedInstance.freeImagesForProduct(index: self.categoryIndex)
        if Constants.packsPurchaseEnabled {
            isPurchased = UserDefaults.standard.bool(forKey: DataManager.sharedInstance.idForProduct(index: self.categoryIndex))
        } else {
            isPurchased = true
        }
        // Return the number of items
        return DataManager.sharedInstance.lengthForCategory(index: self.categoryIndex)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageIndex = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotoCell
        let image = DataManager.sharedInstance.getThumbAt(categoryIndex: self.categoryIndex, imageIndex: imageIndex)
        
        cell?.overLayView.layer.cornerRadius = 40
        cell?.imageView.image = image
        cell?.imageView.layer.cornerRadius = 40
        cell?.imageView.layer.masksToBounds = true
        
        if indexPath.row > 1 {
            let isPurchased = UserViewModel.shared.subscriptionActive
            cell?.overLayView.isHidden = isPurchased
        } else {
            cell?.overLayView.isHidden = true
        }
        
        // Adding blue border with rounded corners
        cell?.layer.borderColor = UIColor.randomFlatColor1().cgColor
        cell?.layer.borderWidth = 10
        cell?.layer.cornerRadius = 40 // Set this value to your desired border radius
        cell?.layer.masksToBounds = true // This ensures the corners are properly rounded
        
        cell?.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        cell?.layer.shadowOpacity = 0.5
        cell?.layer.shadowRadius = 40
        cell?.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell?.layer.shadowPath = UIBezierPath(roundedRect: cell?.bounds ?? CGRect.zero, cornerRadius: 40).cgPath
        
        return cell ?? UICollectionViewCell()
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        
        if cell.overLayView.isHidden {
            DataManager.sharedInstance.selectedCategoryIndex = self.categoryIndex
            DataManager.sharedInstance.selectedImageIndex = indexPath.row
            let dict = ["locked": false]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "didSelectDrawingNotification"), object: nil, userInfo: dict)
        } else{
            HYParentalGate.sharedGate.show(successHandler: { [weak self] in
                let controller = PaywallViewController(displayCloseButton: UIDevice.current.userInterfaceIdiom == .pad ? true : true)
                controller.delegate = self
                self?.present(controller, animated: true, completion: nil)
            }, cancelHandler: {
                print("parental gate dismissed")
            })
        }
        
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionViewDidScroll?(scrollView)
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        collectionViewWillEndDragging?(scrollView, velocity, targetContentOffset)
    }
    
}

extension CollectionViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Calculate thumbnail size based on device
        if traitCollection.userInterfaceIdiom == .pad {
            thumbnailSize.width = floor((collectionView.frame.size.width - itemSpacing) / 2.5)
        } else if traitCollection.userInterfaceIdiom == .phone {
            thumbnailSize.width = floor((collectionView.frame.size.width - itemSpacing * 2) / 3)
        }
        
        thumbnailSize.height = thumbnailSize.width
        
        return thumbnailSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: itemSpacing, left: itemSpacing, bottom: itemSpacing, right: itemSpacing)
    }
}
typealias ColorTuple = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)

extension UIColor {
    
    class func randomFlatColor1() -> UIColor {
        struct RandomColors {
            static let colors: Array<ColorTuple> = [
                
                //Colors
                (red:1.00, green:0.50, blue:0.50, alpha:1.0),
                (red:0.03, green:0.65, blue:0.62, alpha:1.0),
                (red:1.00, green:0.76, blue:0.57, alpha:1.0),
                (red:0.00, green:0.67, blue:1.00, alpha:1.0),
                (red:0.09, green:0.63, blue:0.53, alpha:1.0),
                (red:0.96, green:0.58, blue:0.40, alpha:1.0),
                (red:0.36, green:0.80, blue:0.94, alpha:1.0),
                (red:0.00, green:0.68, blue:0.85, alpha:1.0),
                (red:0.95, green:0.77, blue:0.06, alpha:1.0),
                (red:1.00, green:0.32, blue:0.63, alpha:1.0),
                (red:0.32, green:0.45, blue:1.00, alpha:1.0),
                (red:1.00, green:0.18, blue:0.51, alpha:1.0),
                (red:0.40, green:0.89, blue:0.22, alpha:1.0),
                (red:0.97, green:0.67, blue:0.04, alpha:1.0),
                (red:0.41, green:0.22, blue:0.73, alpha:1.0),
                (red:0.98, green:0.32, blue:0.32, alpha:1.0),
                (red:0.28, green:0.83, blue:0.71, alpha:1.0),
                (red:0.11, green:0.66, blue:0.96, alpha:1.0)
            ]
            
        }
        
        let colorCount = UInt32(RandomColors.colors.count)
        let randomIndex = arc4random_uniform(colorCount)
        let color = RandomColors.colors[Int(randomIndex)]
        
        return UIColor(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha)
    }
    
    class func randomFlatColor() -> UIColor {
        struct RandomColors {
            static let colors: Array<ColorTuple> = [
                
                //Colors
                (red:0.03, green:0.65, blue:0.62, alpha:1.0),
                (red:0.00, green:0.67, blue:1.00, alpha:1.0),
                (red:0.09, green:0.63, blue:0.53, alpha:1.0),
                (red:0.96, green:0.58, blue:0.40, alpha:1.0),
                (red:0.83, green:0.47, blue:0.91, alpha:1.0),
                (red:0.00, green:0.68, blue:0.85, alpha:1.0),
                (red:0.32, green:0.45, blue:1.00, alpha:1.0),
                (red:0.40, green:0.89, blue:0.22, alpha:1.0),
            ]
            
        }
        
        let colorCount = UInt32(RandomColors.colors.count)
        let randomIndex = arc4random_uniform(colorCount)
        let color = RandomColors.colors[Int(randomIndex)]
        
        return UIColor(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha)
    }
    
    static func randomColor(_ alpha: CGFloat) -> UIColor {
        let time = UInt32(NSDate().timeIntervalSinceReferenceDate)
        srand48(Int(time))
        let randomR:CGFloat = CGFloat(drand48())
        let randomG:CGFloat = CGFloat(drand48())
        let randomB:CGFloat = CGFloat(drand48())
        return UIColor(red: randomR, green: randomG, blue: randomB, alpha: alpha)
    }
    
    func adjust(_ red: CGFloat, green: CGFloat, blue: CGFloat, alpha:CGFloat) -> UIColor{
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: r+red, green: g+green, blue: b+blue, alpha: a+alpha)
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
}
