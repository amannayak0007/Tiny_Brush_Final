//
//  IAPSubscriptionViewController.swift
//  IAP screen design
//
//  Created by Aman Jain on 18/06/23.
//

import UIKit

final class IAPSubscriptionViewController: UIViewController {

    @IBOutlet weak var monthlyView: UIView!
    @IBOutlet weak var yearlyView: UIView!
    @IBOutlet weak var upgradeButton: UIButton!
    
    @IBOutlet weak var monthlyTitle: UILabel!
    @IBOutlet weak var monthlySubtitle: UILabel!
    @IBOutlet weak var yearlyTitle: UILabel!
    @IBOutlet weak var yearlySubTitle: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
    }
    
    private func setupView() {
        monthlyView.layer.cornerRadius = 10
        monthlyView.backgroundColor =  UIColor(named: "iapButtonBgColor")

        yearlyView.layer.cornerRadius = 10
        yearlyView.layer.borderWidth = 2
        yearlyView.backgroundColor = .clear
        yearlyView.layer.borderColor = UIColor(named: "iapButtonBgColor")?.cgColor
        yearlyTitle.textColor = UIColor(named: "iapTextColor")
        yearlySubTitle.textColor = UIColor(named: "iapTextColor")
        
        upgradeButton.layer.cornerRadius = 10
        upgradeButton.backgroundColor = UIColor(named: "iapButtonBgColor")
    }
    
    
    @IBAction func didTapMonthlySubscription(_ sender: Any) {
        monthlyView.layer.cornerRadius = 10
        monthlyView.layer.borderWidth = 2
        monthlyView.backgroundColor = UIColor(named: "iapButtonBgColor")
        monthlyTitle.textColor = .white
        monthlySubtitle.textColor = .white
        
        yearlyView.layer.cornerRadius = 10
        yearlyView.layer.borderWidth = 2
        yearlyView.backgroundColor = .clear
        yearlyTitle.textColor = UIColor(named: "iapTextColor")
        yearlySubTitle.textColor = UIColor(named: "iapTextColor")
    }
    
    @IBAction func didTapYearlySubscription(_ sender: Any) {
        yearlyView.layer.cornerRadius = 10
        yearlyView.layer.borderWidth = 2
        yearlyView.backgroundColor = UIColor(named: "iapButtonBgColor")
        yearlyTitle.textColor = .white
        yearlySubTitle.textColor = .white
        
        monthlyView.layer.cornerRadius = 10
        monthlyView.layer.borderWidth = 2
        monthlyView.layer.borderColor = UIColor(named: "iapButtonBgColor")?.cgColor
        monthlyView.backgroundColor = .clear
        monthlyTitle.textColor = UIColor(named: "iapTextColor")
        monthlySubtitle.textColor = UIColor(named: "iapTextColor")
        
    }
    
    @IBAction func didTapUpgradeButton(_ sender: Any) {
    }
    
    @IBAction func didTapMayBeLater(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

