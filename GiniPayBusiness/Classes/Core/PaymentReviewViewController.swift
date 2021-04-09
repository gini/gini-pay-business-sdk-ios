//
//  PaymentReviewViewController.swift
//  GiniPayBusiness
//
//  Created by Nadya Karaban on 30.03.21.
//

import Foundation
public final class PaymentReviewViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var recipientField: UITextField!
    @IBOutlet var ibanField: UITextField!
    @IBOutlet var amountField: UITextField!
    @IBOutlet var usageField: UITextField!
    @IBOutlet var payButton: UIButton!
    @IBOutlet var paymentInputFieldsErrorLabels: [UILabel]!
    @IBOutlet var usageErrorLabel: UILabel!
    @IBOutlet var amountErrorLabel: UILabel!
    @IBOutlet var ibanErrorLabel: UILabel!
    @IBOutlet var recipientErrorLabel: UILabel!
    @IBOutlet var paymentInputFields: [UITextField]!
    @IBOutlet var bankProviderButtonView: UIView!
    @IBOutlet var inputContainer: UIView!
    @IBOutlet var containerCollectionView: UIView!
    @IBOutlet var paymentInfoStackView: UIStackView!
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    enum TextFieldType: Int {
        case recipientFieldTag = 1
        case ibanFieldTag
        case amountFieldTag
        case usageFieldTag
    }

    var giniPayBusinessConfiguration = GiniPayBusinessConfiguration()
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        subscribeOnKeyboardNotifications()
        congifureUI()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        inputContainer.roundCorners(corners: [.topLeft, .topRight], radius: 12)
    }
    
    // MARK: - congifureUI

    fileprivate func congifureUI() {
        configureCollectionView()
        configurePayButton()
        configurePaymentInputFields()
        configureBankProviderView()
        configurePageControl()
        hideErrorLabels()
    }

    // MARK: - TODO ConfigureBankProviderView Dynamically configured
    
    fileprivate func configureBankProviderView() {
        bankProviderButtonView.backgroundColor = .white
        bankProviderButtonView.layer.cornerRadius = self.giniPayBusinessConfiguration.paymentInputFieldCornerRadius
        bankProviderButtonView.layer.borderWidth = self.giniPayBusinessConfiguration.paymentInputFieldBorderWidth
        bankProviderButtonView.layer.borderColor = UIColor.from(hex: 0xE6E7ED).cgColor
    }

    fileprivate func configurePayButton() {
        payButton.backgroundColor = UIColor.from(giniColor: giniPayBusinessConfiguration.payButtonBackgroundColor)
        payButton.layer.cornerRadius = giniPayBusinessConfiguration.payButtonCornerRadius
    }
    
    fileprivate func configurePaymentInputFields() {
        for field in paymentInputFields {
            applyDefaultStyle(field)
        }
    }
    
    fileprivate func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    fileprivate func configurePageControl() {
        pageControl.hidesForSinglePage = true
    }
    
    // MARK: - Input fields configuration

    fileprivate func applyDefaultStyle(_ field: UITextField) {
        field.layer.cornerRadius = self.giniPayBusinessConfiguration.paymentInputFieldCornerRadius
        field.layer.borderWidth = 0.0
        field.backgroundColor = UIColor.from(giniColor: giniPayBusinessConfiguration.paymentInputFieldBackgroundColor)
        field.font = giniPayBusinessConfiguration.paymentInputFieldFont
        field.textColor = UIColor.from(giniColor: giniPayBusinessConfiguration.paymentInputFieldTextColor)
        let placeholderText = inputFieldPlaceholderText(field)
        field.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.from(giniColor: giniPayBusinessConfiguration.paymentInputFieldPlaceholderTextColor), NSAttributedString.Key.font: giniPayBusinessConfiguration.paymentInputFieldPlaceholderFont])
        field.layer.masksToBounds = true
    }

    fileprivate func applyErrorStyle(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            textField.layer.cornerRadius = self.giniPayBusinessConfiguration.paymentInputFieldCornerRadius
            textField.backgroundColor = UIColor.from(giniColor: self.giniPayBusinessConfiguration.paymentInputFieldBackgroundColor)
            textField.layer.borderWidth = self.giniPayBusinessConfiguration.paymentInputFieldBorderWidth
            textField.layer.borderColor = self.giniPayBusinessConfiguration.paymentInputFieldErrorStyleColor.cgColor
            textField.layer.masksToBounds = true
        }
    }

    fileprivate func applySelectionStyle(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            textField.layer.cornerRadius = self.giniPayBusinessConfiguration.paymentInputFieldCornerRadius
            textField.backgroundColor = .white
            textField.layer.borderWidth = self.giniPayBusinessConfiguration.paymentInputFieldBorderWidth
            textField.layer.borderColor = self.giniPayBusinessConfiguration.paymentInputFieldSelectionStyleColor.cgColor
            textField.layer.masksToBounds = true
        }
    }

    fileprivate func inputFieldPlaceholderText(_ textField: UITextField) -> String {
        if let fieldIdentifier = TextFieldType(rawValue: textField.tag) {
            switch fieldIdentifier {
            case .recipientFieldTag:
                return NSLocalizedStringPreferredFormat("ginipaybusiness.reviewscreen.recipient.placeholder",
                                                        comment: "placeholder text for recipient input field")
            case .ibanFieldTag:
                return NSLocalizedStringPreferredFormat("ginipaybusiness.reviewscreen.iban.placeholder",
                                                        comment: "placeholder text for iban input field")
            case .amountFieldTag:
                return NSLocalizedStringPreferredFormat("ginipaybusiness.reviewscreen.amount.placeholder",
                                                        comment: "placeholder text for amount input field")
            case .usageFieldTag:
                return NSLocalizedStringPreferredFormat("ginipaybusiness.reviewscreen.usage.placeholder",
                                                        comment: "placeholder text for usage input field")
            }
        }
        return ""
    }
    
    // MARK: - Input fields validation
    
    fileprivate func validateTextField(_ textField: UITextField) {
        if let fieldIdentifier = TextFieldType(rawValue: textField.tag) {
            switch fieldIdentifier {
            case .ibanFieldTag:
                if let ibanText = textField.text, textField.hasText {
                    if IBANValidator().isValid(iban: ibanText) {
                        applyDefaultStyle(textField)
                        hideErrorLabel(textFieldTag: fieldIdentifier)
                    } else {
                        applyErrorStyle(textField)
                        showErrorLabel(textFieldTag: fieldIdentifier)
                    }
                } else {
                    applyErrorStyle(textField)
                    showErrorLabel(textFieldTag: fieldIdentifier)
                }
            case .amountFieldTag, .recipientFieldTag, .usageFieldTag:
                if textField.hasText {
                    applyDefaultStyle(textField)
                    hideErrorLabel(textFieldTag: fieldIdentifier)
                } else {
                    applyErrorStyle(textField)
                    showErrorLabel(textFieldTag: fieldIdentifier)
                }
            }
        }
    }

    fileprivate func validateAllInputFields() {
        for textField in paymentInputFields {
            validateTextField(textField)
        }
    }
    
    fileprivate func hideErrorLabels() {
        for errorLabel in paymentInputFieldsErrorLabels {
            UIView.animate(withDuration: 0.3) {
                errorLabel.isHidden = true
            }
        }
    }

    fileprivate func showErrorLabel(textFieldTag: TextFieldType) {
        var errorLabel = UILabel()
        var errorMessage = "required field"
        switch textFieldTag {
        case .recipientFieldTag:
            errorLabel = recipientErrorLabel
            errorMessage = "recipient field required"
        case .ibanFieldTag:
            errorLabel = ibanErrorLabel
            errorMessage = "iban field required"
        case .amountFieldTag:
            errorLabel = amountErrorLabel
            errorMessage = "amount field required"
        case .usageFieldTag:
            errorLabel = usageErrorLabel
            errorMessage = "usage field required"
        }
        if errorLabel.isHidden {
            UIView.animate(withDuration: 0.3) {
                errorLabel.isHidden = false
                errorLabel.textColor = .red
                errorLabel.text = errorMessage
            }
        }
    }

    fileprivate func hideErrorLabel(textFieldTag: TextFieldType) {
        var errorLabel = UILabel()
        switch textFieldTag {
        case .recipientFieldTag:
            errorLabel = recipientErrorLabel
        case .ibanFieldTag:
            errorLabel = ibanErrorLabel
        case .amountFieldTag:
            errorLabel = amountErrorLabel
        case .usageFieldTag:
            errorLabel = usageErrorLabel
        }
        if !errorLabel.isHidden {
            UIView.animate(withDuration: 0.3) {
                errorLabel.isHidden = true
            }
        }
    }
    
    // MARK: - IBAction

    @IBAction func payButtonClicked(_ sender: Any) {
        validateAllInputFields()
    }
    
    // MARK: - Keyboard handling
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            /**
             If keyboard size is not available for some reason, dont do anything
             */
            return
        }
        /**
         Moves the root view up by the distance of keyboard height  taking in account safeAreaInsets.bottom
         */
        if #available(iOS 11.0, *) {
            view.frame.origin.y = 0 - keyboardSize.height + view.safeAreaInsets.bottom
        } else {
            view.frame.origin.y = 0 - keyboardSize.height
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        /**
         Moves back the root view origin to zero
         */
        view.frame.origin.y = 0
    }

    func subscribeOnKeyboardNotifications() {
        /**
         Calls the 'keyboardWillShow' function when the view controller receive the notification that a keyboard is going to be shown
         */
        NotificationCenter.default.addObserver(self, selector: #selector(PaymentReviewViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        /**
         Calls the 'keyboardWillHide' function when the view controlelr receive notification that keyboard is going to be hidden
         */
        NotificationCenter.default.addObserver(self, selector: #selector(PaymentReviewViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    fileprivate func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - UITextFieldDelegate

extension PaymentReviewViewController: UITextFieldDelegate {
    /**
     Dissmiss the keyboard when return key pressed
     */
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        validateTextField(textField)
        return true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        validateTextField(textField)
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        applySelectionStyle(textField)
    }
}
// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension PaymentReviewViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pageCellIdentifier", for: indexPath) as! PageCollectionViewCell
        cell.pageImageView.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
        let image = UIImageNamedPreferred(named: "test")
        cell.pageImageView.display(image: image ?? UIImage())
        return cell
    }
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        let width = collectionView.frame.width
        return CGSize(width: width, height: height)
    }

    // MARK: - For Display the page number in page controll of collection view Cell

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}
