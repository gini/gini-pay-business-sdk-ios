//
//  GiniPayBusinessConfiguration.swift
//  GiniPayBusiness
//
//  Created by Nadya Karaban on 30.03.21.
//

import Foundation
public final class GiniPayBusinessConfiguration: NSObject {
    
    /**
     Singleton to make configuration internally accessible in all classes of the Gini Pay Business SDK.
     */
    static var shared = GiniPayBusinessConfiguration()
    
    /**
     Returns a `GiniPayBusinessConfiguration` instance which allows to set individual configurations
     to change the look and feel of the Gini Pay Business SDK.
     
     - returns: Instance of `GiniPayBusinessConfiguration`.
     */
    public override init() {}
    
    
    /**
     Sets the backgroundColor  on the payment review screen for pay button
     */
    @objc public var payButtonBackgroundColor = GiniColor(lightModeColor: UIColor.from(hex:0xFF6800), darkModeColor: UIColor.from(hex:0xFF6800))
    
    /**
     Sets the font of the pay button on the payment review screen
     */
    @objc public var payButtonTextFont = UIFont.systemFont(ofSize: 20, weight: .bold)
    
    /**
     Sets the text color of the pay button on the payment review screen
     */
    @objc public var payButtonTextColor = GiniColor(lightModeColor: .white, darkModeColor: .white)
    
    /**
     Sets the corner radius of the pay button on the payment review screen
     */
    @objc public var payButtonCornerRadius: CGFloat = 6.0
    
    /**
     Sets the corner radius of the payment input fields on the payment review screen
     */
    @objc public var paymentInputFieldCornerRadius: CGFloat = 6.0
    
    /**
     Sets the border width of the payment input fields on the payment review screen
     */
    @objc public var paymentInputFieldBorderWidth: CGFloat = 1.0
    
    /**
     Sets the error style color and error text color for the payment input fields on the payment review screen
     */
    @objc public var paymentInputFieldErrorStyleColor = UIColor.red
    
    /**
     Sets the selection style color for the payment input fields on the payment review screen
     */
    @objc public var paymentInputFieldSelectionStyleColor = UIColor.blue
    
    /**
     Sets the font of the payment input fields on the payment review screen
     */
    @objc public var paymentInputFieldFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
    
    /**
     Sets the background color of the payment input fields on the payment review screen
     */
    @objc public var paymentInputFieldBackgroundColor = GiniColor(lightModeColor: UIColor.from(hex: 0xF2F3F6), darkModeColor: UIColor.from(hex: 0xF2F3F6))
    
    /**
     Sets the text color of the payment input fields on the payment review screen
     */
    @objc public var paymentInputFieldTextColor = GiniColor(lightModeColor: UIColor.from(hex: 0x33406F), darkModeColor: UIColor.from(hex: 0x33406F))

    /**
     Sets the placeholder font of the payment input fields on the payment review screen
     */
    @objc public var paymentInputFieldPlaceholderFont = UIFont.systemFont(ofSize: 17, weight: .light)
    
    /**
     Sets the placeholder text color of the payment input fields on the payment review screen
     */
    @objc public var paymentInputFieldPlaceholderTextColor = GiniColor(lightModeColor: UIColor.from(hex: 0x999FB7), darkModeColor: UIColor.from(hex: 0x999FB7))
    
    /**
     Sets the font used in the screens by default.
     */
    
    @objc public lazy var customFont = GiniFont(regular: UIFont.systemFont(ofSize: 14,
                                                                                                 weight: .regular),
                                                                      bold: UIFont.systemFont(ofSize: 14,
                                                                                              weight: .bold),
                                                                      light: UIFont.systemFont(ofSize: 14,
                                                                                               weight: .light),
                                                                      thin: UIFont.systemFont(ofSize: 14,
                                                                                              weight: .thin),
                                                                      isEnabled: false)
}
