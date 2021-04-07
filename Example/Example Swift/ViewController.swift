//
//  ViewController.swift
//  Example Swift
//
//  Created by Nadya Karaban on 26.03.21.
//

import UIKit
import GiniPayBusiness

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func showReviewScreen(_ sender: Any) {
        let vc = (UIStoryboard(name: "PaymentReview", bundle: giniPayBusinessBundle())
            .instantiateViewController(withIdentifier: "paymentReviewViewController") as? PaymentReviewViewController)!
        self.navigationController?.pushViewController(vc , animated: true)
    }
    
}

