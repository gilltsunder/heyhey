//
//  BaseViewController.swift
//  heyhey
//
//  Created by Vlad Tretiak on 05.12.2020.
//

import UIKit

class BaseViewController: UIViewController {
    
    var userData: Registration?
    let networkService = NetworkService()
    
    var previewButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Wanna see preview", for: .normal)
        button.setTitleColor(.red, for: .normal)
        return button
    }()
    
    func setupPreviewButton() {
        view.addSubview(previewButton)
        NSLayoutConstraint.activate([
            previewButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            previewButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        previewButton.addTarget(self, action: #selector(previewButtonTapped), for: .touchUpInside)
    }
    
    @objc func previewButtonTapped(sender: UIButton) {
        openMainScreen(with: "", isPreview: true)
    }
    
    func openMainScreen(with token: String, isPreview: Bool? = false) {
        if isPreview ?? false {
            DAKeychain.shared[tokenKey] = preview
        } else {
            DAKeychain.shared[tokenKey] = token
        }
        let contr = MainCollectionViewController.instantiate()
        let navController = UINavigationController(rootViewController: contr)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated:true, completion: nil)
    }
    
    func adjustTextField(with textField: UITextField, title: String) {
        textField.backgroundColor = .black
        textField.tintColor = .white
        textField.textColor = .white
        textField.attributedPlaceholder = NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor:  UIColor(white: 1.0, alpha: 0.6)])
        let buttonlLayer = CALayer()
        buttonlLayer.frame = CGRect(x: 0, y: 27, width: textField.frame.width, height: 0.6)
        buttonlLayer.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1).cgColor
        textField.layer.addSublayer(buttonlLayer)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}
