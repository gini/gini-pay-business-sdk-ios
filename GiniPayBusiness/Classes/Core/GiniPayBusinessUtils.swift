//
//  GiniPayBusinessUtils.swift
//  GiniPayBusiness
//
//  Created by Nadya Karaban on 15.04.21.
//

import Foundation
/**
  Returns the GiniPayBusiness bundle.
 
 */
public func giniPayBusinessBundle() -> Bundle {
    Bundle(for: GiniPayBusiness.self)
}

/**
 Returns an optional `UIImage` instance with the given `name` preferably from the client's bundle.
 
 - parameter name: The name of the image file without file extension.
 
 - returns: Image if found with name.
 */
func UIImageNamedPreferred(named name: String) -> UIImage? {
    if let clientImage = UIImage(named: name) {
        return clientImage
    }
    return UIImage(named: name, in: giniPayBusinessBundle(), compatibleWith: nil)
}

/**
 Returns a localized string resource preferably from the client's bundle.
 
 - parameter key:     The key to search for in the strings file.
 - parameter comment: The corresponding comment.
 
 - returns: String resource for the given key.
 */
func NSLocalizedStringPreferredFormat(_ key: String,
                                      fallbackKey: String = "",
                                      comment: String,
                                      isCustomizable: Bool = true) -> String {
    let clientString = NSLocalizedString(key, comment: comment)
    let fallbackClientString = NSLocalizedString(fallbackKey, comment: comment)
    let format: String
    if (clientString.lowercased() != key.lowercased() || fallbackClientString.lowercased() != fallbackKey.lowercased())
        && isCustomizable {
        format = clientString
    } else {
        let bundle = giniPayBusinessBundle()

        var defaultFormat = NSLocalizedString(key, bundle: bundle, comment: comment)
        
        if defaultFormat.lowercased() == key.lowercased() {
            defaultFormat = NSLocalizedString(fallbackKey, bundle: bundle, comment: comment)
        }
        
        format = defaultFormat
    }
    
    return format
}
/**
 Returns a formatted string from amount extraction.
 
 - parameter string: The amount extraction string.
 
 - returns: String with currency,grouping separator, decimal separator and 2 fraction digits .
 */
func formattedStringFromExtraction(string: String) -> String {
    let components = string.components(separatedBy: ":")
    guard components.count == 2 else { return "" }
    let doubleValue = Double(components.first ?? "") ?? 0
    return formattedStringWithCurrency(value: doubleValue)
}

/**
 Returns a formatted string with currency symbol
 
 - parameter value: Double value.
 
 - returns: String with currency,grouping separator, decimal separator and 2 fraction digits .
 */
func formattedStringWithCurrency(value: Double) -> String {
    let myNumber = NSNumber(value: value)
    let currencyFormatter = NumberFormatter()
    currencyFormatter.usesGroupingSeparator = true
    currencyFormatter.numberStyle = .currency
    currencyFormatter.decimalSeparator = .some(".")
    currencyFormatter.maximumFractionDigits = 2
    currencyFormatter.minimumFractionDigits = 2
    return currencyFormatter.string(from: myNumber) ?? ""
}

/**
 Returns a formatted string for payment request
 
 - parameter numberString: String from input field.
 
 - returns: String with specific format for backed and german locale.
 */
func formattedStringWithCurrencyForPaymentRequest(numberString: String) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    let germanLocale = Locale(identifier: "de_DE")
    formatter.locale = germanLocale
    let stringWithoutCurrency =  formatter.string(from: Decimal(string: numberString, locale: germanLocale)! as NSNumber)
    guard let trimmedStringWithoutCurrency = stringWithoutCurrency?.trimmingCharacters(in: .whitespaces) else { return "" }
    let totalString = trimmedStringWithoutCurrency + ":" + formatter.currencyCode
    return totalString
}

/**
 Returns a formatted string without currency and whitespaces
 
 - parameter numberString: String from input field.
 
 - returns: String without currency and whitespaces in current locale.
 */
func formattedStringWithoutCurrencyWithCurrentLocale(numberString: String) -> String {
    var formattedString = numberString
    formattedString.removeLast()
    let resultString = formattedString.trimmingCharacters(in: .whitespaces)
    return resultString
}
