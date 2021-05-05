//
//  AppCoordinator.swift
//  GiniCapture_Example
//
//  Created by Enrique del Pozo Gómez on 11/10/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit
import GiniCapture
import GiniPayApiLib

final class AppCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    fileprivate let window: UIWindow
    fileprivate var screenAPIViewController: UIViewController?
    var rootViewController: UIViewController {
        return selectAPIViewController
    }
    lazy var selectAPIViewController: SelectAPIViewController = {
        let selectAPIViewController = (UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "selectAPIViewController") as? SelectAPIViewController)!
        selectAPIViewController.delegate = self
        selectAPIViewController.clientId = self.client.id
        return selectAPIViewController
    }()
    
    lazy var giniConfiguration: GiniConfiguration = {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.debugModeOn = true
        giniConfiguration.fileImportSupportedTypes = .pdf_and_images
        giniConfiguration.openWithEnabled = true
        giniConfiguration.qrCodeScanningEnabled = true
        giniConfiguration.multipageEnabled = true
        giniConfiguration.flashToggleEnabled = true
        giniConfiguration.navigationBarItemTintColor = .white
        giniConfiguration.customDocumentValidations = { document in
            // As an example of custom document validation, we add a more strict check for file size
            let maxFileSize = 10 * 1024 * 1024
            if document.data.count > maxFileSize {
                let error = CustomDocumentValidationError(message: "Diese Datei ist leider größer als 10MB")
                return CustomDocumentValidationResult.failure(withError: error)
            }
            return CustomDocumentValidationResult.success()
        }
        return giniConfiguration
    }()
    
    private lazy var client: Client = CredentialsManager.fetchClientFromBundle()
    lazy var apiLib = GiniApiLib.Builder(client: client).build()

    private var documentMetadata: Document.Metadata?
    private let documentMetadataBranchId = "GiniPayBusinessExampleIOS"
    private let documentMetadataAppFlowKey = "AppFlow"

    init(window: UIWindow) {
        self.window = window
        print("------------------------------------\n\n",
              "📸 Gini Capture SDK for iOS (\(GiniCapture.versionString))\n\n",
            "      - Client id:  \(client.id)\n",
            "      - Client email domain:  \(client.domain)",
            "\n\n------------------------------------\n")
    }
    
    func start() {
        self.showSelectAPIScreen()
    }
    
    func processExternalDocument(withUrl url: URL, sourceApplication: String?) {
        
        // 1. Build the document
        let documentBuilder = GiniCaptureDocumentBuilder(documentSource: .appName(name: sourceApplication))
        documentBuilder.importMethod = .openWith
        
        documentBuilder.build(with: url) { [weak self] (document) in
            
            guard let self = self else { return }
            
            // When a document is imported with "Open with", a dialog allowing to choose between both APIs
            // is shown in the main screen. Therefore it needs to go to the main screen if it is not there yet.
            self.popToRootViewControllerIfNeeded()
            
            // 2. Validate the document
            if let document = document {
                do {
                    try GiniCapture.validate(document,
                                            withConfig: self.giniConfiguration)
                    self.showOpenWithSwitchDialog(for: [GiniCapturePage(document: document, error: nil)])
                } catch {
                    self.showExternalDocumentNotValidDialog()
                }
            }
        }
    }
    
    func processBankUrl() {
            self.popToRootViewControllerIfNeeded()
            showReturnMessage()
        }
    
    fileprivate func showSelectAPIScreen() {
        self.window.rootViewController = rootViewController
        self.window.makeKeyAndVisible()
    }
    
    
    fileprivate func showComponentAPI(with pages: [GiniCapturePage]? = nil) {
        let componentAPICoordinator = ComponentAPICoordinator(pages: pages ?? [],
                                                              configuration: giniConfiguration,
                                                              documentService: componentAPIDocumentService(), giniApiLib: self.apiLib)
        componentAPICoordinator.delegate = self
        componentAPICoordinator.start()
        add(childCoordinator: componentAPICoordinator)
        
        rootViewController.present(componentAPICoordinator.rootViewController, animated: true, completion: nil)
    }
    
    fileprivate func componentAPIDocumentService() -> ComponentAPIDocumentServiceProtocol {
        
        documentMetadata = Document.Metadata(branchId: documentMetadataBranchId,
                                             additionalHeaders: [documentMetadataAppFlowKey: "ComponentAPI"])
        return ComponentAPIDocumentsService(lib: apiLib, documentMetadata: documentMetadata)
    }
    
    
    fileprivate func showOpenWithSwitchDialog(for pages: [GiniCapturePage]) {
        let alertViewController = UIAlertController(title: "Importierte Datei",
                                                    message: "Möchten Sie die importierte Datei mit dem " +
            "ScreenAPI oder ComponentAPI verwenden?",
                                                    preferredStyle: .alert)
               
        alertViewController.addAction(UIAlertAction(title: "Component API", style: .default) { [weak self] _ in
            self?.showComponentAPI(with: pages)
        })
        
        rootViewController.present(alertViewController, animated: true, completion: nil)
    }
    
    fileprivate func showExternalDocumentNotValidDialog() {
        let alertViewController = UIAlertController(title: "Ungültiges Dokument",
                                                    message: "Dies ist kein gültiges Dokument",
                                                    preferredStyle: .alert)
        
        alertViewController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            alertViewController.dismiss(animated: true, completion: nil)
        })
        
        rootViewController.present(alertViewController, animated: true, completion: nil)
    }
    
    fileprivate func showReturnMessage() {
        let alertViewController = UIAlertController(title: "Congratulations",
                                                    message: "Payment was successful 🎉",
                                                    preferredStyle: .alert)
        
        alertViewController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            alertViewController.dismiss(animated: true, completion: nil)
        })
        
        rootViewController.present(alertViewController, animated: true, completion: nil)
    }
    
    fileprivate func popToRootViewControllerIfNeeded() {
        self.childCoordinators.forEach { coordinator in
            coordinator.rootViewController.dismiss(animated: true, completion: nil)
            self.remove(childCoordinator: coordinator)
        }
    }
}

// MARK: SelectAPIViewControllerDelegate

extension AppCoordinator: SelectAPIViewControllerDelegate {
    
    func selectAPI(viewController: SelectAPIViewController, didSelectApi api: GiniCaptureAPIType) {
        switch api {
        case .screen:
            break
        case .component:
            showComponentAPI()
        }
    }
    
}

// MARK: ComponentAPICoordinatorDelegate

extension AppCoordinator: ComponentAPICoordinatorDelegate {
    func componentAPI(coordinator: ComponentAPICoordinator, didFinish: ()) {
        coordinator.rootViewController.dismiss(animated: true, completion: nil)
        self.remove(childCoordinator: coordinator)
    }
}
