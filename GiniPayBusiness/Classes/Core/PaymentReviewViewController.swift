//
//  PaymentReviewViewController.swift
//  GiniPayBusiness
//
//  Created by Nadya Karaban on 30.03.21.
//

import Foundation
public final class PaymentReviewViewController: UIViewController, UIScrollViewDelegate {
    var giniPayBusinessConfiguration = GiniPayBusinessConfiguration()
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var recipientField: UITextField!
    @IBOutlet var ibanField: UITextField!
    @IBOutlet var amountField: UITextField!
    @IBOutlet var usageField: UITextField!
    @IBOutlet var payButton: UIButton!
    @IBOutlet var backgroundSV: UIScrollView!

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            /**
             If keyboard size is not available for some reason, dont do anything
             */
            return
        }
        /**
         Moves the root view up by the distance of keyboard height
         */
        view.frame.origin.y = 0 - keyboardSize.height
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        /**
         Moves back the root view origin to zero
         */
        view.frame.origin.y = 0
    }

    fileprivate func subscribeOnKeyboardNotifications() {
        /**
         Calls the 'keyboardWillShow' function when the view controller receive the notification that a keyboard is going to be shown
         */
        NotificationCenter.default.addObserver(self, selector: #selector(PaymentReviewViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        /**
         Calls the 'keyboardWillHide' function when the view controlelr receive notification that keyboard is going to be hidden
         */
        NotificationCenter.default.addObserver(self, selector: #selector(PaymentReviewViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    fileprivate func unsubscribeFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        subscribeOnKeyboardNotifications()
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        
        unsubscribeFromKeyboardNotifications()
    }
}

extension PaymentReviewViewController: UITextFieldDelegate {
    /**
     Dissmiss the keyboard when return key pressed
     */
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
