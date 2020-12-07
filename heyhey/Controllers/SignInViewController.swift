//
//  SignInViewController.swift
//  heyhey
//
//  Created by Vlad Tretiak on 05.12.2020.
//

import UIKit

class SignInViewController: BaseViewController {
    
    class func instantiate() -> Self {
        let controller: Self = .instantiate("Main", "SignInViewController")
        return controller
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton! {
        didSet {
            signInButton.isEnabled = false
        }
    }
    @IBOutlet weak var swithStateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        configure()
        setupPreviewButton()
        handleTextField()
    }
    
    func config() {
        adjustTextField(with: loginTextField, title: "Login")
        adjustTextField(with: passwordTextField, title: "Password")
        
        signInButton.setTitleColor(.black, for: .disabled)
        signInButton.setTitleColor(.systemBlue, for: .normal)
        signInButton.addTarget(self, action: #selector(startLogin), for: .touchUpInside)
        
        swithStateButton.addTarget(self, action: #selector(switchController), for: .touchUpInside)
    }
    
    func configure() {
        titleLabel.text = "Welcome, login, please"
        swithStateButton.setTitle("Don't have an account", for: .normal)
        signInButton.setTitle("login", for: .normal)
    }
    
    func handleTextField() {
        loginTextField.addTarget(self, action: #selector(Self.textFieldDidChenge), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(Self.textFieldDidChenge), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChenge() {
        guard let email = loginTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty
        else {
            
            signInButton.isEnabled = false
            return
        }
        signInButton .isEnabled = true
    }
    
    @objc func startLogin(sender: UIButton) {
        view.endEditing(true)
        guard let name = loginTextField.text, let pass = passwordTextField.text else {
            return
        }
        networkService.request(router: .login(userName: name, userPass: pass), model: Registration.self) {
            [weak self] (data) in
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
        let contr = SignUpViewController.instantiate()
        self.present(contr, animated: true, completion: nil)
    }
}


