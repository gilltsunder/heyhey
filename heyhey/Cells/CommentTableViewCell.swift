//
//  CommentTableViewCell.swift
//  heyhey
//
//  Created by Vlad Tretiak on 06.12.2020.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var userNameLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var rateView: StarRatingView! {
        didSet {
            rateView.isUserInteractionEnabled = false
            rateView.starRounding = .roundToFullStar
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.shadowOffset = CGSize(width: -1, height: 1)
        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.backgroundColor = .white
        
    }
    
    func configure(with data: CurrentProductModel) {
        userNameLabel.text = data.createdBy?.username
        rateView.rating = Float(data.rate ?? 0)
        descriptionLabel.text = data.text
    }
    
}
