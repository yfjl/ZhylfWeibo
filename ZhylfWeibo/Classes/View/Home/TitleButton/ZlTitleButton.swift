//
//  ZlTitleButton.swift
//  ZhylfWeibo
//
//  Created by 张彦林 on 2017/12/13.
//  Copyright © 2017年 zhangyanlf. All rights reserved.
//

import UIKit

class ZlTitleButton: UIButton {
    ///如果title为nil显示首页 不为nil显示用户名
     init(title: String?) {
        super.init(frame: CGRect())
        //1.判断title是否为nil
        if title == nil {
            setTitle("首页", for: .normal)
        } else {
            setTitle(title! + "   ", for: .normal)
            //设置图像
            setImage(UIImage(named: "navigationbar_arrow_down"), for: .normal)
            //setImage(UIImage(named: "navigationbar_arrow_up"), for: .highlighted)
            setImage(UIImage(named: "navigationbar_arrow_up"), for: .selected)
        }
        //2.设置字体和颜色
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        setTitleColor(UIColor.darkGray, for: .normal)
        //3.设置大小
        sizeToFit()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return UILayoutFittingExpandedSize
    }
    
    //自定义UI 布局调整
    override func layoutSubviews() {
        super.layoutSubviews()//一定要有super
        guard let titleLabel = titleLabel,
            let imageView = imageView  else {
                return
        }
        //label的x向左移动image宽度 image的x向右移动label宽度
        
        titleLabel.frame.origin.x = 0
        
        imageView.frame.origin.x = titleLabel.bounds.width
        
        //label的x向左移动image宽度 image的x向右移动label宽度
//        self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageView.bounds.width, 0, 0)
//        self.imageEdgeInsets = UIEdgeInsetsMake(0, titleLabel.bounds.width, 0, 0)
        
    
    }
    
   
}
