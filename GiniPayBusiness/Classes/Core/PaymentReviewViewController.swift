//
//  PaymentReviewViewController.swift
//  GiniPayBusiness
//
//  Created by Nadya Karaban on 30.03.21.
//

import Foundation
public final class PaymentReviewViewController: UIViewController {
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var recipientField: UITextField!
    @IBOutlet var ibanField: UITextField!
    @IBOutlet var amountField: UITextField!
    @IBOutlet var usageField: UITextField!
    @IBOutlet var payButton: UIButton!
    @IBOutlet var backgroundSV: UIScrollView!
    @IBOutlet var bottomLayoutContsraint: NSLayoutConstraint!
    
    @IBOutlet var paymentInputFields: [UITextField]!
    @IBOutlet var bankProviderButtonView: UIView!
    @IBOutlet weak var inputContainer: UIView!
    @IBOutlet weak var containerCollectionView: UIView!
    @IBOutlet weak var paymentInfoStackView: UIStackView!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    enum TextFieldType: Int {
        case recipientFieldTag
        case ibanFieldTag
        case amountFieldTag
        case usageFieldTag
    }
    
    var giniPayBusinessConfiguration = GiniPayBusinessConfiguration()
    
    fileprivate func configureCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    fileprivate func configureBankProviderView(){
        bankProviderButtonView.backgroundColor = .white
        bankProviderButtonView.layer.cornerRadius = 6.0
        bankProviderButtonView.layer.borderWidth = 1.0
        bankProviderButtonView.layer.borderColor = UIColor.from(hex: 0xE6E7ED).cgColor
    }
    
    
    fileprivate func configurePayButton(){
        payButton.backgroundColor = UIColor.from(giniColor:giniPayBusinessConfiguration.payButtonBackgroundColor )
        payButton.layer.cornerRadius = giniPayBusinessConfiguration.payButtonCornerRadius
    }
    
    fileprivate func configurepaymentInputFields(){
        for field in paymentInputFields {
            field.borderStyle = .roundedRect
            field.backgroundColor = UIColor.from(giniColor:giniPayBusinessConfiguration.paymentInputFieldBackgroundColor)
            field.font = giniPayBusinessConfiguration.paymentInputFieldFont
            field.textColor = UIColor.from(giniColor:giniPayBusinessConfiguration.paymentInputFieldTextColor)
            let placeholderText = inputFieldPlaceholderText(field)
            field.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes:[NSAttributedString.Key.foregroundColor: UIColor.from(giniColor:giniPayBusinessConfiguration.paymentInputFieldPlaceholderTextColor),NSAttributedString.Key.font:giniPayBusinessConfiguration.paymentInputFieldPlaceholderFont])
        }
    }
    
    fileprivate func inputFieldPlaceholderText(_ textField: UITextField) -> String  {
            if let fieldIdentifier = TextFieldType(rawValue: textField.tag) {
                switch fieldIdentifier {
                case .recipientFieldTag :
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
    
   var thisWidth: CGFloat = 0
    
    fileprivate func congifureUI() {
        configureCollectionView()
        configurePayButton()
        configurepaymentInputFields()
        configureBankProviderView()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        subscribeOnKeyboardNotifications()

        congifureUI()
        
        thisWidth = CGFloat(view.frame.width)

        pageControl.hidesForSinglePage = true
   }
    
    override public func viewDidDisappear(_ animated: Bool) {
        
        unsubscribeFromKeyboardNotifications()
    }
    
    override public func viewWillLayoutSubviews() {
        super .viewWillLayoutSubviews()
        inputContainer.roundCorners(corners: [.topLeft, .topRight], radius: 12)

    }


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
    
    fileprivate func unsubscribeFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    fileprivate func showInputFieldError(fieldIdentifier: TextFieldType) {
        let activeTextField = view.viewWithTag(fieldIdentifier.rawValue) as! UITextField
        switch fieldIdentifier {
        case .ibanFieldTag:
            activeTextField.layer.borderWidth = 1
            activeTextField.layer.borderColor = UIColor.red.cgColor
        default:
            activeTextField.layer.borderWidth = 1
            activeTextField.layer.borderColor = UIColor.red.cgColor
        }
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
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if let fieldIdentifier = TextFieldType(rawValue: textField.tag) {
            switch fieldIdentifier {
            case .ibanFieldTag:
                if let ibanText = textField.text {
                    if (IBANValidator().isValid(iban: ibanText)) {
                    } else { showInputFieldError(fieldIdentifier: fieldIdentifier) }
                } else {
                    showInputFieldError(fieldIdentifier: fieldIdentifier)
                }
            case .amountFieldTag, .recipientFieldTag,.usageFieldTag: break
            }
        }
    }
}

extension PaymentReviewViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
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
        cell.pageImageView.image = image
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        let width = collectionView.frame.width
        return CGSize(width: width, height: height)
    }
    
    //MARK:- For Display the page number in page controll of collection view Cell
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}
