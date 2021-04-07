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
    @objc public var payButtonBackgroundColor = GiniColor(lightModeColor: .blue, darkModeColor: .blue)
    
    /**
     Sets the font of the pay button on the payment review screen
     */
    @objc public var payButtonTextFont = UIFont.systemFont(ofSize: 20, weight: .bold)
    
    /**
     Sets the text color of the pay button on the payment review screen
     */
    @objc public var payButtonTextColor = GiniColor(lightModeColor: .white, darkModeColor: .black)
    
    /**
     Sets the corner radius of the pay button on the payment review screen
     */
    @objc public var payButtonCornerRadius = 6.0
    
    /**
     Sets the font used in the Return Assistant screens by default.
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
