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
    
    public var onErrorHandling: (_ error: GiniPayBusinessError) -> Void = { _ in }

    public var onNoAppsErrorHandling: (_ error: GiniPayBusinessError) -> Void = { _ in }

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

    public func setDocumentForReview(completion: @escaping (Result<[Extraction], GiniPayBusinessError>) -> Void) {
        businessSDK.documentService.fetchDocument(with: self.documentId) {[weak self] result in
            switch result {
            case let .success(document):
                self?.document = document
                self?.fetchExtractions(docId: document.id) {[weak self] result in
                    switch result {
                    case let .success(extractions):
                        completion(.success(extractions))
                    case let .failure(error):
                        self?.onErrorHandling(error)
                    }
                }
            case let .failure(error):
                self?.onErrorHandling(.apiError(error))
            }
        }
    }

    public func fetchExtractions(docId: String, completion: @escaping (Result<[Extraction], GiniPayBusinessError>) -> Void) {
        businessSDK.getExtractions(docId: docId) {[weak self] result in
            switch result {
            case let .success(extractions):
                completion(.success(extractions))
            case let .failure(error):
                self?.onErrorHandling(error)
            }
        }
    }

    public func checkIfAnyPaymentProviderAvailiable(completion: @escaping (Result<PaymentProviders, GiniPayBusinessError>) -> Void) {
        businessSDK.checkIfAnyPaymentProviderAvailiable {[weak self] result in
            switch result {
            case let .success(providers):
                self?.providers.append(contentsOf: providers)
                completion(.success(providers))
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

    public func openPaymentProviderApp(requestId: String, appScheme: String) {
        businessSDK.openPaymentProviderApp(requestID: requestId, appScheme: appScheme)
    }
    
    public func fetchImages() {
        self.isLoading = true
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
                    self.isLoading = false
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
