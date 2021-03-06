//
//  ProfileViewController.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/26/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import IGListKit
import Nuke

protocol ProfileViewControllerDelegate: class {
    func updateBasedOnScroll(_ offset: CGFloat, backgroundPhotoView: ProfileBackgroundHeader)
}

final class ProfileViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
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
    var ownProfile = randomBool()
    weak var delegate: ProfileViewControllerDelegate?
    
    private let refreshControl = UIRefreshControl()
    var attemptingReload = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.alpha = 0
        self.backgroundPhotoView.alpha = 0
        self.setupRefresh()
        self.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavigationBarBkgd()
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

// MARK: Initial Setup
extension ProfileViewController {
    func setupRefresh() {
        self.refreshControl.bounds.origin.y -= 20
        self.refreshControl.tintColor = Colors().white
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to load new profile", attributes: [.font: LatoFont().bold, .foregroundColor: Colors().white])
        self.refreshControl.addTarget(self, action: #selector(self.initiateReload), for: .valueChanged)
    }
    
    func loadData() {
        self.ownProfile = randomBool()
        self.backgroundPhotoView.changePhotoView.isHidden = !self.ownProfile
        self.dataModel = ProfileDataModel(ownProfile: self.ownProfile)
        self.dataModel.delegate = self
    }
    
    @objc func initiateReload() {
        self.attemptingReload = true
        self.refreshControl.endRefreshing()
    }
    
    func reloadData() {
        self.attemptingReload = false
        self.backgroundPhotoView.fade(.viewOut)
        self.collectionView.fade(.viewOut, completion: { finished in
            self.dataModel.removeDataInSection(.profileDetails)
            self.loadData()
        })
    }
    
    func setupLayouts() {
        let backgroundHeight = self.view.frame.width/2
        self.backgroundPhotoViewHeightConstraint.constant = backgroundHeight
        self.collectionView.scrollIndicatorInsets.top = backgroundHeight - self.navHeaderHeight()
    }
    
    func setupBlurView() {
        self.backgroundPhotoView.imageBlurView = ProfileBackgroundBlurView(profileBackgroundView: self.backgroundPhotoView)
    }
    
    func navHeaderHeight() -> CGFloat {
        return UIApplication.shared.statusBarFrame.height + 44
    }
}

// MARK: List Adapter Data
extension ProfileViewController: ListAdapterDataSource {
    func updateMainAdapter() {
        self.adapter.performUpdates(animated: true) { (finished) in
            if self.dataModel.profileDetails != nil {
                self.collectionView.fade(.viewIn)
                self.backgroundPhotoView.fade(.viewIn)
            }
            
            self.updateThreshold()
            self.refreshControl.removeFromSuperview()
            self.collectionView.insertSubview(self.refreshControl, at: 0)
            self.dataModel.items?.gettingData = false
        }
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return self.dataModel.getData()
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is ProfileDetailsData {
            let sectionController = ProfileInfoSectionController()
            sectionController.backgroundImageHeight = self.backgroundPhotoViewHeightConstraint.constant - self.navHeaderHeight()
            
            // In case section wasn't created yet when trying to set this previously
            sectionController.backgroundImageAttrURLString = self.dataModel.profileDetails?.backgroundImageAttrURLString
            
            return sectionController
        } else if object is ItemsData {
            let sectionController = ItemsListSectionController()
            self.dataModel.items?.updateDelegate = sectionController
            return sectionController
        }
        return ListSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }
}

// MARK: Scroll
extension ProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let backgroundMinusHeader = self.view.frame.width/2 - self.navHeaderHeight()
        let offset = scrollView.contentOffset.y
        let framesOffset = offset - backgroundMinusHeader
        
        self.updateFrames(framesOffset)
        
        self.dataModel.checkThreshold(offset)
        
        self.scrubAnimations(offset)
        self.delegate?.updateBasedOnScroll(offset, backgroundPhotoView: self.backgroundPhotoView)
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
    
    func updateThreshold() {
        self.dataModel.threshold = self.collectionView.contentSize.height - 2500
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.attemptingReload && scrollView.contentOffset.y == 0 {
            self.reloadData()
        }
    }
}

// MARK: Delegate
extension ProfileViewController: ProfileDataModelDelegate {
    func bkgdImageLoaded(_ urlString: String?) {
        DispatchQueue.main.async {
            if let url = URL(string: urlString ?? "") {
                Nuke.loadImage(with: url, into: self.backgroundPhotoView.imageView)
            }
        }
    }
    
    func dataLoaded() {
        DispatchQueue.main.async {
            self.backgroundPhotoView.profileNameLabel.text = self.dataModel.profileDetails?.fullName
            self.backgroundPhotoView.updatePhotoAttribution(name: self.dataModel.profileDetails?.backgroundImageAttrName)
            
            if let profileSectionController = self.adapter.sectionController(forSection: 0) as? ProfileInfoSectionController {
                profileSectionController.backgroundImageAttrURLString = self.dataModel.profileDetails?.backgroundImageAttrURLString
            }
            
            self.updateMainAdapter()
        }
    }
}
