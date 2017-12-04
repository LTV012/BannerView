//
//  ViewController.swift
//  BannerView
//
//  Created by long on 2017/12/4.
//  Copyright © 2017年 long. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let bannerV = BannerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 428))
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupBannerView()
    }
    
    func setupBannerView() {
        let model1 = BannerModel()
        model1.imgUrl = "http://img07.tooopen.com/images/20171112/tooopen_sy_228261589544.jpg"
        let model2 = BannerModel()
        model2.imgUrl = "http://img07.tooopen.com/images/20171101/tooopen_sy_227694483582.jpg"
        let model3 = BannerModel()
        model3.imgUrl = "http://img07.tooopen.com/images/20171024/tooopen_sy_227083791981.jpg"
        bannerV.dataArr = Array(arrayLiteral: model1,model2,model3)
        
        bannerV.bannerViewCallBack = { index in
            print("\(index)")
        }
        
        view.addSubview(bannerV)
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

