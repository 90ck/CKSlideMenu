//
//  CKSlideMenu.swift
//  LearnSwift
//
//  Created by ck on 2017/6/15.
//  Copyright © 2017年 caike. All rights reserved.
//

import UIKit

enum SlideMenuTitleStyle {
    case normal             //默认
    case gradient           //颜色渐变
    case transfrom          //放大
}

enum SlideMenuIndicatorStyle {
    case normal             //常规
    case followText         //跟随文本长度
    case stretch            //伸缩  默认
}

//伸缩动画的偏移量
fileprivate let indicatorAnimatePadding:CGFloat = 8.0

class CKSlideMenu: UIView {
    
    // 选中颜色
    var selectedColor:UIColor       = UIColor.red {
        didSet {
            updateColors()
        }
    }
    // 未选中颜色
    var unSelectedColor:UIColor     = UIColor.black {
        didSet {
            updateColors()
        }
    }
    // 下标宽度
    var indicatorWidth:CGFloat      = 30 {  //SlideMenuIndicatorStyle 为normal时有效
        didSet {
            setupIndicatorView()
        }
    }
    // 下标高度
    var indicatorHeight:CGFloat     = 2 {
        didSet {
            setupIndicatorView()
        }
    }
    // 下标距离底部距离
    var bottomPadding:CGFloat       = 2 {
        didSet {
            setupIndicatorView()
        }
    }
    // 标题字体
    var font:UIFont                 = UIFont.systemFont(ofSize: 13) {
        didSet {
            updateFonts()
        }
    }
    
    var indicatorStyle:SlideMenuIndicatorStyle = .stretch
    var titleStyle:SlideMenuTitleStyle = .normal
    
    var tabScrollView:UIScrollView
    var bodyScrollView:UIScrollView
    var indicatorView:UIView = UIView()
    var line:UIView = UIView()
    
    
    fileprivate var leftIndex:Int = 0
    fileprivate var rightIndex:Int = 0
    fileprivate var selectedIndex:Int = 0
    fileprivate var itemLabels:Array<UILabel>  = []
    // tab边距
    private var itemMargin:CGFloat = 15.0
    private var titlesArr:Array<String>
    private var controllers:Array<UIViewController>
    
    
    // MARK: -
    init(frame:CGRect ,titles:Array<String>, childControllers:Array<UIViewController>) {
        
        tabScrollView = UIScrollView()
        bodyScrollView = UIScrollView()
        titlesArr = titles
        controllers = childControllers
        super.init(frame: frame)
        
        setupTabScrollView()
        setupIndicatorView()
        line.backgroundColor = UIColor(white: 0.9, alpha: 1)
        self.addSubview(line)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        tabScrollView.frame = self.bounds
        line.frame = CGRect(x: 0, y: self.frame.height - 0.5, width: self.frame.width, height: 0.5)
        for item in itemLabels {
            var frame = item.frame
            frame.size.height = self.frame.height
            item.frame = frame
        }
        
        if (self.bodyScrollView.superview) == nil {
            self.superview?.addSubview(bodyScrollView)
            setupBodyScrollView()
        }
        
    }
    private func setupBodyScrollView() {
        
        bodyScrollView.showsVerticalScrollIndicator = false
        bodyScrollView.showsHorizontalScrollIndicator = false
        bodyScrollView.isPagingEnabled = true
        bodyScrollView.bounces = false
        bodyScrollView.delegate = self
        if let frame = self.superview?.frame {
            bodyScrollView.frame = CGRect(x: 0, y: self.frame.maxY, width: frame.width, height: frame.height - self.frame.maxY)
            for (i,vc) in controllers.enumerated() {
                vc.view.frame = bodyScrollView.bounds
                vc.view.center = CGPoint(x: bodyScrollView.frame.width*(CGFloat(i)+0.5), y: bodyScrollView.frame.height/2)
                bodyScrollView.addSubview(vc.view)
            }
            bodyScrollView.contentSize = CGSize(width: bodyScrollView.frame.width*CGFloat(controllers.count), height: bodyScrollView.frame.height)
        }
    }
    
    // 配置导航栏
    private func setupTabScrollView()  {
        
        tabScrollView.frame = self.bounds
        tabScrollView.showsVerticalScrollIndicator = false
        tabScrollView.showsHorizontalScrollIndicator = false
        tabScrollView.backgroundColor = UIColor.clear
        self.addSubview(tabScrollView)
        
        var originX = itemMargin
        for (index ,title) in titlesArr.enumerated() {
            
            let item = UILabel()
            item.isUserInteractionEnabled = true
            //计算title长度
            let size = (title as NSString).size(attributes: [NSFontAttributeName:font])
            item.frame = CGRect(x: originX, y: 0, width: size.width, height: self.frame.height)
            //设置属性
            item.text = title
            item.font = font
            item.textColor = index == selectedIndex ? selectedColor : unSelectedColor
            //添加tap手势
            item.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(itemClicked(gesture:))))
        
            itemLabels.append(item)
            tabScrollView.addSubview(item)
            
            originX = item.frame.maxX + 2*itemMargin
        }
        tabScrollView.contentSize = CGSize(width: originX - itemMargin, height: self.frame.height)
        tabScrollView.addSubview(indicatorView)
        
        if tabScrollView.contentSize.width < self.frame.width {
            //item长度小于width，重新计算margin排版
            self.updateLabelsFrame()
        }
    }
    
    
    //配置下标
    private func setupIndicatorView() {

        var frame = itemLabels[selectedIndex].frame
        frame.origin.y = self.frame.height - bottomPadding - indicatorHeight
        frame.size.height = indicatorHeight
        
        if indicatorStyle == .normal {
            frame.origin.x = frame.midX - indicatorWidth/2
            frame.size.width = indicatorWidth
        }
        indicatorView.frame = frame
        indicatorView.backgroundColor = selectedColor
        
    }
    
    
    // 更新itemLabels的布局
    private func updateLabelsFrame() {
        
        let newMarigin = itemMargin + (self.frame.width - tabScrollView.contentSize.width)/CGFloat(self.itemLabels.count*2)
        var originX = newMarigin
        for item in itemLabels {
            var frame = item.frame
            frame.size.height = self.frame.height
            frame.origin.x = originX
            item.frame = frame
            originX = frame.maxX + 2 * newMarigin
        }
        tabScrollView.contentSize = CGSize(width: originX - newMarigin, height: frame.height)
    }
    
    // 更新字体
    private func updateFonts() {
        
        var originX = itemMargin
        for item in itemLabels {
            //计算title长度
            let size = (item.text! as NSString).size(attributes: [NSFontAttributeName:font])
            item.frame = CGRect(x: originX, y: 0, width: size.width, height: self.frame.height)
            //设置属性
            item.font = font

            originX = item.frame.maxX + 2*itemMargin
        }
        tabScrollView.contentSize = CGSize(width: originX - itemMargin, height: self.frame.height)
        if tabScrollView.contentSize.width < self.frame.width {
            //item长度小于width，重新计算margin排版
            self.updateLabelsFrame()
        }
        setupIndicatorView()
    }
    
    // 更新颜色
    private func updateColors() {
        for item in itemLabels {
            item.textColor = unSelectedColor
        }
        itemLabels[selectedIndex].textColor = selectedColor
        indicatorView.backgroundColor = selectedColor
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //渐变颜色
    fileprivate func averageColor(fromColor:UIColor , toColor:UIColor , percent:CGFloat) -> UIColor {
        var fromRed:CGFloat = 0.0
        var fromGreen:CGFloat = 0.0
        var fromBlue:CGFloat = 0.0
        var fromAlpha:CGFloat = 0.0
        fromColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)

        var toRed:CGFloat = 0.0
        var toGreen:CGFloat = 0.0
        var toBlue:CGFloat = 0.0
        var toAlpha:CGFloat = 0.0
        toColor.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
        
        let nowRed = fromRed + (toRed - fromRed)*percent
        let nowGreen = fromGreen + (toGreen - fromGreen)*percent
        let nowBlue = fromBlue + (toBlue - fromBlue)*percent
        let nowAlpha = fromAlpha + (toAlpha - fromAlpha)*percent
        
        return UIColor(red: nowRed, green: nowGreen, blue: nowBlue, alpha: nowAlpha)
    }
    
    // 修正tabScrollView的位置
    fileprivate func resetTabScrollViewFrame() {
        let seletedItem = itemLabels[selectedIndex]
        let tab_width = tabScrollView.frame.width
        var reviseX:CGFloat = 0
        
        if seletedItem.center.x + tab_width/2 >= tabScrollView.contentSize.width {
            reviseX = tabScrollView.contentSize.width - tab_width
        }
        else if (seletedItem.center.x - tab_width/2) <= 0 {
            reviseX = 0
        }
        else {
            reviseX = seletedItem.center.x - tab_width/2
        }
        tabScrollView.setContentOffset(CGPoint(x:reviseX,y:0), animated: true)
    }
    
    
    // 导航栏点击事件
    func itemClicked(gesture:UITapGestureRecognizer) {
        let item = gesture.view as! UILabel
        if item == itemLabels[selectedIndex] {
            return
        }
        let fromIndex = selectedIndex
        selectedIndex = itemLabels.index(of: item)!
        self.changeTitleItem(from: fromIndex, to: selectedIndex)
        self.changeIndicator(from: fromIndex, to: selectedIndex)
        bodyScrollView.setContentOffset(CGPoint(x:bodyScrollView.frame.size.width*CGFloat(selectedIndex), y:0), animated: false)
        self.resetTabScrollViewFrame()
    }
    
    //点击事件触发的UI更新
    private func changeTitleItem(from:Int ,to:Int) {
        
        self.itemLabels[from].textColor = self.unSelectedColor
        self.itemLabels[to].textColor = self.selectedColor
        
        if titleStyle == .transfrom {
            UIView.animate(withDuration: 0.25, animations: {
                self.itemLabels[to].transform = CGAffineTransform.init(scaleX: 1.05, y: 1.05)
                self.itemLabels[from].transform = CGAffineTransform.identity
                
            }, completion: nil)
        }
    }
    
    //点击事件触发的UI更新
    private func changeIndicator(from:Int, to:Int) {
        let fromItem = itemLabels[from]
        let toItem = itemLabels[to]
        
        if indicatorStyle != .stretch {
            UIView.animate(withDuration: 0.3, animations: {
                self.indicatorView.center = CGPoint(x:toItem.center.x,y:self.indicatorView.center.y)
            })
        }
        else {
            var frame = indicatorView.frame
            frame.size.width = itemLabels[to].frame.width
            
            let finnalFrame = frame
            let distance = indicatorStyle == .followText ? 0 : indicatorAnimatePadding
            
            let max = fromItem.frame.width + toItem.frame.width + 2*itemMargin
            frame.size.width = max - distance*2
            let x = (toItem.frame.maxX - fromItem.frame.minX)/2 + fromItem.frame.minX
            
            UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: .calculationModePaced, animations: {
                
                UIView.addKeyframe(withRelativeStartTime:0, relativeDuration: 0.15, animations: {
                    self.indicatorView.frame = frame
                    self.indicatorView.center = CGPoint(x: x, y: self.indicatorView.center.y)
                })
                
                UIView.addKeyframe(withRelativeStartTime: 0.15, relativeDuration: 0.15, animations: {
                    self.indicatorView.frame = finnalFrame
                    self.indicatorView.center = CGPoint(x: toItem.center.x, y: self.indicatorView.center.y)
                })
                
            }, completion: nil)
        }
    }
}


// MARK: - 代理
extension CKSlideMenu: UIScrollViewDelegate {
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == self.bodyScrollView {
            let offset = scrollView.contentOffset
            if offset.x <= 0 {
                // 左边界
                leftIndex = 0
                rightIndex = leftIndex
            }
            else if (offset.x >= scrollView.contentSize.width - scrollView.frame.width) {
                //右边界
                leftIndex = itemLabels.count - 1
                rightIndex = leftIndex
            }
            else{
                leftIndex = Int(offset.x/scrollView.frame.width)
                rightIndex = leftIndex + 1
            }
            
            //计算偏移的相对位移
            let relativeLacation = bodyScrollView.contentOffset.x/bodyScrollView.frame.width - CGFloat(leftIndex)
            if relativeLacation == 0 {
                return
            }
            //更新UI
            self.updateIndicatorStyle(relativeLacation)
            self.updateTitleStyle(relativeLacation)
            
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == bodyScrollView {
            selectedIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
            self.resetTabScrollViewFrame()
        }
    }
    
    
    func updateIndicatorStyle(_ relativeLacation:CGFloat) {
        
        let leftItem = itemLabels[leftIndex]
        let rightItem = itemLabels[rightIndex]
        
        if indicatorStyle == .normal {
            //常规模式 只需更新中心点即可
            let max = rightItem.center.x - leftItem.center.x
            self.indicatorView.center = CGPoint(x:leftItem.center.x + max*relativeLacation,y:indicatorView.center.y)
        }
        else {
            //仔细观察位移效果，分析出如下计算公式
            let distance = indicatorStyle == .followText ? 0 : indicatorAnimatePadding
            var frame = self.indicatorView.frame
            let maxWidth = rightItem.frame.maxX - leftItem.frame.minX - distance*2
            if relativeLacation <= 0.5 {
                frame.size.width = leftItem.frame.width + (maxWidth - leftItem.frame.width)*(relativeLacation/0.5)
                frame.origin.x = leftItem.frame.minX + distance*(relativeLacation/0.5)
            }
            else{
                frame.size.width = rightItem.frame.width + (maxWidth - rightItem.frame.width)*((1-relativeLacation)/0.5)
                frame.origin.x = rightItem.frame.maxX - frame.size.width - distance*((1-relativeLacation)/0.5)
            }
            self.indicatorView.frame = frame
        }
    }
    
    
    func updateTitleStyle(_ relativeLacation:CGFloat) {
        let leftItem = itemLabels[leftIndex]
        let rightItem = itemLabels[rightIndex]
        switch titleStyle {
        case .gradient:
            leftItem.textColor = self.averageColor(fromColor: selectedColor, toColor: unSelectedColor, percent: relativeLacation)
            rightItem.textColor = self.averageColor(fromColor: unSelectedColor, toColor: selectedColor, percent: relativeLacation)
            
        case .normal:
            leftItem.textColor = relativeLacation <= 0.5 ? selectedColor : unSelectedColor
            rightItem.textColor = relativeLacation <= 0.5 ? unSelectedColor : selectedColor

        default:

            if relativeLacation <= 0.5 {
        
                leftItem.textColor = selectedColor
                leftItem.transform = CGAffineTransform.init(scaleX: 1.05, y: 1.05)
                
                rightItem.textColor = unSelectedColor
                rightItem.transform = CGAffineTransform.identity
            }
            else {
                leftItem.textColor = unSelectedColor
                leftItem.transform = CGAffineTransform.identity
                
                rightItem.textColor = selectedColor
                rightItem.transform = CGAffineTransform.init(scaleX: 1.05, y: 1.05)
            }
            break
        }
        
    }
    
    
}










