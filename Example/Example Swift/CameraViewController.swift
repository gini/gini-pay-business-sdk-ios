//
//  CameraViewController.swift
//  Example Swift
//
//  Created by Nadya Karaban on 15.04.21.
//

import GiniPayApiLib
import GiniPayBusiness
import Photos
import UIKit

class CameraViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var apiLib: GiniApiLib!
    var imagePicker: ImagePicker!
    var businessSDK: GiniPayBusiness!

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        initializeSDK()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !businessSDK.checkIfAnyPaymentProviderAvailiable(){
            showError("", message: "Unfortunately, we didn't find any app which support Gini Pay")
        }
    }

    @IBAction func showImagePicker(_ sender: UIButton) {
        imagePicker.present(from: sender)
    }

    func initializeSDK() {
        let client = CredentialsManager.fetchClientFromBundle()
        apiLib = GiniApiLib.Builder(client: client).build()
        businessSDK = GiniPayBusiness(with: apiLib)
    }
}

extension CameraViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        imageView.image = image
    }
}


extension CameraViewController {
    func showError(_ title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }
}
