//
//  ScreenAPIViewController.swift
//  GiniCapture
//
//  Created by Peter Pult on 05/30/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import GiniCapture

protocol SelectAPIViewControllerDelegate: class {
    func selectAPI(viewController: SelectAPIViewController, didSelectApi api: GiniCaptureAPIType)
}

/**
 Integration options for Gini Capture SDK.
 */
enum GiniCaptureAPIType {
    case screen
    case component
}

/**
 View controller showing how to capture an image of a document using the Screen API of the Gini Capture SDK for iOS
 and how to process it using the Gini SDK for iOS.
 */
final class SelectAPIViewController: UIViewController {
    
    @IBOutlet weak var metaInformationButton: UIButton!
    
    weak var delegate: SelectAPIViewControllerDelegate?
        
    var clientId: String?
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let metaTitle = "Gini Capture SDK: (\(GiniCapture.versionString)) / Client id: \(self.clientId ?? "")"
        metaInformationButton.setTitle(metaTitle, for: .normal)
    }
    
    // MARK: User interaction

    @IBAction func launchComponentAPI(_ sender: Any) {
        delegate?.selectAPI(viewController: self, didSelectApi: .component)
    }
    
}
