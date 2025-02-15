//
//  SAHistoryViewController.swift
//  SAHistoryNavigationViewController
//
//  Created by 鈴木大貴 on 2015/03/26.
//  Copyright (c) 2015年 鈴木大貴. All rights reserved.
//

import UIKit

protocol SAHistoryViewControllerDelegate: class {
    func historyViewController(_ viewController: SAHistoryViewController, didSelectIndex index: Int)
}

class SAHistoryViewController: UIViewController {
    //MARK: static constants
    fileprivate struct Const {
        static let lineSpace: CGFloat = 20.0
        static let reuseIdentifier = "Cell"
    }
    
    //MARK: - Properties
    weak var delegate: SAHistoryViewControllerDelegate?
    weak var contentView: UIView?
    let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    var images: [UIImage]?
    var currentIndex: Int = 0
    
    fileprivate var selectedIndex: Int?
    fileprivate var isFirstLayoutSubviews = true
    
    //MARKL: - Initializers
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.handleOrientationChanged), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    deinit {
        contentView?.removeFromSuperview()
        contentView = nil
    }
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }
        
        StoreStruct.historyBool = true

        // Do any additional setup after loading the view.
        if let contentView = contentView {
            view.addLayoutSubview(contentView, andConstraints:
                contentView.top,
                contentView.bottom,
                contentView.left,
                contentView.right
            )
        }
        view.backgroundColor = contentView?.backgroundColor
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Const.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        
        view.addLayoutSubview(collectionView, andConstraints: 
            collectionView.top,
            collectionView.bottom,
            collectionView.centerX,
            collectionView.width |==| view.width |*| 3
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isFirstLayoutSubviews {
            scrollToIndex(currentIndex, animated: false)
            isFirstLayoutSubviews = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func handleOrientationChanged() {
        collectionView.collectionViewLayout.invalidateLayout()
    }

    //MARK: - Scroll handling
    fileprivate func scrollToIndex(_ index: Int, animated: Bool) {
        collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: animated)
    }
    
    func scrollToSelectedIndex(_ animated: Bool) {
        guard let index = selectedIndex else { return }
        scrollToIndex(index, animated: animated)
    }
}

//MARK: - UICollectionViewDataSource
extension SAHistoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Const.reuseIdentifier, for: indexPath)
        
        let subviews = cell.subviews
        subviews.forEach {
            guard let view = $0 as? UIImageView else { return }
            view.removeFromSuperview()
        }
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = images?[indexPath.row]
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        cell.addLayoutSubview(imageView, andConstraints:
            imageView.top,
            imageView.bottom,
            imageView.left,
            imageView.right
        )
        
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension SAHistoryViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let windowSize = self.view.window?.bounds.size ?? UIScreen.main.bounds.size
        let imageSize = images?[indexPath.row].size ?? windowSize
        let ratio = windowSize.height / imageSize.height
        return CGSize(width: min(windowSize.width, imageSize.width * ratio), height: windowSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Const.lineSpace
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Const.lineSpace
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let size = self.view.window?.bounds.size ?? UIScreen.main.bounds.size
        return UIEdgeInsets(top: 0.0, left: size.width, bottom: 0.0, right: size.width)
    }
}

//MARK: - UICollectionViewDelegate
extension SAHistoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }
        
        collectionView.deselectItem(at: indexPath, animated: false)
        let index = indexPath.row
        selectedIndex = index
        delegate?.historyViewController(self, didSelectIndex:index)
    }
}
