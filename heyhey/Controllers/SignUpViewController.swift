//
//  SignUpViewController.swift
//  heyhey
//
//  Created by Vlad Tretiak on 05.12.2020.
//

import UIKit

class SignUpViewController: BaseViewController {
    
    class func instantiate() -> Self {
        let controller: Self = .instantiate("Main", "SignUpViewController")
        return controller
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton! {
        didSet {
            signUpButton.isEnabled = false
        }
    }
    @IBOutlet weak var swithStateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        setupPreviewButton()
        titleLabel.text = "Welcome, registr, please for start"
        swithStateButton.setTitle("Alredy have an account? Log In", for: .normal)
        signUpButton.setTitle("regist", for: .normal)
    }
    
    func config() {
        view.backgroundColor = .black
        adjustTextField(with: loginTextField, title: "Login")
        adjustTextField(with: passwordTextField, title: "Password")
        handleTextField()
        
        signUpButton.addTarget(self, action: #selector(startLogin), for: .touchUpInside)
        swithStateButton.addTarget(self, action: #selector(switchController), for: .touchUpInside)
    }
    
    func handleTextField() {
        loginTextField.addTarget(self, action: #selector(Self.textFieldDidChenge), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(Self.textFieldDidChenge), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChenge() {
        guard let email = loginTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
            else {
                signUpButton.setTitleColor(.lightText, for: .normal)
                signUpButton.isEnabled = false
                return
        }
        signUpButton.setTitleColor(.systemBlue, for: .normal)
        signUpButton .isEnabled = true
    }

    
    @objc func startLogin(sender: UIButton) {
        view.endEditing(true)
        guard let name = loginTextField.text, let pass = passwordTextField.text else {
            return
        }
        networkService.request(router: .registration(userName: name, userPass: pass), model: Registration.self) { [weak self] (data) in
            guard let data = data else { return } //need add error
            self?.userData = data
            //TO DO: parsing here
            guard self?.userData?.message == nil else {
                let alert = UIAlertController(title: "try again", message: self?.userData?.message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self?.present(alert, animated: true)
                return
            }
            self?.openMainScreen(with: self?.userData?.token ?? "")
        }
    }
    
    @objc func switchController(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
