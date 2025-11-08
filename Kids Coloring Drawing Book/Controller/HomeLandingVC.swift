

import UIKit
import PopupDialog
import SwiftUI
import Lottie
import SpriteKit
import RevenueCat
import RevenueCatUI

class HomeLandingVC: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var bgImage: UIImageView!

    @IBOutlet private weak var drawingButton: UIButton!
    
    var isEnableAudio = true
    
    var interests = Categories.fetchHomeCategories()
    let cellScaling: CGFloat = 0.6
    var vc : UIViewController? = nil
    var animationView = AnimationView()
    private var hasSetInitialOffset = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize = UIScreen.main.bounds.size
        let cellWidth = floor(screenSize.width/2 * cellScaling + 10)
        let cellHeight = floor(screenSize.height * cellScaling + 80)
        
        let insetX = (view.bounds.width/2 - cellWidth) / 2.0
        let insetY = (view.bounds.height - cellHeight) / 4.0
        
        let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        collectionView?.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView.contentOffset.x = -20
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeLandingVC.purchasedSuccess(notification:)), name: Notification.Name("isPurchased"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeLandingVC.purchasedFailed(notification:)), name: Notification.Name("isFailed"), object: nil)
        
        let appDefaults: [String:Any] = ["SwitchStates" : isEnableAudio]
        defaults.register(defaults: appDefaults)
        isEnableAudio = defaults.bool(forKey: "SwitchStates")
        
        SoundManager.shared.play(sound: .BgSound, volume : 0.5)
        
        addParallaxToView(vw: bgImage)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeLandingVC.purchasedSuccess(notification:)), name: Notification.Name("isPurchased"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeLandingVC.purchasedFailed(notification:)), name: Notification.Name("isFailed"), object: nil)
        
        if ProcessInfo.processInfo.isMacCatalystApp == true {
            drawingButton.isHidden = true
        }
    }
    
    func stratAnimation() {
        
        animationView.animation = Animation.named("Animation - 1726338514085")
        animationView.frame = view!.bounds
        animationView.tag = 81
        animationView.animationSpeed = 0.8
        animationView.backgroundColor = .white
        animationView.contentMode = .scaleAspectFill

        view.addSubview(animationView)
    }
    
    @IBAction func didTapDoodle(_ sender: UIButton) {
        if (vc != nil){
            return
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if #available(iOS 18.0, *) {
                self.vc = self.storyboard?.instantiateViewController(withIdentifier: "\(DrawingViewController1.self)") as? DrawingViewController1
                self.navigationController?.pushViewController(self.vc ?? UIViewController(), animated: true)
            } else {
                let view = DrawingView0()
                let hostingController = UIHostingController(rootView: view)
                self.navigationController?.pushViewController(hostingController, animated: true)
            }
           
        } else {
            let view = DrawingView0()
            let hostingController = UIHostingController(rootView: view)
            self.navigationController?.pushViewController(hostingController, animated: true)
        }
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
    
    let showEmitterCell: CAEmitterCell = {
        let emitterCell = CAEmitterCell()
        emitterCell.contents = UIImage(named: "leaf1")?.cgImage
        emitterCell.scale = 0.09
        emitterCell.scaleRange = 0.6
        emitterCell.emissionRange = .pi
        emitterCell.lifetime = 20.0
        emitterCell.birthRate = 2
        emitterCell.velocity = -30
        emitterCell.velocityRange = -20
        emitterCell.yAcceleration = 30
        emitterCell.xAcceleration = 5
        emitterCell.spin = -0.5
        emitterCell.spinRange = 1.0
        return emitterCell
    }()
    
    lazy var snowEmitterLayer:CAEmitterLayer = {
        let emitterLayer =  CAEmitterLayer()
        emitterLayer.emitterPosition = CGPoint(x: view.bounds.width / 2.0, y: -50)
        emitterLayer.emitterSize = CGSize(width: view.bounds.width, height: 0)
        emitterLayer.emitterShape = CAEmitterLayerEmitterShape.cuboid
        emitterLayer.beginTime = CACurrentMediaTime()
        emitterLayer.timeOffset = 10
        emitterLayer.emitterCells = [self.showEmitterCell]
        
        return emitterLayer
    }()
    
    
    func addParallaxToView(vw: UIView) {
        let amount = 20
        
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount
        
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        vw.addMotionEffect(group)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Set the initial content offset only if it hasn't been set yet
            if !hasSetInitialOffset {
                // Set the initial content offset to show the first cell properly
                let initialOffsetX = -(collectionView?.contentInset.left ?? 0)
                let initialOffsetY = -(collectionView?.contentInset.top ?? 0)
                collectionView?.setContentOffset(CGPoint(x: initialOffsetX, y: initialOffsetY), animated: false)
                hasSetInitialOffset = true
            }
        
        
        if !SoundManager.shared.isPlaying(), isEnableAudio {
            SoundManager.shared.play(sound: .BgSound, volume : 0.5)
        }
        self.vc = nil
    }
    
    
    @IBAction func didTapSettings(_ sender : UIButton) {
        
        sender.animateLabel()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            HYParentalGate.sharedGate.show(successHandler: {
                let controller = PaywallViewController(displayCloseButton: UIDevice.current.userInterfaceIdiom == .pad ? true : true)
                controller.delegate = self
                self.present(controller, animated: true, completion: nil)
            }, cancelHandler: {
                print("parental gate dismissed")
            })
        }
        SoundManager.shared.addHapticFeedbackWithStyle(style: .rigid)
        SoundManager.shared.playOnlyOnce(sound: .Tap)
    }
    
}

extension HomeLandingVC : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return interests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(HomeLandingCollectionViewCell.self)", for: indexPath) as! HomeLandingCollectionViewCell
        cell.delegate = self
        cell.interest = interests[indexPath.item]
        if indexPath.row > 0 {
            let isPurchased = UserViewModel.shared.subscriptionActive
            cell.overLayView.isHidden = isPurchased
        }else{
            cell.overLayView.isHidden = true
        }
        return cell
    }
}

extension HomeLandingVC: HomeLandingCollectionViewCellDelegate {
    
    
    func didSelectLockedCell() {
        HYParentalGate.sharedGate.show(successHandler: { [weak self] in
            let controller = PaywallViewController(displayCloseButton: UIDevice.current.userInterfaceIdiom == .pad ? true : true)
            controller.delegate = self
            self?.present(controller, animated: true, completion: nil)
        }, cancelHandler: {
            print("parental gate dismissed")
        })
    }
    
    
    func didSelectCell(withCategory category: Categories) {
        
        stratAnimation()
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
        vc?.selectedCategory = category.categoryType.rawValue
        animationView.play(fromProgress: 0,
                           toProgress: 1,
                           loopMode: LottieLoopMode.playOnce,
                           completion: { [weak self] (finished) in
            if finished {
                self?.animationView.removeFromSuperview()
                self?.navigationController?.pushViewController(vc!, animated: true)
            } else {
                print("Animation cancelled")
            }
        })
        
        
    }
    
    
}

extension HomeLandingVC: PaywallViewControllerDelegate {
    
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

extension HomeLandingVC : UIScrollViewDelegate, UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        if offset.x > 0.0 {
            let parallaxFactor: CGFloat = 0.65
            let prallaxedOffset = offset.x * parallaxFactor
            let transform = CATransform3DTranslate(CATransform3DIdentity, -prallaxedOffset, 0, 0)
            bgImage.layer.transform = transform
        } else {
            bgImage.layer.transform = CATransform3DIdentity
        }
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
}

extension SKView {
    convenience init(withEmitter name: String) {
        self.init()
        
        self.frame = UIScreen.main.bounds
        backgroundColor = .clear
        
        let scene = SKScene(size: self.frame.size)
        scene.backgroundColor = .clear
        
        guard let emitter = SKEmitterNode(fileNamed: name + ".sks") else { return }
        emitter.name = name
        emitter.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        
        scene.addChild(emitter)
        presentScene(scene)
    }
}

extension UIFont {
    class func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        let font: UIFont
        
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: size)
        } else {
            font = systemFont
        }
        return font
    }
}
