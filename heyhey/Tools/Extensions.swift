//
//  Extensions.swift
//  heyhey
//
//  Created by Vlad Tretiak on 05.12.2020.
//

import Foundation
import UIKit

extension UIViewController {
    class func instantiate<T>(_ storyboardName: String, _ identifier: String = "\(T.self)") -> T {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier) as! T
    }
}

//MARK: UITableView & UITableViewCell & UITableViewHeaderFooterView
extension UITableViewCell {
    @objc class var reusableNibName: String { reusableIdentifier }
    @objc class var reusableBundleName: String? { nil }
    @objc class var reusableIdentifier: String { "\(Self.self)" }
}

extension UITableViewHeaderFooterView {
    @objc class var reusableNibName: String { reusableIdentifier }
    @objc class var reusableBundleName: String? { nil }
    @objc class var reusableIdentifier: String { "\(Self.self)" }
}

extension UITableView {
    func register<T: UITableViewCell>(_ classType: T.Type) {
        register(classType, forCellReuseIdentifier: classType.reusableIdentifier)
    }
    
    func registerWithNib<T: UITableViewCell>(_ classType: T.Type) {
        var bundle: Bundle?
        if let bundleName = classType.reusableBundleName {
            bundle = Bundle(identifier: bundleName)
        }
        let nib = UINib(nibName: classType.reusableNibName, bundle: bundle)
        register(nib, forCellReuseIdentifier: classType.reusableIdentifier)
    }
    
    func registerWithNib<T: UITableViewHeaderFooterView>(headerFooterViewClassWith name: T.Type) {
        var bundle: Bundle?
        if let bundleName = name.reusableBundleName {
            bundle = Bundle(identifier: bundleName)
        }
        let nib = UINib(nibName: name.reusableNibName, bundle: bundle)
        register(nib, forHeaderFooterViewReuseIdentifier: name.reusableIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(withClass name: T.Type) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: name.reusableIdentifier) as? T else {
            fatalError(
                "Couldn't find UITableViewCell for \(name.reusableIdentifier)," +
                " make sure the cell is registered with table view")
        }
        return cell
    }
    
    func dequeueReusableCell<T: UITableViewCell>(_ classType: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: classType.reusableIdentifier, for: indexPath) as? T else {
            fatalError(
                "Couldn't find UITableViewCell for \(classType.reusableIdentifier)," +
                " make sure the cell is registered with table view")
        }
        return cell
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(withClass name: T.Type) -> T {
        guard let headerFooterView = dequeueReusableHeaderFooterView(withIdentifier: name.reusableIdentifier) as? T else {
            fatalError(
                "Couldn't find UITableViewHeaderFooterView for \(name.reusableIdentifier)," +
                " make sure the view is registered with table view")
        }
        return headerFooterView
    }
}

//MARK: UICollectionView & UICollectionViewCell
extension UICollectionViewCell {
    @objc class var reusableNibName: String { reusableIdentifier }
    @objc class var reusableBundleName: String? { nil }
    @objc class var reusableIdentifier: String { "\(Self.self)" }
}

extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(withClass name: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: name.reusableIdentifier, for: indexPath) as? T else {
            fatalError(
                "Couldn't find UICollectionViewCell for \(name.reusableIdentifier)," +
                " make sure the cell is registered")
        }
        return cell
    }
    
    func register<T: UICollectionViewCell>(_ classType: T.Type) {
        register(classType, forCellWithReuseIdentifier: classType.reusableIdentifier)
    }
    
    func registerWithNib<T: UICollectionViewCell>(_ classType: T.Type) {
        var bundle: Bundle?
        if let bundleName = classType.reusableBundleName {
            bundle = Bundle(identifier: bundleName)
        }
        let nib = UINib(nibName: classType.reusableNibName, bundle: bundle)
        register(nib, forCellWithReuseIdentifier: classType.reusableIdentifier)
    }
}

//MARK: UIImageView
extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    
    func downloaded(with link: String) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url)
    }
}


