//
//  ProfileViewController.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/26/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import IGListKit

final class ProfileViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundPhotoView: ProfileBackgroundHeader!
    @IBOutlet weak var backgroundPhotoViewHeightConstraint: NSLayoutConstraint!
    
    lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)
        adapter.dataSource = self
        adapter.collectionView = self.collectionView
        adapter.scrollViewDelegate = self
        return adapter
    }()
    
    var dataModel: ProfileDataModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataModel = ProfileDataModel()
        self.dataModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.backgroundPhotoView.imageBlurView?.restartAnimator()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.backgroundPhotoView.imageBlurView == nil {
            self.setupLayouts()
            self.setupBlurView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.backgroundPhotoView.imageBlurView?.stopAnimator()
    }
}

//MARK: INITIAL SETUP
extension ProfileViewController {
    func setupLayouts() {
        let backgroundHeight = self.view.frame.width/2
        self.backgroundPhotoViewHeightConstraint.constant = backgroundHeight
        
        if #available(iOS 11.0, *) {
        } else {
            self.collectionViewTopConstraint.constant = self.navHeaderHeight()
        }
        self.collectionView.scrollIndicatorInsets.top = backgroundHeight - self.navHeaderHeight()
    }
    
    func setupBlurView() {
        self.backgroundPhotoView.imageBlurView = ProfileBackgroundBlurView(profileBackgroundView: self.backgroundPhotoView)
    }
    
    func navHeaderHeight() -> CGFloat {
        return UIApplication.shared.statusBarFrame.height + 44
    }
}

//MARK: LIST ADAPTER DATA
extension ProfileViewController: ListAdapterDataSource {
    func updateMainAdapter() {
        self.adapter.performUpdates(animated: true) { (finished) in
//            self.updateThreshold()
        }
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return self.dataModel.getData()
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is ProfileDetailsData {
            let sectionController = ProfileInfoSectionController()
            sectionController.backgroundImageHeight = self.backgroundPhotoViewHeightConstraint.constant - self.navHeaderHeight()
            return sectionController
        } else if object is ItemsData {
//            let sectionController = ListsTodosSectionController()
//            self.dataModel.todosDataVM.paginationDelegate = sectionController
//
//            return sectionController
        }
        return ListSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }
}

//MARK: SCROLL
extension ProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset = self.collectionView.contentOffset.y - (self.view.frame.width/2 - self.navHeaderHeight())
        self.updateFrames(offset)
        
//        self.dataModel.checkThreshold(offset)
        
        offset += (self.view.frame.width/2 - self.navHeaderHeight())
        self.scrubAnimations(offset)
    }
    
    func updateFrames(_ offset: CGFloat) {
        self.backgroundPhotoViewHeightConstraint.constant = (offset <= 0) ? -(offset - self.navHeaderHeight()) : self.navHeaderHeight()
        self.collectionView.scrollIndicatorInsets.top = (offset <= 0) ? -offset : 0
        self.view.layoutSubviews()
    }
    
    func scrubAnimations(_ offset: CGFloat) {
        self.backgroundPhotoView.imageBlurView?.scrubAnimator(scrollViewOffset: offset)
        self.backgroundPhotoView.scrubChangePhotoAlpha(scrollViewOffset: offset)
    }
    
//    func updateThreshold() {
//        self.dataModel.threshold += (self.collectionView.contentSize.height - self.dataModel.threshold) * 0.6
//    }
}

//MARK: DELEGATE
extension ProfileViewController: ProfileDataModelDelegate {
    func dataUpdated() {
        self.updateMainAdapter()
    }
//    func loadData() {
//        if let profileDetails = self.dataModel.profileVCDataModel.profileDetails {
//            if let url = URL(string: profileDetails.backgroundURL) {
//                NetworkImageManager.shared().commonManager.loadImage(with: url, into: self.backgroundPhotoView.imageView)
//            } else {
//                self.backgroundPhotoView.imageView.image = #imageLiteral(resourceName: "ProfileDefaultBackground")
//            }
//        }
//
//        self.updateMainAdapter()
//    }
}
