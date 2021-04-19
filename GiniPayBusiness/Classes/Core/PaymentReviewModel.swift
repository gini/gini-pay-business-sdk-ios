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
    
    public var onDocumentUpdated: () -> () = {}
    public var onPaymentProvidersFetched: (_ provider: PaymentProviders) -> () = {_ in }

    public var onExtractionFetched: () -> () = {}
    public var onExtractionUpdated: () -> () = {}
    //public var onPreviewImagesFetched: () -> () = {}


    public var document: Document? {
        didSet {
            self.onDocumentUpdated()
        }
    }
    
    public var providers: PaymentProviders = []
    
//    public var previewImages: [Data] {
//        didSet {
//            self.onPreviewImagesFetched()
//        }
//    }
    
    public var extractions: [Extraction] {
        didSet {
            self.onExtractionFetched()
        }
    }
    
    public var documentId: String
    private var businessSDK: GiniPayBusiness

    
    public init(with giniApiLib: GiniApiLib, docId: String, extractions: [Extraction] ){
        self.apiLib = giniApiLib
        self.businessSDK = GiniPayBusiness.init(with: self.apiLib)
        self.documentId = docId
        self.extractions = extractions
    }
    
    public func setDocumentForReview(completion: @escaping (Result<[Extraction], GiniPayBusinessError>) -> Void) {
        businessSDK.documentService.fetchDocument(with: self.documentId) { result in
            switch result{
            case .success(let document):
                self.document = document
                self.fetchExtractions(docId: document.id) { result in
                    switch result{
                    case .success(let extractions):
                        completion(.success(extractions))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(.apiError(error)))
            }
        }
    }
    
    public func fetchExtractions(docId: String, completion: @escaping (Result<[Extraction], GiniPayBusinessError>) -> Void){
        businessSDK.getExtractions(docId: docId) { result in
            switch result{
            case .success(let extractions):
                completion(.success(extractions))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func checkIfAnyPaymentProviderAvailiable(completion: @escaping (Result<PaymentProviders, GiniPayBusinessError>) -> Void) {
        businessSDK.checkIfAnyPaymentProviderAvailiable { result in
            switch result {
            case .success(let providers):
                self.providers.append(contentsOf: providers)
                completion(.success(providers))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func sendFeedback(updatedExtractions: [Extraction]){
        businessSDK.documentService.submitFeedback(for: document!, with: updatedExtractions){ result in
            switch result {
            case .success( _): break
            case .failure( _): break
            }
        }
    }
    
    public func createPaymentRequest(paymentInfo: PaymentInfo, completion: @escaping (Result<String, GiniPayBusinessError>) -> Void) {
        businessSDK.createPaymentRequest(paymentInfo: paymentInfo) { result in
            switch result {
            case let .success(requestId):
                self.businessSDK.openPaymentProviderApp(requestID: requestId, appScheme: paymentInfo.paymentProviderScheme)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    public func openPaymentProviderApp(requestId: String, appScheme: String){
        businessSDK.openPaymentProviderApp(requestID: requestId, appScheme:appScheme)
    }
    
    public func fetchImages(completion: @escaping (Result< [Data], GiniPayBusinessError>) -> Void){
//        businessSDK.documentService.fetchDocument(with: self.documentId) { result in
//            switch result{
//            case .success(let document):
//                self.businessSDK.documentService.pagePreview(for: document, pageNumber: 1, size: Document.Page.Size.big) { result in
//                    switch result {
//                    case let .success(dataImage):
//                        completion(.success([dataImage]))
//                    case let .failure(error):
//                        completion(.failure(.apiError(error)))
//                    }
//                }
//            case .failure(let error):
//                completion(.failure(.apiError(error)))
//            }
//        }
        }

}
