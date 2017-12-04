//
//  UIImageView+Extension.swift
//  rnsCode
//
//  Created by long on 2017/11/9.
//  Copyright © 2017年 long. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView{
    
    //设置网络图片
    func setImage(_ URLString : String?, _ placeHolderName : String?) {
        
        guard let URLString = URLString else { return }

        guard let placeHolderName = placeHolderName else { return }

        guard let url = URL(string: URLString) else { return }

        kf.setImage(with: url, placeholder : UIImage(named: placeHolderName))
    }
}
