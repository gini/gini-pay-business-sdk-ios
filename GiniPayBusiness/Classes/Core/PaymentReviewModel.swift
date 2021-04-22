//
//  PaymentReviewModer.swift
//  GiniPayBusiness
//
//  Created by Nadya Karaban on 18.04.21.
//

import Foundation
import GiniPayApiLib
public class PaymentReviewModel: NSObject {
    private var apiLib: GiniApiLib

    public var onDocumentUpdated: () -> Void = {}
    public var onPaymentProvidersFetched: (_ provider: PaymentProviders) -> Void = { _ in }

    public var onExtractionFetched: () -> Void = {}
    public var onExtractionUpdated: () -> Void = {}
    public var onPreviewImagesFetched: () -> Void = {}
    public var reloadCollectionViewClosure: () -> Void = {}
    public var updateLoadingStatus: () -> Void = {}
    public var updateImagesLoadingStatus: () -> Void = {}

    
    public var onErrorHandling: (_ error: GiniPayBusinessError) -> Void = { _ in }

    public var onNoAppsErrorHandling: (_ error: GiniPayBusinessError) -> Void = { _ in }
    
    public var onCreatePaymentRequestErrorHandling: () -> Void = {}

    public var document: Document {
        didSet {
            self.onDocumentUpdated()
        }
    }

    public var providers: PaymentProviders = []

    public var extractions: [Extraction] {
        didSet {
            self.onExtractionFetched()
        }
    }

    public var documentId: String
    private var businessSDK: GiniPayBusiness

    private var cellViewModels: [PageCollectionCellViewModel] = [PageCollectionCellViewModel]() {
        didSet {
            self.reloadCollectionViewClosure()
        }
    }

    var numberOfCells: Int {
        return cellViewModels.count
    }

    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus()
        }
    }
    
    var isImagesLoading: Bool = false {
        didSet {
            self.updateImagesLoadingStatus()
        }
    }

    public init(with giniApiLib: GiniApiLib, document: Document, extractions: [Extraction]) {
        self.apiLib = giniApiLib
        self.businessSDK = GiniPayBusiness(with: self.apiLib)
        self.documentId = document.id
        self.document = document
        self.extractions = extractions
    }

    func getCellViewModel(at indexPath: IndexPath) -> PageCollectionCellViewModel {
        return cellViewModels[indexPath.section]
    }

    private func createCellViewModel(previewImage: UIImage) -> PageCollectionCellViewModel {
        return PageCollectionCellViewModel(preview: previewImage)
    }

    public func checkIfAnyPaymentProviderAvailiable() {
        businessSDK.checkIfAnyPaymentProviderAvailiable {[weak self] result in
            switch result {
            case let .success(providers):
                self?.onPaymentProvidersFetched(providers)
            case let .failure(error):
                self?.onNoAppsErrorHandling(error)
            }
        }
    }

    public func sendFeedback(updatedExtractions: [Extraction]) {
        businessSDK.documentService.submitFeedback(for: document, with: updatedExtractions) { result in
            switch result {
            case .success: break
            case .failure: break
            }
        }
    }

    public func createPaymentRequest(paymentInfo: PaymentInfo, completion: @escaping (Result<String, GiniPayBusinessError>) -> Void) {
        businessSDK.createPaymentRequest(paymentInfo: paymentInfo) {[weak self] result in
            switch result {
            case let .success(requestId):
                self?.businessSDK.openPaymentProviderApp(requestID: requestId, appScheme: paymentInfo.paymentProviderScheme)
            case let .failure(error):
                self?.onErrorHandling(error)
            }
        }
    }
    
    public func createPaymentRequest(paymentInfo: PaymentInfo){
        isLoading = true
        businessSDK.createPaymentRequest(paymentInfo: paymentInfo) {[weak self] result in
            switch result {
            case let .success(requestId):
                    self?.isLoading = false
                    self?.openPaymentProviderApp(requestId: requestId, appScheme: paymentInfo.paymentProviderScheme)
            case .failure(_ ):
                    self?.isLoading = false
                    self?.onCreatePaymentRequestErrorHandling()
            }
        }
    }

    public func openPaymentProviderApp(requestId: String, appScheme: String) {
        businessSDK.openPaymentProviderApp(requestID: requestId, appScheme: appScheme)
    }
    
    public func fetchImages() {
        self.isImagesLoading = true
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "imagesQueue")
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        var vms = [PageCollectionCellViewModel]()
        dispatchQueue.async {
            for page in 1 ... self.document.pageCount {
                dispatchGroup.enter()

                self.businessSDK.documentService.preview(for: self.documentId, pageNumber: page) {[weak self] result in
                    switch result {
                    case let .success(dataImage):
                        if let image = UIImage(data: dataImage), let cellModel = self?.createCellViewModel(previewImage: image) {
                            vms.append(cellModel)
                        }
                    case let .failure(error):
                        self?.onErrorHandling(.apiError(error))
                    }
                    dispatchSemaphore.signal()
                    dispatchGroup.leave()
                }
                dispatchSemaphore.wait()
            }

            dispatchGroup.notify(queue: dispatchQueue) {
                DispatchQueue.main.async {
                    self.isImagesLoading = false
                    self.cellViewModels.append(contentsOf: vms)
                    self.onPreviewImagesFetched()
                }
            }
        }
    }
}

public struct PageCollectionCellViewModel {
    let preview: UIImage
}
