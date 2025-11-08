//
//  HomeViewController.swift
//  coloringbook
//
//  Created by AMAN JAIN on 7/29/16.

import UIKit
import Lottie
import StoreKit
import PopupDialog

class HomeViewController: UIViewController {
    
    @IBOutlet weak var categoryMenuView: UIScrollView!
    @IBOutlet weak var menuBottom: NSLayoutConstraint!
    @IBOutlet weak var menuHeight: NSLayoutConstraint!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoBtn: UIButton!
    
    var selectedItem: CategoryItemView?
    var offsetX: CGFloat = 12
    var space: CGFloat = 12
    var pageVC: ManagePageViewController!
    var currentId: Int = 0
    var pendingId: Int = 0
    let collectionViewTopInset: CGFloat = 200
    let startColor = UIColor(hex: 0x39B68A)
    let endColor = UIColor(hex: 0xFFFFFF)
    var settingsBtnTapped = false
    
    var container = UIView()
    var loadingView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var animationView = AnimationView()
    var selectedCategory: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageVC = self.children.last as! ManagePageViewController
        pageVC.delegate = self
        
        let scrollView = pageVC.view.subviews.filter { $0 is UIScrollView }.first as! UIScrollView
        scrollView.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didSelectDrawing(_:)),
                                               name: NSNotification.Name(rawValue: "didSelectDrawingNotification"),
                                               object :nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didPurchasePack(_:)),
                                               name: NSNotification.Name(rawValue: "didPurchasePackNotification"),
                                               object :nil)
        createCategoryMenu()
        selectCategory(categoryNum: selectedCategory)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        categoryMenuView.contentSize = CGSize(width: offsetX, height: categoryMenuView.frame.height)
    }
    
    func createCategoryMenu() {
        if offsetX != space {
            offsetX = space
        }
    
        // Add menu item for each category from json data file
        for i in 0..<DataManager.sharedInstance.categoriesCount {
            addItemWithTitle(DataManager.sharedInstance.titleForCategory(index: i), index: i)
        }
        
        categoryMenuView.tag = -1
        categoryMenuView.showsHorizontalScrollIndicator = false
        categoryMenuView.contentSize = CGSize(width: offsetX, height: categoryMenuView.frame.height)
        categoryMenuView.layoutIfNeeded()
    }
    
    func addItemWithTitle(_ title: String, index: Int ) {
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(selectCategory(_:)))
        
        let categoryItem = CategoryItemView(title: title, index: index)
        categoryItem.tag = index
        categoryItem.translatesAutoresizingMaskIntoConstraints = false
        categoryItem.addGestureRecognizer(gesture)
        categoryMenuView.addSubview(categoryItem)
        
        // Add menu item constraints
        categoryItem.centerYAnchor.constraint(equalTo: categoryMenuView.centerYAnchor).isActive = true
        categoryItem.leadingAnchor.constraint(equalTo: categoryMenuView.leadingAnchor, constant: offsetX).isActive = true
        categoryItem.setNeedsLayout()
        categoryItem.layoutIfNeeded()
        
        // Increase x offset
        offsetX += categoryItem.bounds.width
        offsetX += space
    }
    
    func setupScroll(viewController: CollectionViewController) {
//        viewController.collectionView?.contentInset.top = collectionViewTopInset
//        if menuBottom.constant == menuHeight.constant {
//            viewController.collectionView?.contentOffset.y = -menuHeight.constant
//        } else {
//            viewController.collectionView?.contentOffset.y = -(viewController.collectionView?.contentInset.top)!
//        }
//        viewController.collectionView?.showsVerticalScrollIndicator = false
//        viewController.collectionView?.layoutIfNeeded()
//        viewController.collectionViewDidScroll = scroll
//        viewController.collectionViewWillEndDragging = endDragging
    }
    
    @objc func selectCategory(_ sender:UITapGestureRecognizer){
        // Load category for item index
        if let categoryItem = sender.view as? CategoryItemView {
            
            let direction = selectMenuItem(categoryItem)
            if let vc = pageVC.getVC(categoryItem.index) {
                pageVC.goToVC(vc, navigationDirection: direction)
                setupScroll(viewController: vc)
            }
            currentId = categoryItem.index
        }
    }
    
    func selectCategory(categoryNum: Int) {
         // Load first category
        if let vc = pageVC.getVC(categoryNum) {
            pageVC.goToVC(vc, navigationDirection: .forward)
            setupScroll(viewController: vc)
        }
    }
    
    func selectMenuItem(_ item: CategoryItemView) -> UIPageViewController.NavigationDirection {
        
        var previousIndex: Int = 0
        
        if let previousSelectedItem = selectedItem {
            previousSelectedItem.selected = false
            previousIndex = previousSelectedItem.index
        }
        selectedItem = item
        item.selected = true
        
        // Set menu content offset if item is out off screen
        if (item.frame.maxX + space) > (categoryMenuView.contentOffset.x + categoryMenuView.frame.width) {
            let contentOffset = CGPoint(x: (item.frame.maxX + space) - categoryMenuView.frame.width, y: 0)
            categoryMenuView.setContentOffset(contentOffset, animated: true)
        } else if (item.frame.minX - space) < categoryMenuView.contentOffset.x {
            let contentOffset = CGPoint(x: (item.frame.minX - space), y: 0)
            categoryMenuView.setContentOffset(contentOffset, animated: true)
        }
        
        return (previousIndex > selectedItem!.index ) ? .reverse : .forward
        
    }
    

    func scroll(scrollView: UIScrollView) {
        menuBottom.constant =  max(-scrollView.contentOffset.y, menuHeight.constant)
        let fraction = (scrollView.contentInset.top - menuBottom.constant) / (scrollView.contentInset.top - menuHeight.constant)
        coverView.alpha = fraction
        titleLabel.textColor = startColor.interpolateRGBColorTo(end: endColor, fraction: fraction)
        infoBtn.tintColor = titleLabel.textColor
        view.layoutIfNeeded()
    }
    
    func endDragging(scrollView: UIScrollView, velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if (targetContentOffset.pointee.y > -scrollView.contentInset.top && targetContentOffset.pointee.y < -menuHeight.constant) {
            
            if (velocity.y < 0) {
                targetContentOffset.pointee.y = -scrollView.contentInset.top
            } else if (velocity.y > 0) {
                targetContentOffset.pointee.y = -menuHeight.constant
            } else {
                if targetContentOffset.pointee.y > -scrollView.contentInset.top * 0.5 {
                    targetContentOffset.pointee.y = -menuHeight.constant
                } else {
                    targetContentOffset.pointee.y = -scrollView.contentInset.top
                }
            }
        }
    }
    
    @objc func didSelectDrawing(_ notification:Notification) -> Void {
        
        if let locked = notification.userInfo!["locked"] as? Bool, locked == true{
            showLockedPackAlert()
            return
        }
        if DataManager.sharedInstance.isOriginalImage() {
            gotoDrawing()
        } else {
            showImageOptionsAlert()
        }
    }
    
    @objc func didPurchasePack(_ notification:Notification) -> Void {
        // Reload images in current category
        if let vc = self.pageVC.viewControllers?[0] as? CollectionViewController {
            vc.collectionView?.reloadData()
        }
    }
    
    @IBAction func didTapHome(_ sender : UIButton) {
        sender.animateLabel()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.navigationController?.popViewController(animated: true)
        }
        SoundManager.shared.addHapticFeedbackWithStyle(style: .rigid)
        SoundManager.shared.playOnlyOnce(sound: .Tap)
        
        requestReview()
    }
    
    @available(macCatalyst 14.0, *)
    func requestReview() {
        if !ifAlreadyAskedReview {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
                ifAlreadyAskedReview = true
            } else {
                // Fallback for older versions or if windowScene is not available
                SKStoreReviewController.requestReview()
                ifAlreadyAskedReview = true
            }
        }
    }

    func gotoDrawing() {
        animationView.animation = Animation.named("Animation - 1726338514085")
        animationView.frame = view!.bounds
        animationView.tag = 81
        animationView.animationSpeed = 0.8
        animationView.backgroundColor = .white
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .playOnce
        animationView.play(fromProgress: 0,
                           toProgress: 1,
                           loopMode: LottieLoopMode.playOnce,
                           completion: { [weak self] (finished) in
                            if finished {
                                SettingsManager.sharedInstance.waitForTransition = true
                                self?.performSegue(withIdentifier: "ShowDrawingView", sender: self)
                                self?.removeSuccess()
                                
                            } else {
                                print("Animation cancelled")
                            }
        })
        view?.addSubview(animationView)
        
    }
    
    func removeSuccess() {
        if let viewLoading = self.view.viewWithTag(81) {
            UIView.animate(withDuration: 0.25, animations: {
                viewLoading.alpha = 0.0
            }, completion: { (_) in
                viewLoading.alpha = 1.0
                viewLoading.removeFromSuperview()
            })
        }
    }
    
    func showImageOptionsAlert() {
        
            // Prepare the popup
            let title = ""
            let message = ""
            let image = UIImage(named: "")
        let popup = PopupDialog(title: "", message: "🖍️🌈")
            popup.transitionStyle = .zoomIn
            popup.buttonAlignment = .vertical
            let dialogAppearance = PopupDialogDefaultView.appearance()
            dialogAppearance.titleFont  = UIFont(name: "FUTURA", size: 24)!
            dialogAppearance.messageFont  = UIFont(name: "FUTURA", size: 20)!
            dialogAppearance.messageColor = .gray
            
            let buttonAppearance = DefaultButton.appearance()
            buttonAppearance.titleFont      =  UIFont(name: "FUTURA", size: 22)!
            buttonAppearance.titleColor     = UIColor(red: 0.25, green: 0.53, blue: 0.91, alpha: 1)
            buttonAppearance.buttonColor    = .clear
            buttonAppearance.separatorColor = UIColor(white: 0.9, alpha: 1)
            
            
            let buttonOne = DefaultButton(title: "Continue") {
                self.gotoDrawing()
            }
            let buttonTwo = DefaultButton(title: "Start new") {
                DataManager.sharedInstance.deleteImage()
                self.gotoDrawing()
            }
            
            let buttonThree = DefaultButton(title: "Cancel") {
            
            }
            
            popup.addButtons([buttonOne, buttonTwo, buttonThree])
            self.present(popup, animated: true, completion: nil)
    }
}

extension HomeViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let pendingVC = pendingViewControllers[0] as? CollectionViewController {
            setupScroll(viewController: pendingVC)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished && completed {
            currentId = pendingId
        }
    }
    
}

extension HomeViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !pageVC.isTransitionCompleted { return }
        let percentComplete = (scrollView.contentOffset.x - view.frame.size.width)/view.frame.size.width
        if percentComplete >= 0.5 {
            if (pendingId != currentId + 1 && currentId < DataManager.sharedInstance.categoriesCount - 1) {
                pendingId = currentId + 1
                if let item = categoryMenuView.viewWithTag(pendingId) as? CategoryItemView {
                    _ = selectMenuItem(item)
                }
            }
        } else if percentComplete <= -0.5 {
            if (pendingId != currentId - 1 && currentId > 0) {
                pendingId = currentId - 1
                if let item = categoryMenuView.viewWithTag(pendingId) as? CategoryItemView {
                    _ = selectMenuItem(item)
                }
            }
        } else {
             if (pendingId != currentId) {
                pendingId = currentId
                if let item = categoryMenuView.viewWithTag(pendingId) as? CategoryItemView {
                    _ = selectMenuItem(item)
                }
            }
        }
    }
    
}

extension HomeViewController {
    
    func showLockedPackAlert() {
        
        let categoryIndex = DataManager.sharedInstance.selectedCategoryIndex
        let title = DataManager.sharedInstance.tileForProduct(index: categoryIndex)
        let message = DataManager.sharedInstance.descriptionForProduct(index: categoryIndex)
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        alertController.view.tintColor = UIColor(hex: 0x39B68A)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
//        let QuickPurchaseAction = UIAlertAction(title: "Quick purchase", style: .default) { [unowned self] (action) in
//            self.purchaseProduct()
//        }
     //   alertController.addAction(QuickPurchaseAction)
        
        let ViewShopAction = UIAlertAction(title: "View in shop", style: .default) { [unowned self] (action) in
            self.performSegue(withIdentifier: "ShowSettingsAndShop", sender: nil)
        }
        alertController.addAction(ViewShopAction)
        
        alertController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRect(origin: self.view.center, size: CGSize(width: 1, height: 1))
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showActivityIndicator() {
        container.frame = view.bounds
        container.center = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2)
        container.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = container.center
        loadingView.backgroundColor = UIColor(red: 57/255, green: 182/255, blue: 138/255, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.style = .whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2,
                                           y: loadingView.frame.size.height / 2)
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        view.addSubview(container)
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}



