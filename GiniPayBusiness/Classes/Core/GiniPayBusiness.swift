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
    
    private func getInstalledBankingApps() -> [PaymentProvider] {
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
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
        return bankProviders
    }

    /**
     Checks if there are any banking app which support Gini Pay fuctionaly installed
     for example to change texts and colors displayed to the user.
     
     */
    public func checkIfAnyPaymentProviderAvailiable() -> Bool {
        let installedApps = getInstalledBankingApps()
        return installedApps.count > 0
    }
    
    /**
     Sets a configuration which is used to customize the look of the Gini Pay Business SDK,
     for example to change texts and colors displayed to the user.
     
     - parameter configuration: The configuration to set.
     */
    public func setConfiguration(_ configuration: GiniPayBusinessConfiguration) {
        GiniPayBusinessConfiguration.shared = configuration
    }
    
}

