//
//  CameraViewController.swift
//  Example Swift
//
//  Created by Nadya Karaban on 15.04.21.
//

import UIKit
import Photos
class CameraViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!

    var imagePicker: ImagePicker!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
    }

    @IBAction func showImagePicker(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
}

extension CameraViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        self.imageView.image = image
    }
}
