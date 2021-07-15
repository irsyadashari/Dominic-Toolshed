//
//  LendToolsPopUpViewController.swift
//  DominicTools
//
//  Created by Irsyad Ashari on 02/07/21.
//

import UIKit
import RxSwift

class LendToolsPopUpViewController: UIViewController {

    public enum NavigationEvent {
        case dismiss
        case saveInput(String)
        case contactIsNotExist
    }
    
    public var onNavigationEvent: ((NavigationEvent) -> Void)?
    
    // MARK: - PRIVATE PROPERTIES
    
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var textFieldLenderName: UITextField!
    @IBOutlet private weak var okButton: UIButton!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textFieldLenderName.becomeFirstResponder()
    }
    
    // MARK: - PUBLIC METHOD

    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch: UITouch? = touches.first
        
        let onTheBackgroundView = (touch?.view == backgroundView)
        let notPresentingSomething = self.presentedViewController == nil
        
        if onTheBackgroundView && notPresentingSomething {
            dismiss()
        }
    }
    
    public func show(from viewController: UIViewController) {
        
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        
        viewController.present(self, animated: false) {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                
                self?.containerView.transform = .identity
                
                self?.view.layoutIfNeeded()
                self?.view.alpha = 1
            })
        }
    }
    
    public func dismiss(animated: Bool = true) {
        
        textFieldLenderName.resignFirstResponder()
        
        guard animated else {
            
            view.alpha = 0
            dismiss(animated: false, completion: nil)
            return
        }
        
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                
                self?.view.alpha = 0
                guard let translateY = self?.containerView.frame.size.height else {
                    return
                }
                self?.containerView.transform = CGAffineTransform(translationX: 0, y: translateY)
                
            }, completion: { [weak self] _ in
                self?.dismiss(animated: false, completion: nil)
            }
        )
        
    }
    
    // MARK: - PRIVATE METHOD
    
    private func configureView() {
        
        configureContainerView()
        registerKeyboardNSNotification()
        prepareSubviewsForAnimation()
        configureBottomButton()
    }
    
    private func configureBottomButton() {
        
        textFieldLenderName.rx.text
            .subscribe(onNext: { text in
                
                guard let isEmpty = text?.isEmpty else { return}
                
                self.okButton.isEnabled = isEmpty ? false : true
                self.okButton.backgroundColor = isEmpty ? .gray : .blue
            })
            .disposed(by: disposeBag)
    }
    
    private func prepareSubviewsForAnimation() {
        
        view.alpha = 0
        containerView.transform = CGAffineTransform(translationX: 0, y: containerView.frame.size.height)
    }
    
    private func configureContainerView() {
        
        
        containerView.layer.cornerRadius = 16
        containerView.layer.maskedCorners = CACornerMask(arrayLiteral: [
            CACornerMask.layerMinXMinYCorner,
            CACornerMask.layerMaxXMinYCorner
        ])
        okButton.layer.cornerRadius = 16
    }
    
    private func registerKeyboardNSNotification() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillChangeFrame(notification: Notification) {
        
        guard
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else {
            return
        }
        
        bottomConstraint.constant = UIScreen.main.bounds.size.height - self.view.safeAreaInsets.bottom - keyboardFrame.origin.y
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    @IBAction private func onOkButtonTapped(_ sender: Any) {
        
        guard let name = textFieldLenderName.text else {
            self.onNavigationEvent?(.dismiss)
            return
        }
        
        self.onNavigationEvent?(.saveInput(name))
    }
}
