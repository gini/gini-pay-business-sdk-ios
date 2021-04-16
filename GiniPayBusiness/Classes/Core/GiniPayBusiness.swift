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
        self.paymentService.paymentProviders { result in
            switch result {
            case let .success(providers):
                for provider in providers {
                    DispatchQueue.main.async {
                        if let url = URL(string: provider.appSchemeIOS) {
                            if UIApplication.shared.canOpenURL(url) {
                                self.bankProviders.append(provider)
                            }
                        }
                    }
                }
                completion(.success(self.bankProviders))
            case let .failure(error):
                completion(.failure(.apiError(error)))
            }
        }
    }

    /**
     Checks if there are any banking app which support Gini Pay fuctionaly installed
     for example to change texts and colors displayed to the user.
     
     */
    public func checkIfAnyPaymentProviderAvailiable(completion: @escaping (Result<PaymentProviders, GiniPayBusinessError>) -> Void){
        getInstalledBankingApps(completion: completion)
    }
    
    /**
     Sets a configuration which is used to customize the look of the Gini Pay Business SDK,
     for example to change texts and colors displayed to the user.
     
     - parameter configuration: The configuration to set.
     */
    public func setConfiguration(_ configuration: GiniPayBusinessConfiguration) {
        GiniPayBusinessConfiguration.shared = configuration
    }
    
    public func getExtractions(docID: String, completion: @escaping (Result<[Extraction], GiniPayBusinessError>) -> Void){
            documentService.fetchDocument(with: docID) { result in
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
        
        
    public func createPaymentRequest(paymentInfo: PaymentInfo, completion: @escaping (Result<String, GiniPayBusinessError>) -> Void) {
        let selectedPaymentProvider = self.bankProviders[0]
        paymentService.createPaymentRequest(sourceDocumentLocation: "", paymentProvider: selectedPaymentProvider.id, recipient: paymentInfo.recipient, iban: paymentInfo.iban, bic: "", amount: paymentInfo.amount, purpose: paymentInfo.purpose) { result in
            switch result {
            case let .success(requestID):
                completion(.success(requestID))
            case let .failure(error):
                completion(.failure(.apiError(error)))
            }
        }
    }
        
}

