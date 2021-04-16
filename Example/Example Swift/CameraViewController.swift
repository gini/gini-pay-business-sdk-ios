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
    var docId = ""
    var paymentProviders: PaymentProviders = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        initializeSDK()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        businessSDK.checkIfAnyPaymentProviderAvailiable {result in
            switch result {
            case let .success(providers):
                self.paymentProviders = providers
            case let .failure(error):
                self.showError(message: error.localizedDescription)
            }
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

    fileprivate func createCompositeDocument(createdDocument: Document, completion: @escaping (Result<String, GiniPayBusinessError>) -> Void) {
        let partialDocs = [PartialDocumentInfo(document: createdDocument.links.document)]
        self.businessSDK.documentService
            .createDocument(fileName: "ginipay-composite",
                            docType: nil,
                            type: .composite(CompositeDocumentInfo(partialDocuments: partialDocs)),
                            metadata: nil) { [weak self] result in
                guard self != nil else { return }
                switch result {
                case let .success(createdDocument):
                    completion(.success(createdDocument.id))
                    
                case let .failure(error):
                    completion(.failure(.apiError(error)))
                }
            }
    }
    
    func uploadDocument(documentData: Data, completion: @escaping (Result<String, GiniPayBusinessError>) -> Void) {
        businessSDK.documentService.createDocument(fileName: "ginipay-partial",
                                                   docType: nil,
                                                   type: .partial(documentData),
                                                   metadata: nil) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(createdDocument):
                DispatchQueue.main.async {
                    self.createCompositeDocument(createdDocument: createdDocument, completion: completion)
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    completion(.failure(.apiError(error)))
                }
            }
        }
    }
}

extension CameraViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        imageView.image = image
        guard let data = image?.jpegData(compressionQuality: 0.2) else { return }
        self.uploadDocument(documentData: data) { result in
            switch result {
            case .success(let documentId):
                self.docId = documentId
                print(String(documentId) + "upload")
            case .failure(let error):
                self.showError(message: error.localizedDescription)
            }
        }
    }
}
