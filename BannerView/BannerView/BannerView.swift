//
//  BannerView.swift
//  rnsCode
//
//  Created by long on 2017/11/8.
//  Copyright © 2017年 long. All rights reserved.
//

import UIKit

class BannerModel {
    ///图片资源URL
    var imgUrl : String = ""
    ///点击的链接地址
    var linkUrl : String = ""
}

class bannerCollectionCell: UICollectionViewCell {
    
    var model : BannerModel? {
        didSet{
            self.imageV.setImage(model?.imgUrl, "main_qidong")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(imageV)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageV.frame = self.bounds
    }

    lazy var imageV : UIImageView = {
        let tempImageV = UIImageView()
        tempImageV.contentMode = UIViewContentMode.scaleAspectFill
        tempImageV.clipsToBounds = true
        tempImageV.backgroundColor = UIColor.init(red: CGFloat(arc4random_uniform(256)), green: CGFloat(arc4random_uniform(256)), blue: CGFloat(arc4random_uniform(256)), alpha: 1.0)
        return tempImageV
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BannerView: UIView {
    
    let cellID = "UICollectionViewCell_BannerView"
    let kMaxSections = 3
    var bannerViewCallBack : ((_ index : Int) -> ())?
    var timer : Timer?
    
    var dataArr : Array<BannerModel> = Array() {
        didSet {
            self.removeTimer()
            self.collectionView.reloadData()
            self.pageControl.numberOfPages = dataArr.count
            self.pageControl.hidesForSinglePage = true
            if dataArr.count > 1 {
                self.collectionView.isScrollEnabled = true
                self.addTimer()
            }else{
                self.collectionView.isScrollEnabled = false
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(collectionView)
        self.addSubview(pageControl)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.collectionView.frame = self.bounds
        let centerPage = CGPoint(x: self.center.x, y: self.bounds.size.height - 16)
        self.pageControl.center = centerPage
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.superview == nil {
            self.removeTimer()
        }
    }
    
    deinit {
        self.collectionView.delegate = nil
        self.collectionView.dataSource = nil
    }
    //懒加载
    lazy var collectionView : UICollectionView = {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.itemSize = CGSize(width: self.frame.size.width, height: self.frame.size.height)
        
        let collectionV = UICollectionView(frame: self.bounds, collectionViewLayout: flowLayout)
        collectionV.backgroundColor = UIColor.white
        collectionV.isPagingEnabled = true
        collectionV.showsHorizontalScrollIndicator = false
        collectionV.dataSource = self
        collectionV.delegate = self
        collectionV.register(bannerCollectionCell.self, forCellWithReuseIdentifier: cellID)
        return collectionV
    }()
    
    lazy var pageControl : UIPageControl = {
        let pageC = UIPageControl()
        pageC.currentPageIndicatorTintColor = UIColor.black
        pageC.pageIndicatorTintColor = UIColor.red
        return pageC
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BannerView : UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return kMaxSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! bannerCollectionCell
        cell.model = self.dataArr[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard bannerViewCallBack != nil else { return }
        self.bannerViewCallBack!(indexPath.item)
    }
    
    //当用户即将开始拖拽的时候调用
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.isKind(of: UICollectionView.self) {
            self.removeTimer()
            _ = self.resetIndexPath()
        }
    }
    
    //当用户停止拖拽的时候调用
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.isKind(of: UICollectionView.self) {
            self.addTimer()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //获取下一页
        if scrollView.isKind(of: UICollectionView.self) {
            if self.dataArr.count > 0 && scrollView.bounds.size.width > 0{
                let page = Int(scrollView.contentOffset.x / scrollView.bounds.size.width + 0.5) % self.dataArr.count
                self.pageControl.currentPage = page
            }
        }
    }
}

///内部调用
extension BannerView {
    
    fileprivate func reloadData(){
        self.collectionView.reloadData()
    }
   
    @objc fileprivate func nextPage(){
        
        //获得当前显示的中间那组数据
        let currentIndextPathReset = self.resetIndexPath()
        guard currentIndextPathReset != nil else { return }
        //计算出下一个需要展示的位置
        var nextItem = currentIndextPathReset!.item + 1
        var nextSection = currentIndextPathReset!.section
        if nextItem == self.dataArr.count {
            //如果滚动完了某一组，就回到下一组的起点，组数加1
            nextItem = 0
            nextSection = nextSection + 1
        }
        //计算下一个需要展示的位置
        let nextIndexPath = IndexPath(item: nextItem, section: nextSection)
        //滚动到下一组
        self.collectionView.scrollToItem(at: nextIndexPath, at: UICollectionViewScrollPosition.left, animated: true)
    }
    
    //定位到中间那一组的图片位置
    fileprivate func resetIndexPath() -> IndexPath?{
        //获取正在展示的位置
        let currentIndexPath = self.collectionView.indexPathForItem(at: CGPoint(x: self.collectionView.contentOffset.x + 1, y: 0))
        
        guard currentIndexPath != nil else { return nil }
        
        let currentIndexPathReset = IndexPath(item: (currentIndexPath?.item)!, section: kMaxSections / 2)
        
        self.collectionView.scrollToItem(at: currentIndexPathReset, at: UICollectionViewScrollPosition.left, animated: false)
        
        self.pageControl.currentPage = (currentIndexPath?.item)! % self.dataArr.count
        return currentIndexPathReset
    }
}

///供外部调用
extension BannerView {

    ///添加定时器
    func addTimer() {
        if self.timer == nil && self.dataArr.count > 1 {
            self.timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(BannerView.nextPage), userInfo: nil, repeats: true)
            RunLoop.main.add(self.timer!, forMode: RunLoopMode.commonModes)
        }
    }
    
    ///移除定时器
    func removeTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}
