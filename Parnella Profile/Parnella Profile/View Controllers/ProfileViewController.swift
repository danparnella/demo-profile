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
    
    var profileModel: ProfileVM!
    
    init(othersProfile: Friend? = nil, isBlogger: Bool = false) {
        super.init(nibName: ProfileViewController.reuseIdentifier, bundle: nil)
        if !isBlogger {
            self.profileModel = ProfileVM(othersProfile: othersProfile)
            self.profileModel.delegate = self
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeBackButtonTitle()
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
            self.collectionViewTopConstraint.constant = NAV_HEADER_HEIGHT
        }
        //        self.collectionView.contentInset.top = backgroundHeight - NAV_HEADER_HEIGHT
        self.collectionView.scrollIndicatorInsets.top = backgroundHeight - NAV_HEADER_HEIGHT
    }
    
    func setupBlurView() {
        self.backgroundPhotoView.imageBlurView = ProfileBackgroundBlurView(profileBackgroundView: self.backgroundPhotoView)
    }
}

//MARK: LIST ADAPTER DATA
extension ProfileViewController: ListAdapterDataSource {
    func updateMainAdapter() {
        self.adapter.performUpdates(animated: true) { (finished) in
            self.updateThreshold()
        }
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return self.profileModel.getData().filter({ !($0 is ListsDataModel) })
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is ProfileVMProfileData:
            let sectionController = ProfileInfoSectionController()
            sectionController.backgroundImageHeight = self.backgroundPhotoViewHeightConstraint.constant - NAV_HEADER_HEIGHT
            sectionController.ownProfile = (self.profileModel.profileType == .own)
            return sectionController
        //        case is ListsDataModel:
        case is ItemsListSection:
            let sectionController = ListsTodosSectionController()
            self.profileModel.todosDataVM.paginationDelegate = sectionController
            
            return sectionController
        default:
            return ListSectionController()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }
}

//MARK: SCROLL
extension ProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset = self.collectionView.contentOffset.y - (self.view.frame.width/2 - NAV_HEADER_HEIGHT)
        self.updateFrames(offset)
        
        self.profileModel.checkThreshold(offset)
        
        offset += (self.view.frame.width/2 - NAV_HEADER_HEIGHT)
        self.scrubAnimations(offset)
    }
    
    func updateFrames(_ offset: CGFloat) {
        self.backgroundPhotoViewHeightConstraint.constant = (offset <= 0) ? -(offset - NAV_HEADER_HEIGHT) : NAV_HEADER_HEIGHT
        self.collectionView.scrollIndicatorInsets.top = (offset <= 0) ? -offset : 0
        self.view.layoutSubviews()
    }
    
    func scrubAnimations(_ offset: CGFloat) {
        self.backgroundPhotoView.imageBlurView?.scrubAnimator(scrollViewOffset: offset)
        self.backgroundPhotoView.scrubChangePhotoAlpha(scrollViewOffset: offset)
    }
    
    func updateThreshold() {
        self.profileModel.threshold += (self.collectionView.contentSize.height - self.profileModel.threshold) * 0.6
    }
}

//MARK: DELEGATE
extension ProfileViewController: ProfileVMLoadDataDelegate {
    func loadData() {
        if let profileDetails = self.profileModel.profileVCDataModel.profileDetails {
            if let url = URL(string: profileDetails.backgroundURL) {
                NetworkImageManager.shared().commonManager.loadImage(with: url, into: self.backgroundPhotoView.imageView)
            } else {
                self.backgroundPhotoView.imageView.image = #imageLiteral(resourceName: "ProfileDefaultBackground")
            }
        }
        
        self.updateMainAdapter()
    }
}
