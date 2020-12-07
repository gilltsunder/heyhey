//
//  MainCollectionViewController.swift
//  heyhey
//
//  Created by Vlad Tretiak on 05.12.2020.
//

import UIKit

class MainCollectionViewController: UICollectionViewController {
    
    class func instantiate() -> Self {
        let controller: Self = .instantiate("Main", "MainCollectionViewController")
        return controller
    }
    
    let networkService = NetworkService()
    var productData = [ProductModel]()
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        fetchData()
    }
    
    private func config() {
        title = "Products"
        view.backgroundColor = .black
        collectionView.registerWithNib(ProductCollectionViewCell.self)
        
        let title = AccessManager.shared.isPreviewMode ? "registr" : "Logout"
        let logoutBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(logoutUser))
        self.navigationItem.leftBarButtonItem  = logoutBarButtonItem
    }
    
    @objc func logoutUser() {
        let contr = SignInViewController.instantiate()
        contr.modalPresentationStyle = .fullScreen
        present(contr, animated: true, completion: nil)
    }
    
    private func fetchData() {
        networkService.request(router: .getProducts, model: [ProductModel].self) { [weak self] (result) in
            guard let data = result else { return }
            self?.productData = data
            self?.collectionView.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productData.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: ProductCollectionViewCell.self, for: indexPath)
        cell.configure(with: productData[indexPath.row])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let contr = ProductViewController.instantiate(with: productData[indexPath.row])
        contr.modalPresentationStyle = .fullScreen
        present(contr, animated: true, completion: nil)
        //        self.navigationController?.pushViewController(contr, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 8
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.black.cgColor
    }
}

extension MainCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = collectionView.bounds
        return CGSize(width: bounds.width/2 - 20, height: bounds.height/4)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
