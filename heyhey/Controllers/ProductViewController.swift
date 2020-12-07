//
//  ProductViewController.swift
//  heyhey
//
//  Created by Vlad Tretiak on 06.12.2020.
//

import UIKit

protocol PostData: class {
    func post(with data: String, rate: Int)
}

class ProductViewController: UIViewController, PostData {
    
    class func instantiate(with model: ProductModel) -> Self {
        let controller: Self = .instantiate("Main", "ProductViewController")
        controller.productData = model
        return controller
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var dispasable: Dispossable?
    var productData: ProductModel?
    let networkService = NetworkService()
    var currentProductData = [CurrentProductModel]()
    
    var productView = ProductView()
    var dismissButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.red, for: .normal)
        button.setTitle("Back", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchCurrentProduct()
        configureProduct()
    }
    
    func configureUI() {
        view.addSubview(productView)
        let rect = CGRect(x: 0, y: 0, width: view.frame.width, height: 200)
        productView.frame = rect
        
        view.addSubview(dismissButton)
        view.bringSubviewToFront(dismissButton)
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            dismissButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15)
        ])
        dismissButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        
        tableView.contentInset = UIEdgeInsets(top: 400, left: 0, bottom: 0, right: 0)
        tableView.registerWithNib(CommentTableViewCell.self)
        tableView.registerWithNib(NewCommentTableViewCell.self)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    
    @objc func backButtonTapped(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func configureProduct() {
        productView.titleLabel.text = productData?.text
        productView.descriptionLabel.text = productData?.text
        
        guard let path = productData?.img else { return }
        dispasable = DownloadMediaService.shared.fetchMedia(with: path, progressBlock: { _ in
        }, completionBlock: { [weak self] error, url in
            if let url = url {
                let image = UIImage(contentsOfFile: url.path)
                DispatchQueue.main.async {
                    self?.productView.image.image = image
                }
            }
        })
    }
    
    func fetchCurrentProduct() {
        guard let productId = productData?.id else { return }
        networkService.request(router: .getCurrentProduct(path: String(productId)), model: [CurrentProductModel].self) { [weak self] (data) in
            guard let data = data else { return }
            self?.currentProductData = data
            self?.tableView.reloadData()
        }
    }
    
    func post(with data: String, rate: Int) {
        print("data: \(data) and: \(rate)")
        guard let id = productData?.id else { return }
        networkService.request(router: .postComment(path: String(id), comment: data, rate: rate), model: PostResponse.self) { [weak self] (result) in
            guard result != nil else {
                let alert = UIAlertController(title: "some error", message: "try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
                self?.present(alert, animated: true)
                return
            }
            self?.fetchCurrentProduct()
        }
    }
}

extension ProductViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return currentProductData.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(NewCommentTableViewCell.self, for: indexPath)
            cell.delegate = self
            cell.selectionStyle = .none
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(CommentTableViewCell.self, for: indexPath)
            cell.configure(with: currentProductData[indexPath.section - 1])
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        2
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        12
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = 200 - (scrollView.contentOffset.y + 200)
        let h = max(200, y)
        let rect = CGRect(x: 0, y: 0, width: view.bounds.width, height: h)
        productView.frame = rect
    }
}
