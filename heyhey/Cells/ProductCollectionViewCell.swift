//
//  ProductCollectionViewCell.swift
//  heyhey
//
//  Created by Vlad Tretiak on 05.12.2020.
//

import UIKit

class ProductCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    var dispasable: Dispossable?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with model: ProductModel) {
        titleLabel.text = model.title
        descriptionLabel.text = model.text
        guard let path = model.img else { return }
        
        dispasable = DownloadMediaService.shared.fetchMedia(with: path, progressBlock: { _ in
        }, completionBlock: { [weak self] error, url in
            if let url = url {
                let image = UIImage(contentsOfFile: url.path)
                DispatchQueue.main.async {
                    self?.image.image = image
                }
            }
        })
    }
}
