//
//  ZlStatusViewModel.swift
//  ZhylfWeibo
//
//  Created by 张彦林 on 2017/12/15.
//  Copyright © 2017年 zhangyanlf. All rights reserved.
//

import Foundation

/// 单条微博的试图模型
/**
 如果没有任何父类  如果希望在开发时调试 书出台需要输出信息 需要
 1.遵守 CustomStringConvertible
 2.实现 description 计算性属性
 
 关于表格的性能优化
 - 尽量少计算， 所有需要的素材提前计算好
 - 控件不要设置圆角半径  图片渲染的属性都要注意
 - 不要动态创建组件  所有需要的控件 都要提前创建好 在现实的时候 根据数据显示/隐藏
 - cell中控件的数量越少越好
 - 要测量 不要猜测
 */
class ZlStatusViewModel: CustomStringConvertible {
    
    /// 微博模型
    var status: ZlStatus
    
   /// vip图标
    /// 会员等级数 0-6
    var vipmberIcon: UIImage?
    
    /// 认证图标
    /// 认证类型 -1：没有认证 0：认证 2，3，5企业用户 220：达人
    var memberIcon: UIImage?
    
    /// 转发文字 有的话显示数字 没有的话显示转发
    var retweetStr: String?
    
    /// 微博来源字符转
    var sourceStr: NSString?
    
    /// 评论数
    @objc var commentsStr: String?
    /// 表态数
    @objc var attitudesStr: String?
    
    /// 配图试图大小
    var pictureViewSize = CGSize()
    
    /// 如果是被转发的  原创的一定没有图
    var pic_Urls: [ZlStatusPicture]? {
        //如果有被转发微博 返回被转发试图配图
        //如果没有被转发微博 返回原创微博试图配图
        //如果都没有  返回nil
        return status.retweeted_status?.pic_urls ?? status.pic_urls
    }
    /// 被转发文字
    var retweetedText: NSString?

    /// 行高
    var rowHeight: CGFloat = 0
    
    /// 构造函数
    ///
    /// - Parameter model: 微博模型
    /// - returns: 微博的试图模型
    init(model: ZlStatus) {
        self.status = model
        
        //common_icon_membership_level1
        //会员等级数 0-6
         if (model.user?.mbrank) ?? 0 > 0 && ((model.user?.mbrank)) ?? 0 < 7{
            let inageName = "common_icon_membership_level\(model.user?.mbrank ?? 1)"
            vipmberIcon = UIImage(named: inageName)
         } else {
            let inageName = "common_icon_membership_expired"
            vipmberIcon = UIImage(named: inageName)
           
        }
        ///认证图标
        switch model.user?.verified_type ?? -1 {
        case 0:
            memberIcon = UIImage(named: "avatar_vip")
        case 2,3,5:
            memberIcon = UIImage(named: "avatar_enterprise_vip")
        case 220:
            memberIcon = UIImage(named: "avatar_grassroot")
        default:
            break
        }
        ///设置底部计数字符串
        //测试计算大于10000
        //model.comments_count = Int64(Int(arc4random_uniform(100000)))
        retweetStr = countString(count: Int(model.reposts_count), defaultStr: "转发")
        commentsStr = countString(count: Int(model.comments_count), defaultStr: "评论")
        attitudesStr = countString(count: Int(model.attitudes_count), defaultStr: "赞")
        
        ///计算配图大小 有原创的就计算原创的  有转发的就计算转发的
        pictureViewSize = calaPictureViewSize(count: (pic_Urls?.count)!)
        ///设置被转发微博的文字
        retweetedText = "@" + ((status.retweeted_status?.user?.screen_name ?? "")! as String) + ":" + (status.retweeted_status?.text ?? "") as NSString
        //设置来源字符串
        sourceStr = "来自" + ((model.source as String?)?.zl_href()?.text ?? "") as NSString
        
        ///计算行高
        updateRowHeight()
    }
    
    var description: String {
        return status.description
    }
    
    /// 根据当前的试图模型内容计算行高
    func updateRowHeight() {
        //原创微博：顶部分割试图（12）+ 间距(12) + 图像高度(34) + 间距(12) + 正文高度(需要计算) + 配图试图高度(计算) + 间距（12）+ 底部试图间距（35）
        //转发微博：顶部分割试图（12）+ 间距(12) + 图像高度(34) + 间距(12) + 正文高度(需要计算) + 配图试图高度(计算) + 间距（12）+ 间距（12）+ 转发微博文本高度(需要计算) + + 配图试图高度(计算) + 间距（12）+ 底部试图间距（35）
        let margin: CGFloat = 12
        let iconHeight: CGFloat = 34
        let toolBarHeight: CGFloat = 35
        
        var height: CGFloat = 0
        
        let viewSize = CGSize(width: UIScreen.cz_screenWidth() - 2 * margin, height: CGFloat(MAXFLOAT))
        let originalFont = UIFont.systemFont(ofSize: 15)
        let retweetedFont = UIFont.systemFont(ofSize: 14)
        
        
        //1>计算顶部位置
        height = 2 * margin + iconHeight + margin
        //2>正文高度
        /**计算多行文本
         1>预期尺寸 宽度固定  高度尽量大
         2>选项换行文件同意使用usesLineFragmentOrigin
         3>指定字体字典
         */
        if let text = status.text {
            height += (text as NSString).boundingRect(with: viewSize,
                                                      options: [.usesLineFragmentOrigin],
                                                      attributes: [NSAttributedStringKey.font : originalFont],
                                                      context: nil).height
        }
        //3>判断是否转发微博
        if status.retweeted_status != nil {
            height += 2 * margin
            
            //转发微博文字高度  -- 一定要用 retweetedText 拼接 @用户名：微博文字
            if let text = retweetedText {
                height += (text as NSString).boundingRect(with: viewSize,
                                                          options: [.usesLineFragmentOrigin],
                                                          attributes: [NSAttributedStringKey.font : retweetedFont],
                                                          context: nil).height
            }
        }
        
        //4>配图试图
        height += pictureViewSize.height
        height += margin
        
        //底部工具栏
        height += toolBarHeight
        
        //使用属性记录
        rowHeight = height
    }
    
    
    /// 使用单个图像跟新配图试图的大小
    ///
    /// 新浪针对单张图片 都是缩率图  但是偶尔会有一张特别大的图 7000 * 9000多
    /// 支持长微博 但是有时候有特别长的 长到宽度只有1个点
    /// - Parameter image: 网络缓存的单张图片
    func updateSingleImageSize(image: UIImage) {
        var size = image.size
        ///过宽图像处理
        let maxWidth: CGFloat = 300
        let minWidth: CGFloat = 40
        //过宽图像处理
        if size.width > maxWidth {
            //设置最大宽度
            size.width = maxWidth
            //等比例调整宽度
            size.height = size.width * image.size.height / image.size.width
        }
        ///过窄图片处理
        if size.width < minWidth {
            //设置最大宽度
            size.width = minWidth
            //等比例调整宽度  要特殊处理高度
            size.height = size.width * image.size.height / image.size.width / 4
        }
        
        //尺寸要增加顶部的12个点 便于布局
        size.height += ZlStatusPictureViewOutterMargin
        ///从新设置配图试图大小
        pictureViewSize = size
        
        //更新行高
        updateRowHeight()
    }
    
    /// 计算指定数量的图片对应的配图试图的大小
    ///
    /// - Parameter count: 配图数量
    /// - Returns: 配图试图的大小
    private func calaPictureViewSize(count: Int?) -> CGSize {
       if count == 0 || count == nil {
            return CGSize()
        }
        
        //1.计算配图试图的宽度

        //计算高度
        //1>根据 count 计算 知道行数（1-9）
        /**
         1 2 3 = 0 1 2 / 3 = 0 + 1 = 1
         4 5 6 = 3 4 5 / 3 = 1 + 1 = 2
         7 8 9 = 6 7 8 / 3 = 2 + 1 = 3
         */
        let row = (count! - 1) / 3 + 1
        
        //2> 根据行数算高度
        var height = ZlStatusPictureViewOutterMargin
        height += CGFloat(row) * ZlStatusPictureItemWidth
        height += CGFloat(row - 1) * ZlStatusPictureViewInnerMargin
        
        
        return CGSize(width: ZlStatusPictureViewWidth, height: height)
    }
    
    /// 给定一个数字，返回对于的描述结果
    ///
    /// - Parameters:
    ///   - count: 数字
    ///   - defaultStr: 默认文字
    /// - Returns: 返回的描述结果
    /**
     count == 0 显示默认标题
     count > 10000 显示x.xx万
     count < 10000 显示原数字
     */
    private func countString (count: Int, defaultStr: String) -> String {
        if count == 0 {
            return defaultStr
        }
        if count < 10000 {
            return count.description
        }
        return String(format: "%.02f 万", Double(count) / 10000)
    }
    
}
