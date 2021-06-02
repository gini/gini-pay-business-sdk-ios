//
//  GiniPayBusiness.swift
//  GiniPayBusiness
//
//  Created by Nadya Karaban on 18.02.21.
//

import Foundation
import GiniPayApiLib

/**
 Errors thrown with GiniPayBusiness SDK.
 */
public enum GiniPayBusinessError: Error {
     /// Error thrown when there are no apps which supports Gini Pay installed.
    case noInstalledApps
     /// Error thrown when api return failure.
    case apiError(GiniError)
}
/**
 Data structure for Payment Review Screen initialization.
 */
public struct DataForReview {
    public let document: Document
    public let extractions: [Extraction]
    public init(document: Document, extractions: [Extraction]) {
        self.document = document
        self.extractions = extractions
    }
}
/**
 Core class for GiniPayBusiness SDK.
 */
@objc public final class GiniPayBusiness: NSObject {
    /// reponsible for interaction with Gini Pay backend .
    public var giniApiLib: GiniApiLib
    /// reponsible for the whole document processing.
    public var documentService: DefaultDocumentService
    /// reponsible for the payment processing.
    public var paymentService: PaymentService
    private var bankProviders: [PaymentProvider] = []
    
    /**
     Returns a GiniPayBusiness instance
     
     - parameter giniApiLib: GiniApiLib initialized with client's credentials
     */
    public init(with giniApiLib: GiniApiLib){
        self.giniApiLib = giniApiLib
        self.documentService = giniApiLib.documentService()
        self.paymentService = giniApiLib.paymentService()
    }
    /**
     Getting a list of the installed banking apps which support Gini Pay functionaly.
     
     - parameter completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case.
     Completion block called on main thread.
     In success case it includes array of payment providers, which are represebt the installed on the phone apps.
     In case of failure error that there are no supported banking apps installed.
     
     */
    private func getInstalledBankingApps(completion: @escaping (Result<PaymentProviders, GiniPayBusinessError>) -> Void){
        paymentService.paymentProviders { result in
            switch result {
            case let .success(providers):
                for provider in providers {
                    DispatchQueue.main.async {
                        if let url = URL(string:provider.appSchemeIOS) {
                            if UIApplication.shared.canOpenURL(url) {
                                self.bankProviders.append(provider)
                            }
                        }
                        if self.bankProviders.count > 0 {
                            completion(.success(self.bankProviders))
                        } else {
                            completion(.failure(.noInstalledApps))
                        }
                    }
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    completion(.failure(.apiError(error)))
                    
                }
            }
        }
    }

    /**
     Checks if there are any banking app which support Gini Pay functionaly installed.
     
     - parameter completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case.
     Completion block called on main thread.
     In success case it includes array of payment providers.
     In case of failure error that there are no supported banking apps installed.
     
     */
    public func checkIfAnyPaymentProviderAvailiable(completion: @escaping (Result<PaymentProviders, GiniPayBusinessError>) -> Void){
        self.getInstalledBankingApps(completion: completion)
    }
    
    /**
     Sets a configuration which is used to customize the look of the Gini Pay Business SDK,
     for example to change texts and colors displayed to the user.
     
     - parameter configuration: The configuration to set.
     
     */
    public func setConfiguration(_ configuration: GiniPayBusinessConfiguration) {
        GiniPayBusinessConfiguration.shared = configuration
    }
    
    /**
     Checks if the document is payable which looks for iban extraction.
     
     - parameter documentId: Id of uploaded document.

     */
    public func checkIfDocumentIsPayable(docId: String) -> Bool {
        var isIbanNotEmpty = false
        documentService.fetchDocument(with: docId) { result in
            switch result {
            case let .success(createdDocument):
                self.documentService.extractions(for: createdDocument,
                                                 cancellationToken: CancellationToken()) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case let .success(extractionResult):
                            if let iban = extractionResult.extractions.first(where: { $0.name == "iban" })?.value, !iban.isEmpty {
                                isIbanNotEmpty = true
                            }
                        case .failure:
                            break
                        }
                    }
                }
            case .failure:
                break
            }
        }
        return isIbanNotEmpty
    }
    
    /**
     Polls the document via document id.
     
     - parameter documentId: Id of uploaded document.
     - parameter completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case.
     Completion block called on main thread.
     In success returns the polled document.
     In case of failure error from the server side.

     */
    public func pollDocument(docId: String, completion: @escaping (Result<Document, GiniPayBusinessError>) -> Void){
        documentService.fetchDocument(with: docId) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(document):
                    completion(.success(document))
                case let .failure(error):
                    completion(.failure(.apiError(error)))
                }
            }
        }
    }
    
    /**
     Get extractions for the document.
     
     - parameter docId: id of the uploaded document.
     - parameter completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case.
     Completion block called on main thread.
     In success case it includes array of extractions.
     In case of failure in case of failure error from the server side.
     
     */
    public func getExtractions(docId: String, completion: @escaping (Result<[Extraction], GiniPayBusinessError>) -> Void){
            documentService.fetchDocument(with: docId) { result in
                switch result {
                case let .success(createdDocument):
                    self.documentService
                            .extractions(for: createdDocument,
                                         cancellationToken: CancellationToken()) { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case let .success(extractionResult):
                                        completion(.success(extractionResult.extractions))
                                    case let .failure(error):
                                        completion(.failure(.apiError(error)))
                                    }
                                }
                            }
                case let .failure(error):
                    DispatchQueue.main.async {
                        completion(.failure(.apiError(error)))
                    }
                }
            }
        }
        
    /**
     Creates a payment request
     
     - parameter docId: id of the uploaded document.
     - parameter completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case.
     Completion block called on main thread.
     In success it includes the id of created payment request.
     In case of failure error from the server side.
     
     */
    public func createPaymentRequest(paymentInfo: PaymentInfo, completion: @escaping (Result<String, GiniPayBusinessError>) -> Void) {
        paymentService.createPaymentRequest(sourceDocumentLocation: "", paymentProvider: paymentInfo.paymentProviderId, recipient: paymentInfo.recipient, iban: paymentInfo.iban, bic: "", amount: paymentInfo.amount, purpose: paymentInfo.purpose) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(requestID):
                    completion(.success(requestID))
                case let .failure(error):
                    completion(.failure(.apiError(error)))
                }
            }
        }
    }
    
    /**
     Opens an app of selected payment provider.
        openUrl called on main thread.
     
     - parameter requestID: id of the created payment request.
     - parameter appScheme: app scheme for the selected payment provider
     
     */
    public func openPaymentProviderApp(requestID: String, appScheme: String) {
        let queryItems = [URLQueryItem(name: "id", value: requestID)]
        let urlString = appScheme + "://payment"
        var urlComponents = URLComponents(string: urlString)!
        urlComponents.queryItems = queryItems
        let resultUrl = urlComponents.url!
        DispatchQueue.main.async {
            UIApplication.shared.open(resultUrl, options: [:], completionHandler: nil)
        }
    }
    
    /**
     Sets a data for payment review screen
     
     - parameter documentId: Id of uploaded document.
     - parameter completion: An action for processing asynchronous data received from the service with Result type as a paramater.
     Result is a value that represents either a success or a failure, including an associated value in each case.
     Completion block called on main thread.
     In success it includes array of extractions.
     In case of failure error from the server side.
     
     */
    public func setDocumentForReview(documentId: String, completion: @escaping (Result<[Extraction], GiniPayBusinessError>) -> Void) {
        documentService.fetchDocument(with: documentId) { result in
            switch result {
            case .success(let document):
                self.getExtractions(docId: document.id) { result in
                    switch result{
                    case .success(let extractions):
                        completion(.success(extractions))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(.apiError(error)))
                }
            }
        }
    }
    
    /**
     Fetches document and extractions for payment review screen

     - parameter documentId: Id of uploaded document.
     - parameter completion: An action for processing asynchronous data received from the service with Result type as a paramater.
     Result is a value that represents either a success or a failure, including an associated value in each case.
     Completion block called on main thread.
     In success returns DataForReview structure. It includes document and array of extractions.
     In case of failure error from the server side and nil instead of document .

     */
    public func fetchDataForReview(documentId: String, completion: @escaping (Result<DataForReview, GiniPayBusinessError>) -> Void) {
        documentService.fetchDocument(with: documentId) { result in
            switch result {
            case let .success(document):
                self.documentService
                    .extractions(for: document,
                                 cancellationToken: CancellationToken()) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case let .success(extractionResult):
                                let fetchedData = DataForReview(document: document, extractions: extractionResult.extractions)
                                completion(.success(fetchedData))
                            case let .failure(error):
                                completion(.failure(.apiError(error)))
                            }
                        }
                    }
            case let .failure(error):
                DispatchQueue.main.async {
                    completion(.failure(.apiError(error)))
                }
            }
        }
    }
}
