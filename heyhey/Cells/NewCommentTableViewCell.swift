//
//  NewCommentTableViewCell.swift
//  heyhey
//
//  Created by Vlad Tretiak on 07.12.2020.
//

import UIKit

class NewCommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var rateView: StarRatingView!
    @IBOutlet weak var commentTextField: UITextField! {
        didSet {
            commentTextField.placeholder = "write you comment here"
        }
    }
    @IBOutlet weak var sendButton: UIButton! {
        didSet {
            sendButton.isEnabled = false
            sendButton.setTitleColor(.gray, for: .disabled)
            sendButton.setTitleColor(.systemBlue, for: .normal)
        }
    }
    
    weak var delegate: PostData?
    let isPreview = !AccessManager.shared.isPreviewMode
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        handleTextField()
    }
    
    func setup() {
        label.text = isPreview ?
            "please, rate the product" :
            "please registration for start"
        
        commentTextField.isEnabled = isPreview
        
        rateView.starColor = isPreview ? .systemOrange : .gray
        rateView.isUserInteractionEnabled = isPreview
        rateView.rating = 0
        rateView.starRounding = .floorToFullStar
    }
    
    func handleTextField() {
        commentTextField.addTarget(self, action: #selector(Self.textFieldDidChenge), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChenge() {
        guard let comment = commentTextField.text, !comment.isEmpty else {
            sendButton.isEnabled = false
            return
        }
        sendButton .isEnabled = true
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        guard let message = commentTextField.text else { return }
        delegate?.post(with: message, rate: Int(rateView.rating))
        
        rateView.rating = 0
        sendButton.isEnabled = false
        commentTextField.text = nil
    }
}
