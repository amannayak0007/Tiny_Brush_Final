
import UIKit
import Lottie

class LoadingViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var animationView = AnimationView()
    var isFromLoadingView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stratAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isFromLoadingView = true
        SoundManager.shared.playOnlyOnce(sound: .Intro)
        animationView.play(fromProgress: 0,
                           toProgress: 1,
                           loopMode: LottieLoopMode.playOnce,
                           completion: { [weak self] (finished) in
            if finished {
                print("Animation Complete")
                let vc = self?.storyboard?.instantiateViewController(withIdentifier: "\(HomeLandingVC.self)") as? HomeLandingVC
                self?.navigationController?.pushViewController(vc!, animated: true)
            } else {
                print("Animation cancelled")
            }
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isFromLoadingView = false
    }
    
    func stratAnimation() {
        animationView.animation = Animation.named("Animation - 1706816622738")
        
        // Set the width and height to 0.25 of the screen dimensions
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let targetWidth = screenWidth * 0.85
        let targetHeight = screenHeight * 0.85
        
        // Calculate the centered origin
        let originX = (screenWidth - targetWidth) / 2
        let originY = (screenHeight - targetHeight) / 2
        
        // Set the frame
        animationView.frame = CGRect(x: originX, y: originY, width: targetWidth, height: targetHeight)
        
        animationView.contentMode = .scaleAspectFit
        animationView.animationSpeed = 0.8
        view.addSubview(animationView)
    }
}
