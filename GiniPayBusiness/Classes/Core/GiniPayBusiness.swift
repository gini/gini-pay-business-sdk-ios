//
//  GiniPayBusiness.swift
//  GiniPayBusiness
//
//  Created by Nadya Karaban on 18.02.21.
//

import Foundation
import GiniPayApiLib

public enum GiniPayBusinessError: Error {
    case noInstalledApps
    case apiError(GiniError)
}

@objc public final class GiniPayBusiness: NSObject {
    
    public var giniApiLib: GiniApiLib
    public var documentService: DefaultDocumentService
    public var paymentService: PaymentService
    private var bankProviders: [PaymentProvider] = []
    
    public init(with giniApiLib: GiniApiLib){
        self.giniApiLib = giniApiLib
        self.documentService = giniApiLib.documentService()
        self.paymentService = giniApiLib.paymentService()
    }
    
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
                            DispatchQueue.main.async {
                                completion(.success(self.bankProviders))
                            }
                        } else {
                            DispatchQueue.main.async {
                                completion(.failure(.noInstalledApps))
                            }
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
     
     - parameter completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case. In success case it includes array of payment providers, in case of failure error that there are no supported banking apps installed.
     
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
     Get extractions for the document.
     
     - parameter docId: id of the uploaded document.
     - parameter completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case. In success case it includes array of extractions, in case of failure in case of failure error from the server side.
     
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
                    completion(.failure(.apiError(error)))
                }
            }
        }
        
    /**
     Creates a payment request
     
     - parameter docId: id of the uploaded document.
     - parameter completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case. In success it includes id of the payment request, in case of failure error from the server side.
     
     */
    public func createPaymentRequest(paymentInfo: PaymentInfo, completion: @escaping (Result<String, GiniPayBusinessError>) -> Void) {
        paymentService.createPaymentRequest(sourceDocumentLocation: "", paymentProvider: paymentInfo.paymentProviderId, recipient: paymentInfo.recipient, iban: paymentInfo.iban, bic: "", amount: paymentInfo.amount, purpose: paymentInfo.purpose) { result in
            switch result {
            case let .success(requestID):
                self.openPaymentProviderApp(requestID: requestID, appScheme: paymentInfo.paymentProviderScheme)
            case let .failure(error):
                completion(.failure(.apiError(error)))
            }
        }
    }
    
    /**
     Opens an app of selected payment provider
     
     - parameter requestID: id of the created payment request.
     - parameter appScheme: app scheme for the selected payment provider
     
     */
    //ginipay-providername://payment?id=1
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
     Sets a data for review screen
     
     - parameter documentId: Id of uploaded document.
     - parameter completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case. In success it includes array of extractions,, in case of failure error from the server side.
     
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
                completion(.failure(.apiError(error)))
            }
        }
    }
}
