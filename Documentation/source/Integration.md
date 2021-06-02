Integration
=============================

Gini Pay provides an information extraction system for analyzing business invoices and transfers them to the iOS banking app, where the payment process will be completed.

The Gini Pay Business SDK for iOS provides functionality to upload the multipage documents with mobile phones, accurate line item extraction enables the user to to pay the invoice with prefferable payment provider. 

**Note** For supporting each payment provider you need to specify `LSApplicationQueriesSchemes` in your `Info.plist` file. App schemes for specification will be provided by Gini.


## Upload the document

Document upload can be done in two ways:

using `GiniApiLib`
using `GiniCapture`


#### GiniApiLib initialization

If you want to use a transparent proxy with your own authentication you can specify your own domain and add `AlternativeTokenSource` protocol implementation:

```swift
 let apiLib =  GiniApiLib.Builder(customApiDomain: "api.custom.net",
                                 alternativeTokenSource: MyAlternativeTokenSource)
                                 .build()
```
The token your provide will be added as a bearer token to all api.custom.net requests.

Optionally if you want to use _Certificate pinning_, provide metadata for the upload process, you can pass both your public key pinning configuration (see [TrustKit repo](https://github.com/datatheorem/TrustKit) for more information)
```swift
    let giniApiLib = GiniApiLib
        .Builder(client: Client(id: "your-id",
                                secret: "your-secret",
                                domain: "your-domain"),
                 api: .default,
                 pinningConfig: yourPublicPinningConfig)
        .build()
```
> ⚠️  **Important**
> - The document metadata for the upload process is intended to be used for reporting.

## GiniPayBusiness initialization
Now that the `GiniApiLib` has been initialized, you can initialize `GiniPayBusiness`

```swift
 let businessSDK = GiniPayBusiness(with: giniApiLib)
```
and upload your document if you plan to do it with `GiniPayBusiness`. First you need get document service and create partial document.

```swift
let documentService: DefaultDocumentService = businessSDK.documentService()
documentService.createDocument(fileName:"ginipay-partial",
                               docType: nil,
                               type: .partial(documentData),
                               metadata: nil)
```
The method above returns the completion block with partial `Document` in success case.

After receiving the partial document in completion you can get actual composite document:

```swift
let partialDocs = [PartialDocumentInfo(document: createdDocument.links.document)]
 self.businessSDK.documentService
            .createDocument(fileName: "ginipay-composite",
                            docType: nil,
                            type: .composite(CompositeDocumentInfo(partialDocuments: partialDocs)),
                            metadata: nil)

```

##  Check preconditions
There are two methods in GiniPayBusiness `businessSDK.checkIfAnyPaymentProviderAvailiable` and `businessSDK.checkIfDocumentIsPayable(docId: String)` returns true if Iban was extracted.

## Fetching data for payment review screen
If the preconditions checks are succeeded you can fetch the document and extractions for Payment Review screen:

```swift
businessSDK.fetchDataForReview(documentId: documentId,
                              completion: @escaping (Result<DataForReview, GiniPayBusinessError>) -> Void)
```
The method above returns the completion block with the struct `DataForReview`, which includes document and extractions.


## Payment review screen initialization 
```swift
let vc = PaymentReviewViewController.instantiate(with giniPayBusiness: businessSDK,
                                                 data: dataForReview)
```
The screen can be presented modally, used in a container view or pushed to a navigation view controller. Make sure to add your own navigational elements around the provided views.

To also use the `GiniPayBusinessConfiguration`:

```swift
let giniConfiguration = GiniPayBusinessConfiguration()
config.loadingIndicatorColor = .black
.
.
.
businessSDK.setConfiguration(config)
```