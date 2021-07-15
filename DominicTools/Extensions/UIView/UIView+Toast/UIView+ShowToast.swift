//
//  UIView+ShowToast.swift
//  DominicTools
//
//  Created by Irsyad Ashari on 10/07/21.
//

import UIKit

extension UIViewController {
    func toastMessage(_ message: String){
        guard let window = UIApplication.shared.keyWindow else {return}
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 12)
        messageLabel.textColor = .white
        messageLabel.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        let textSize:CGSize = messageLabel.intrinsicContentSize
        let labelWidth = min(textSize.width, window.frame.width - 40)
        
        messageLabel.frame = CGRect(x: 20, y: 24, width: labelWidth + 30, height: textSize.height + 20)
        messageLabel.center.x = window.center.x
        messageLabel.layer.cornerRadius = messageLabel.frame.height/2
        messageLabel.layer.masksToBounds = true
        window.addSubview(messageLabel)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            UIView.animate(withDuration: 1, animations: {
                messageLabel.alpha = 0
            }) { (_) in
                messageLabel.removeFromSuperview()
            }
        }
    }}
