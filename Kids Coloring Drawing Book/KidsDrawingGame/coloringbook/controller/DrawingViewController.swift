

import UIKit
import CoreImage
import AVFoundation
import Photos

class DrawingViewController: UIViewController, WSPalettePickerDelegate, WSPalettePickerDataSource {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var undoBtn:UIButton!
    @IBOutlet weak var redoBtn:UIButton!
    @IBOutlet weak var cameraButton:UIButton!
    @IBOutlet weak var stopView:MessageView!
    @IBOutlet weak var undoView:MessageView!
    @IBOutlet weak var redoView:MessageView!
    
    @IBOutlet weak var paintBrus:UIButton!
    @IBOutlet weak var paintBucket:UIButton!
    @IBOutlet weak var drawingToolBarView:UIView!
    
    @IBOutlet weak var pickerButton: WSPalettePickerButton!
    
    var palettesBtnTapped = false
    var selectedPaletteIdOnPopOver = 0
    
    var drawingView: DrawingView!
    var contentView: UIView!
    var contentViewTop: NSLayoutConstraint!
    var contentViewBottom: NSLayoutConstraint!
    var contentViewTrailing: NSLayoutConstraint!
    var contentViewLeading: NSLayoutConstraint!
    var lastZoomScale: CGFloat?
    var imageSize: CGSize!
    var imageScale: CGFloat!
    var thumbImageSize: CGSize!
    var thumbImageScale: CGFloat!
    var minZoomScale: CGFloat!
    var fitZoomScale: CGFloat!
    
    @IBOutlet var toolButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerButton.layer.borderWidth = 5
        pickerButton.layer.borderColor = UIColor.white.cgColor
        
        PalettesManager.sharedInstance.selectedPaletteId = 0
        PalettesManager.sharedInstance.selectedColorId = 0
        
        SoundManager.shared.play(sound: .storybg6, volume : 0.5)
       
        scrollView.delegate = self
        
        let smoothLinesImage = DataManager.sharedInstance.getSelectedImage()!
        imageSize = smoothLinesImage.size
        imageScale = smoothLinesImage.scale
        
        let borders = UIImageView(image: smoothLinesImage)
        drawingView = DrawingView(frame: borders.frame)
        drawingView.scrollView = scrollView
        DrawingManager.sharedInstance.selectedTool = .Pen
        drawingView.tool = DrawingManager.sharedInstance.selectedTool

        DrawingUndoManager.sharedInstance.reset()
        
        let saveSnapShot:((UIImage) -> Void) = {
            image in DrawingUndoManager.sharedInstance.saveSnapshot(image)
        }
        
        let showImage:(()->Void) = {
            [weak self] in self?.contentView.isHidden = false
        }
        
        drawingView.onImageDraw = saveSnapShot
        drawingView.onProcessComplete = showImage
        
        
        drawingView.loadImage(smoothLinesImage, savedImage: DataManager.sharedInstance.getSavedImage())
        
        contentView = UIView(frame: drawingView.frame)
        contentView.backgroundColor = UIColor.red
        contentView.addSubview(drawingView)
        contentView.addSubview(borders)
        contentView.isHidden = true
        
        
        contentView.widthAnchor.constraint(equalToConstant: imageSize.width).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: imageSize.height).isActive = true
        
        scrollView.addSubview(contentView)
        scrollView.contentSize = contentView.frame.size
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 1
        
        if SettingsManager.sharedInstance.undoSwipe {
            let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(_:)))
            leftSwipe.direction = .left
            leftSwipe.numberOfTouchesRequired = 2
            scrollView.addGestureRecognizer(leftSwipe)
            
            let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(_:)))
            rightSwipe.direction = .right
            rightSwipe.numberOfTouchesRequired = 2
            scrollView.addGestureRecognizer(rightSwipe)
            
            scrollView.panGestureRecognizer.require(toFail: leftSwipe)
            scrollView.panGestureRecognizer.require(toFail: rightSwipe)
            scrollView.pinchGestureRecognizer?.require(toFail: leftSwipe)
            scrollView.pinchGestureRecognizer?.require(toFail: rightSwipe)
        }
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentViewTop = contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0)
        contentViewTop.isActive = true
        contentViewBottom = contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0)
        contentViewBottom.isActive = true
        contentViewLeading = contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0)
        contentViewLeading.isActive = true
        contentViewTrailing = contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0)
        contentViewTrailing.isActive = true
        
        // Set the delegate for the button itself
        pickerButton.pickerDelegate = self
        pickerButton.pickerDataSource = self
        pickerButton.currentColor = UIColor(red: 0.976, green: 0.831, blue: 0.0, alpha: 1.0)
        DrawingManager.sharedInstance.selectedColor = pickerButton.currentColor
        
        
        drawingView.layer.cornerRadius = 120
        contentView.backgroundColor = .clear
        
        
        for toolButtons in toolButtons {
            toolButtons.contentHorizontalAlignment = .fill
            toolButtons.contentVerticalAlignment = .fill
            toolButtons.imageView?.contentMode = .scaleAspectFit
        }
        
        drawingToolBarView.layer.cornerRadius = 18.0
        drawingToolBarView.layer.borderWidth = 8
        drawingToolBarView.layer.borderColor = UIColor.white.cgColor
        
        if ProcessInfo.processInfo.isMacCatalystApp == true {
            cameraButton.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SoundManager.shared.stopSound()
    }
     
    // MARK: Palette Data Source
    
    // MARK: Palette Data Source
    func palettePickerColors(pickerController: WSPalettePickerController) -> [UIColor] {
        return [
            UIColor(red: 0.9827967286, green: 0.2422868609, blue: 0.304597497, alpha: 1),
            UIColor(red: 1, green: 0.9176470588, blue: 0.1294117647, alpha: 1),
            UIColor(red: 0.3658626974, green: 0.4213269651, blue: 0.9910128713, alpha: 1),
            UIColor(red: 0.7058823529, green: 0.9607843137, blue: 0.007843137255, alpha: 1),
            UIColor(red: 0.9976219535, green: 0.493891716, blue: 0.1634469032, alpha: 1),
            UIColor(red: 0.9960784314, green: 0.5647058824, blue: 0.6941176471, alpha: 1),
            UIColor(red: 0.9137254902, green: 0.631372549, blue: 0.4705882353, alpha: 1),
            UIColor(red: 0.4274509804, green: 0.4039215686, blue: 0.8941176471, alpha: 1),
            UIColor(red: 0.01082013734, green: 0.5376695395, blue: 0.6011897922, alpha: 1),
            UIColor(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1),
            UIColor(red: 0.1380527318, green: 0.8117864728, blue: 0.9663870931, alpha: 1),
            UIColor(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1),
            UIColor(red: 1, green: 0.4117647059, blue: 0.4117647059, alpha: 1),
            UIColor(red: 1, green: 0.7921568627, blue: 0.5647058824, alpha: 1),
            UIColor(red: 0.192, green: 0.451, blue: 0.149, alpha: 1.0),
            UIColor(red: 0, green: 0, blue: 0, alpha: 1),
            UIColor(red: 0.976, green: 0.831, blue: 0.0, alpha: 1.0),
            UIColor(red: 0.7843137255, green: 0.7176470588, blue: 0.6509803922, alpha: 1),
            UIColor(red: 0.9176470588, green: 0.5568627451, blue: 0.9176470588, alpha: 1),
            UIColor(red: 0.8, green: 0.9137254902, blue: 0.5647058824, alpha: 1),
            UIColor(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1),
            UIColor(red: 0.5215686275, green: 0.4666666667, blue: 0.3607843137, alpha: 1),
            UIColor(red: 0.9019607843, green: 0.8196078431, blue: 0.9803921569, alpha: 1),
            UIColor(red: 0.9960784314, green: 1, blue: 0.5254901961, alpha: 1),
            UIColor(red: 0.262745098, green: 0.1725490196, blue: 0.4784313725, alpha: 1),
            UIColor(red: 0.6509803922, green: 0.368627451, blue: 0.3647058824, alpha: 1),
            UIColor(red: 1, green: 0.6470588235, blue: 0.3490196078, alpha: 1),
            UIColor(red: 0.6587355733, green: 0.8163673282, blue: 0.5126903653, alpha: 1),
            UIColor(red: 0.9525182843, green: 0.628824532, blue: 0.8127143383, alpha: 1),
            UIColor(red: 0.322, green: 0.227, blue: 0.212, alpha: 1.0),
            UIColor(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1),
            UIColor(red: 1, green: 1, blue: 1, alpha: 1),
            UIColor(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1),
            UIColor(red: 0.8352941176, green: 0.7058823529, blue: 0.7058823529, alpha: 1),
            UIColor(red: 0.9624045491, green: 0.8834995031, blue: 0.6421941519, alpha: 1),
            UIColor(red: 0.6862079501, green: 0.5064355135, blue: 0.8446342349, alpha: 1),
            UIColor(red: 0.4, green: 0.8, blue: 0.6, alpha: 1), // Mint green
            UIColor(red: 0.8, green: 0.4, blue: 0.6, alpha: 1), // Raspberry
            UIColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 1), // Lavender
            UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1), // Sunflower yellow
            UIColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 1), // Sky blue
            UIColor(red: 0.8, green: 0.6, blue: 0.2, alpha: 1), // Goldenrod
            UIColor(red: 0.4, green: 0.2, blue: 0.6, alpha: 1), // Deep purple
            UIColor(red: 0.6, green: 0.8, blue: 0.4, alpha: 1), // Lime green
            UIColor(red: 1.0, green: 0.6, blue: 0.8, alpha: 1), // Bubblegum pink
            UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1)  // Emerald green
        ]
    }
    
    // MARK: Palette Delegate
    
    func palettePickerShouldPresent(pickerController: WSPalettePickerController) {
        self.present(pickerController, animated: true)
        SoundManager.shared.addHapticFeedbackWithStyle(style: .rigid)
        SoundManager.shared.playOnlyOnce(sound: .Tap)
    }
    
    func pickerDidSelect(color: UIColor) {
        print("Selected \(color)")
        paintBrus.tintColor = color
        paintBucket.tintColor = color
        DrawingManager.sharedInstance.selectedColor = color
        SoundManager.shared.addHapticFeedbackWithStyle(style: .rigid)
        SoundManager.shared.playOnlyOnce(sound: .Tap)
    }
    
    
    deinit {
        //print("DrawingVC deinit")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateZoom()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SettingsManager.sharedInstance.waitForTransition = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func playUndoRedoSound() {
        if SettingsManager.sharedInstance.soundEffects, let url = Bundle.main.url(forResource: "undo", withExtension: "aiff") {
            let player = AudioPlayer.playerWithURL(url)
            player?.play()
        }
    }
    
    func playNoUndoRedoSound() {
        if SettingsManager.sharedInstance.soundEffects, let url = Bundle.main.url(forResource: "wrong", withExtension: "aiff") {
            let player = AudioPlayer.playerWithURL(url)
            player?.play()
        }
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .right) {
            if DrawingUndoManager.sharedInstance.hasRedo() {
                guard let image = DrawingUndoManager.sharedInstance.redo() else { return }
                playUndoRedoSound()
//                view.bringSubview(toFront: redoView)
                view.bringSubviewToFront(redoView)
                redoView.fadeOut()
                drawingView.updateImage(image)
            } else {
                playNoUndoRedoSound()
//                view.bringSubview(toFront: stopView)
                view.bringSubviewToFront(stopView)
                stopView.fadeOut()
            }
        } else if (sender.direction == .left) {
            if DrawingUndoManager.sharedInstance.hasUndo() {
                guard let image = DrawingUndoManager.sharedInstance.undo() else { return }
                playUndoRedoSound()
//                view.bringSubview(toFront: undoView)
                view.bringSubviewToFront(undoView)
                undoView.fadeOut()
                drawingView.updateImage(image)
            } else {
                playNoUndoRedoSound()
//                view.bringSubview(toFront: stopView)
                view.bringSubviewToFront(stopView)
                stopView.fadeOut()
            }
            
        }
    }
    
    
    @IBAction func undo(_ sender: AnyObject) {
        guard let image = DrawingUndoManager.sharedInstance.undo() else { return }
        SoundManager.shared.playOnlyOnce(sound: .Tap)
        playUndoRedoSound()
        drawingView.updateImage(image)
    }
    
    @IBAction func redo(_ sender: AnyObject) {
        guard let image = DrawingUndoManager.sharedInstance.redo() else { return }
        playUndoRedoSound()
        drawingView.updateImage(image)
    }
    
    func updateConstraints() {
        let viewWidth = scrollView.bounds.size.width
        let viewHeight = scrollView.bounds.size.height
        
        // Center image if it is smaller than the scroll view
        let xOffset = max(0, (viewWidth - scrollView.zoomScale * imageSize.width) * 0.5)
        let yOffset = max(0, (viewHeight - scrollView.zoomScale * imageSize.height) * 0.5)
        
        contentViewTop.constant = yOffset
        contentViewBottom.constant = yOffset
        contentViewTrailing.constant = xOffset
        contentViewLeading.constant = xOffset
        
        view.layoutIfNeeded()
    }
    
    private func updateZoom() {
        let widthScale = scrollView.bounds.size.width / imageSize.width
        let heightScale = scrollView.bounds.size.height / imageSize.height
        
        fitZoomScale = min(widthScale, heightScale)
        minZoomScale = fitZoomScale * 0.5
        
        scrollView.maximumZoomScale = 6
        scrollView.minimumZoomScale = minZoomScale
        
        if let lastScale = lastZoomScale {
            if lastScale < minZoomScale {
                scrollView.zoomScale = minZoomScale
            } else {
                scrollView.zoomScale = lastScale
            }
            
            if scrollView.zoomScale > fitZoomScale {
                scrollView.minimumZoomScale = fitZoomScale
            }
            
        } else {
            scrollView.zoomScale = fitZoomScale
        }
        
        lastZoomScale = scrollView.zoomScale
        updateConstraints()
    }
 
    @IBAction func didTapFill(_ sender: AnyObject) {
        scrollView?.isScrollEnabled  = true
        scrollView?.pinchGestureRecognizer?.isEnabled = true
        scrollView?.panGestureRecognizer.isEnabled = true
        
        DrawingManager.sharedInstance.selectedTool = .Fill
        drawingView.tool = DrawingManager.sharedInstance.selectedTool
        SoundManager.shared.addHapticFeedbackWithStyle(style: .rigid)
        SoundManager.shared.playOnlyOnce(sound: .Tap)
//        paintBrus.alpha = 1.0
//        paintBucket.alpha = 0.7
        

        // Scale up the button
          UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
              self.paintBrus.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
          }, completion: nil)
        
        // Scale up the button
          UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
              self.paintBucket.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
          }, completion: nil)
    }
    
    @IBAction func didTappen(_ sender: AnyObject) {
        scrollView?.isScrollEnabled  = false
        DrawingManager.sharedInstance.selectedTool = .Pen
        drawingView.tool = DrawingManager.sharedInstance.selectedTool
        SoundManager.shared.addHapticFeedbackWithStyle(style: .rigid)
        SoundManager.shared.playOnlyOnce(sound: .Tap)
//        paintBrus.alpha = 0.7
//        paintBucket.alpha = 1.0
        
        // Scale up the button
          UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
              self.paintBrus.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
          }, completion: nil)
        
        // Scale up the button
          UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
              self.paintBucket.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
          }, completion: nil)
    }
    
    @IBAction func backToGallery(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        sender.animateLabel()
        if let navController = self.navigationController {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                if navController.viewControllers.index(of: self)! > 0 {
                    navController.popViewController(animated: true)
                } else {
                    navController.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
        SoundManager.shared.addHapticFeedbackWithStyle(style: .medium)
        SoundManager.shared.playOnlyOnce(sound: .Tap)
        
        // Save current drawing for later use
        guard drawingView.isChanged() else { return }
        UIGraphicsBeginImageContextWithOptions(imageSize, true, imageScale)
        drawingView.layer.render(in: UIGraphicsGetCurrentContext()!)
        DataManager.sharedInstance.saveImage(UIGraphicsGetImageFromCurrentImageContext()!)
        UIGraphicsEndImageContext()
    }
    
    @IBAction func saveToGallery(_ sender: UIButton) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            if let wnd = self.view {
                let v = UIView(frame: wnd.bounds)
                v.backgroundColor = UIColor.white
                v.alpha = 1

                wnd.addSubview(v)
                UIView.animate(withDuration: 1, animations: {
                    v.alpha = 0.0
                }, completion: { (finished: Bool) in
                    v.removeFromSuperview()
                })
            }

            AudioServicesPlaySystemSound(SystemSoundID(1108))
            UIGraphicsBeginImageContextWithOptions(imageSize, true, imageScale)
            contentView.layer.render(in: UIGraphicsGetCurrentContext()!)
            UIImageWriteToSavedPhotosAlbum(UIGraphicsGetImageFromCurrentImageContext()!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            
            
        } else if status == .denied || status == .restricted {
            showPermissionDeniedAlert()
        } else if status == .notDetermined {
            HYParentalGate.sharedGate.show(successHandler: { [weak self] in
                guard let self = self else { return }
                UIGraphicsBeginImageContextWithOptions(self.imageSize, true, self.imageScale)
                self.contentView.layer.render(in: UIGraphicsGetCurrentContext()!)
                UIImageWriteToSavedPhotosAlbum(UIGraphicsGetImageFromCurrentImageContext()!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)

            }, cancelHandler: {
                print("Parental gate dismissed")
            })
        }
    }

    // Function to show permission denied alert
    func showPermissionDeniedAlert() {
        let alert = UIAlertController(title: "Permission Denied", message: "Image save permission is not granted.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let _ = error {
            showPermissionDeniedAlert()
        } else {
            if let wnd = self.view {
                let v = UIView(frame: wnd.bounds)
                v.backgroundColor = UIColor.white
                v.alpha = 1

                wnd.addSubview(v)
                UIView.animate(withDuration: 1, animations: {
                    v.alpha = 0.0
                }, completion: { (finished: Bool) in
                    v.removeFromSuperview()
                })
            }

            AudioServicesPlaySystemSound(SystemSoundID(1108))
        }
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

}

extension DrawingViewController:UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        if DrawingManager.sharedInstance.selectedTool == .Pen {
            scrollView.isScrollEnabled = true
        } else {
            scrollView.isScrollEnabled = true
        }
    }
    
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if DrawingManager.sharedInstance.selectedTool == .Pen {
            scrollView.isScrollEnabled = false
        } else {
            scrollView.isScrollEnabled = true
        }
        lastZoomScale = scrollView.zoomScale
        updateConstraints()
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if DrawingManager.sharedInstance.selectedTool == .Pen {
            scrollView.isScrollEnabled = false
        }
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // Update min zoom scale (2 steps zooming)
        if scrollView.zoomScale > fitZoomScale {
            scrollView.minimumZoomScale = fitZoomScale
        } else {
            scrollView.minimumZoomScale = minZoomScale
        }
    }
}

extension DrawingViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}
