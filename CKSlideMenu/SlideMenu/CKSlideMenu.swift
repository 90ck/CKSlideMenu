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
    case gradient           //渐变颜色
    case transfrom          //放大
}

enum SlideMenuIndicatorStyle {
    case normal             //常规
    case followText         //跟随文本长度
    case stretch            //伸缩  默认
}



class CKSlideMenu: UIView {
    
    //MARK: - 成员变量
    /// 是否是固定型菜单（不需要修正滚动）
    var isFixed:Bool = false
    
    /// 是否懒加载子控制器
    var lazyLoad:Bool = true
    
    /// 选中颜色
    var selectedColor:UIColor       = UIColor.red {
        didSet {
            for item in itemButtons {
                item.setTitleColor(selectedColor, for: .selected)
            }
        }
    }
    
    /// 未选中颜色
    var unSelectedColor:UIColor     = UIColor.black {
        didSet {
            for item in itemButtons {
                item.setTitleColor(unSelectedColor, for: .normal)
            }
        }
    }
    
    /// 下标宽度
    var indicatorWidth:CGFloat      = 30 {  //SlideMenuIndicatorStyle 为normal时有效
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 下标高度
    var indicatorHeight:CGFloat     = 2 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 下标距离底部距离
    var bottomPadding:CGFloat       = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    //伸缩动画的偏移量 在indicatorStyle = stretch是生效
    var indicatorAnimatePadding:CGFloat = 8.0
    
    /// 标题字体
    var font:UIFont                 = UIFont.systemFont(ofSize: 13) {
        didSet {
            needLayout = true
            setNeedsLayout()
        }
    }
    
    /// 下标样式
    var indicatorStyle:SlideMenuIndicatorStyle = .normal {
        didSet{
            setNeedsLayout()
        }
    }
    
    /// 标题样式
    var titleStyle:SlideMenuTitleStyle = .normal {
        didSet{
            setNeedsLayout()
        }
    }
    
    ///bodyScrollView的父视图,默认为SlideMenu的父视图
    weak var bodySuperView:UIView? {
        didSet{
            needLayout = true
            setNeedsLayout()
        }
    }
    
    ///bodyScrollView的frame
    var bodyFrame:CGRect = CGRect.zero {
        didSet{
            bodyScrollView.frame = bodyFrame
        }
    }
    
    
    /// 菜单栏
    lazy var tabScrollView:UIScrollView = {
        let  tabScrollView = UIScrollView.init(frame: self.bounds)
        tabScrollView.showsVerticalScrollIndicator = false
        tabScrollView.showsHorizontalScrollIndicator = false
        tabScrollView.backgroundColor = UIColor.clear
        return tabScrollView
    }()
    
    
    /// 内容视图
    lazy var bodyScrollView:UIScrollView = {
        let bodyScrollView = UIScrollView.init(frame: CGRect.zero)
        bodyScrollView.showsVerticalScrollIndicator = false
        bodyScrollView.showsHorizontalScrollIndicator = false
        bodyScrollView.isPagingEnabled = true
        bodyScrollView.bounces = false
        bodyScrollView.delegate = self
        return bodyScrollView
    }()
    
    
    /// 下标视图
    lazy var indicatorView:UIView = UIView()
    
    ///当前索引
    fileprivate(set) var currentIndex:Int = 0
    
    /// 底部分割线 默认不显示
    lazy var line:UIView = UIView()
    
    fileprivate var leftIndex:Int = 0
    fileprivate var rightIndex:Int = 0
   
    fileprivate var itemButtons:Array<UIButton>  = []
    // tab文字的边距
    fileprivate var itemMargin:CGFloat = 15.0
    
    private var needLayout:Bool = true
    private var titlesArr:Array<String>
    private var controllers:Array<UIViewController>
    
    
    // MARK: - 生命周期
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame:CGRect ,titles:Array<String>, childControllers:Array<UIViewController>) {
        titlesArr = titles
        controllers = childControllers
        super.init(frame: frame)
        
        addSubview(tabScrollView)
        tabScrollView.addSubview(indicatorView)
        indicatorView.backgroundColor = selectedColor
        line.backgroundColor = UIColor(white: 0.9, alpha: 1)
        line.isHidden = true
        self.addSubview(line)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        tabScrollView.frame = self.bounds
        line.frame = CGRect(x: 0, y: self.frame.height - 0.5, width: self.frame.width, height: 0.5)
        
        if needLayout {
            for item in itemButtons {
                item.removeFromSuperview()
            }
            itemButtons.removeAll()
            setupTabScrollView()
            if bodySuperView != nil {
                bodySuperView?.addSubview(bodyScrollView)
            }
            else{
                superview?.addSubview(bodyScrollView)
            }
            if lazyLoad {
                lazyLoadContents(at: currentIndex)
            }
            else {
                for (index, vc) in controllers.enumerated() {
                    vc.view.frame = bodyScrollView.bounds
                    vc.view.center = CGPoint(x: bodyScrollView.frame.width*(CGFloat(index)+0.5), y: bodyScrollView.frame.height/2)
                    bodyScrollView.addSubview(vc.view)
                }
            }
            bodyScrollView.contentSize = CGSize(width: bodyScrollView.frame.width*CGFloat(controllers.count), height: bodyScrollView.frame.height)
            bodyScrollView.setContentOffset(CGPoint(x:bodyScrollView.frame.size.width*CGFloat(currentIndex), y:0), animated: false)
            resetTabScrollViewFrame()
            needLayout = false
        }
        setupIndicatorView()
    }
    
    /// 配置导航栏
    private func setupTabScrollView()  {
        
        var originX:CGFloat = 0
        var totalTextLenght:CGFloat = 0
        for (index,title) in titlesArr.enumerated() {
            let item = UIButton.init()
            item.setTitleColor(selectedColor, for: .selected)
            item.setTitleColor(unSelectedColor, for: .normal)
            item.reversesTitleShadowWhenHighlighted = true
            item.titleLabel?.font = font
            item.setTitle(title, for: .normal)
            item.addTarget(self, action: #selector(itemClicked(_:)), for: .touchUpInside)
            
            let size = (title as NSString).size(attributes: [NSFontAttributeName:font])
            item.frame = CGRect(x: originX, y: 0, width: size.width + itemMargin*2, height: self.frame.height)
            item.textWidth = size.width
            originX = item.frame.maxX
            itemButtons.append(item)
            tabScrollView.addSubview(item)
            item.isSelected = index == currentIndex
            if titleStyle == .transfrom && index == currentIndex {
                transformItem(item, isIdentify: false)
            }
            totalTextLenght += size.width
        }
        
        //固定型修正
        if isFixed {
            if totalTextLenght > self.frame.width {
                //文字长度超过容器，则平分宽度
                let width = self.frame.width/CGFloat(self.titlesArr.count)
                for (index,item) in itemButtons.enumerated() {
                    item.frame = CGRect(x: width*CGFloat(index), y: 0, width: width, height: item.frame.height)
                    item.textWidth = width
                }
            }
            else{
                //未超过，按照文本长度计算margin
                let margin = (self.frame.width - totalTextLenght)/CGFloat(titlesArr.count*2)
                originX = 0
                for (_,item) in itemButtons.enumerated() {
                    item.frame = CGRect(x: originX, y: 0, width: item.textWidth+2*margin, height: item.frame.height)
                    originX = item.frame.maxX
                }
            }
        }
        tabScrollView.contentSize = CGSize(width: originX, height: self.frame.height)
    }
    
    ///配置下标
    private func setupIndicatorView() {
        
        var frame = itemButtons[currentIndex].frame
        frame.origin.y = self.frame.height - bottomPadding - indicatorHeight
        frame.size.height = indicatorHeight
        
        if indicatorStyle == .normal {
            frame.origin.x = frame.midX - indicatorWidth/2
            frame.size.width = indicatorWidth
        }
        else {
            let text = titlesArr[currentIndex]
            let size = (text as NSString).size(attributes: [NSFontAttributeName:font])
            frame.origin.x = frame.midX - size.width/2
            frame.size.width = size.width
        }
        indicatorView.frame = frame
    }
    
    
    // 修正tabScrollView的位置
    fileprivate func resetTabScrollViewFrame() {
        
        if self.isFixed {
            return
        }
        
        let seletedItem = itemButtons[currentIndex]
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
    
    /// 懒加载子控制器
    ///
    /// - Parameter index: 索引
    fileprivate func lazyLoadContents(at index:Int)  {
        let vc = controllers[index]
        if !vc.isViewLoaded {
            vc.view.frame = bodyScrollView.bounds
            vc.view.center = CGPoint(x: bodyScrollView.frame.width*(CGFloat(index)+0.5), y: bodyScrollView.frame.height/2)
            bodyScrollView.addSubview(vc.view)
        }
    }
    
    
    deinit {
        print("\(#function)")
    }
    
    
    //MARK: - 事件及UI
    
    func scrollToIndex(_ index:UInt) {
        if itemButtons.count > Int(index) {
            let button = itemButtons[currentIndex]
            itemClicked(button)
        }
        else {
            currentIndex = Int(index)
        }
    }
    
    
    /// 更新下标的UI效果
    ///
    /// - Parameter relativeLacation: 滑动的相对距离
    func updateIndicatorStyle(_ relativeLacation:CGFloat) {
        
        let leftItem = itemButtons[leftIndex]
        let rightItem = itemButtons[rightIndex]
        
        switch indicatorStyle {
        case .normal:
            //常规模式 只需更新中心点即可
            let max = rightItem.center.x - leftItem.center.x
            self.indicatorView.center = CGPoint(x:leftItem.center.x + max*relativeLacation,y:indicatorView.center.y)
        case .followText:
            
            
            var frame = self.indicatorView.frame
            let maxWidth = rightItem.textWidth - leftItem.textWidth
            frame.size.width = leftItem.textWidth + maxWidth*relativeLacation
            indicatorView.frame = frame
            
            let max = rightItem.center.x - leftItem.center.x
            indicatorView.center = CGPoint(x:leftItem.center.x + max*relativeLacation,y:indicatorView.center.y)
            
        case .stretch:
            //仔细观察位移效果，分析出如下计算公式
            var frame = self.indicatorView.frame
            
            let maxWidth = rightItem.textMaxX - leftItem.textMinX - indicatorAnimatePadding*2
            if relativeLacation <= 0.5 {
                frame.size.width = leftItem.textWidth + (maxWidth - leftItem.textWidth)*(relativeLacation/0.5)
                frame.origin.x = leftItem.textMinX + indicatorAnimatePadding*(relativeLacation/0.5)
            }
            else{
                frame.size.width = rightItem.textWidth + (maxWidth - rightItem.textWidth)*((1-relativeLacation)/0.5)
                frame.origin.x = rightItem.textMaxX - frame.size.width - indicatorAnimatePadding*((1-relativeLacation)/0.5)
            }
            self.indicatorView.frame = frame
        }
    }
    
    
    /// 更新标题的UI效果
    ///
    /// - Parameter relativeLacation: 滑动的相对距离
    func updateTitleStyle(_ relativeLacation:CGFloat) {
        
        let leftItem = itemButtons[leftIndex]
        let rightItem = itemButtons[rightIndex]
        
        switch titleStyle {
        case .gradient:
            
            leftItem.isSelected = relativeLacation <= 0.5
            rightItem.isSelected = relativeLacation > 0.5
            
            let percent = relativeLacation <= 0.5 ? (1-relativeLacation) : relativeLacation
            
            leftItem.setTitleColor(self.averageColor(fromColor: unSelectedColor, toColor: selectedColor, percent: percent), for: .selected)
            leftItem.setTitleColor(self.averageColor(fromColor: selectedColor, toColor: unSelectedColor, percent: percent), for: .normal)
            
            rightItem.setTitleColor(self.averageColor(fromColor: unSelectedColor, toColor: selectedColor, percent: percent), for: .selected)
            rightItem.setTitleColor(self.averageColor(fromColor: selectedColor, toColor: unSelectedColor, percent: percent), for: .normal)
            
        case .normal:
            leftItem.isSelected = relativeLacation <= 0.5
            rightItem.isSelected = relativeLacation > 0.5
            
        default:
            
            if relativeLacation <= 0.5 {
                transformItem(leftItem, isIdentify: false)
                transformItem(rightItem, isIdentify: true)
            }
            else {
                transformItem(leftItem, isIdentify: true)
                transformItem(rightItem, isIdentify: false)
            }
            break
        }
    }
    
    
    /// 对item进行放大和还原操作
    ///
    /// - Parameters:
    ///   - item: button
    ///   - isIdentify: 是否还原
    private func transformItem(_ item:UIButton, isIdentify:Bool) {
        item.isSelected = !isIdentify
        item.transform = isIdentify ? CGAffineTransform.identity : CGAffineTransform.init(scaleX: 1.05, y: 1.05)

    }
    
    
    // 导航栏点击事件
    func itemClicked(_ button:UIButton) {
        if button.isSelected {
            return
        }
        let fromIndex = currentIndex
        currentIndex = itemButtons.index(of: button)!
        self.changeTitleItem(from: fromIndex, to: currentIndex)
        self.changeIndicator(from: fromIndex, to: currentIndex)
        bodyScrollView.setContentOffset(CGPoint(x:bodyScrollView.frame.size.width*CGFloat(currentIndex), y:0), animated: false)
        self.resetTabScrollViewFrame()
    }
    
    //点击事件触发的UI更新
    private func changeTitleItem(from:Int ,to:Int) {
        
        self.itemButtons[from].isSelected = false
        self.itemButtons[to].isSelected = true
        
        if titleStyle == .transfrom {
            UIView.animate(withDuration: 0.25, animations: {
                self.itemButtons[to].transform = CGAffineTransform.init(scaleX: 1.05, y: 1.05)
                self.itemButtons[from].transform = CGAffineTransform.identity
                
            }, completion: nil)
        }
    }
    
    //点击事件触发的UI更新
    private func changeIndicator(from:Int, to:Int) {
        let fromItem = itemButtons[from]
        let toItem = itemButtons[to]
        
        switch indicatorStyle {
        case .normal:
            UIView.animate(withDuration: 0.3, animations: {
                self.indicatorView.center = CGPoint(x:toItem.center.x,y:self.indicatorView.center.y)
            })
        case .followText:
            var bounds = indicatorView.bounds
            bounds.size.width = toItem.textWidth
            UIView.animate(withDuration: 0.3, animations: {
                self.indicatorView.bounds = bounds
                self.indicatorView.center = CGPoint(x:toItem.center.x,y:self.indicatorView.center.y)
                
            })
        case .stretch:
            var frame = indicatorView.frame
            frame.size.width = itemButtons[to].textWidth
            let finnalFrame = frame
            
            let max = fromItem.textWidth + toItem.textWidth + 2*itemMargin
            frame.size.width = max - indicatorAnimatePadding*2
            
            let x = (toItem.frame.maxX - fromItem.frame.minX)/2 + fromItem.frame.minX + itemMargin
            
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
            currentIndex = lroundf(Float(scrollView.contentOffset.x / scrollView.frame.size.width))
            
            var index = currentIndex
            if offset.x > scrollView.frame.width*CGFloat(currentIndex) {
                
                index = (currentIndex + 1) >= itemButtons.count ? currentIndex : currentIndex + 1
            }
            else if (offset.x < scrollView.frame.width*CGFloat(currentIndex)) {
                index = (currentIndex - 1) < 0 ? 0 : currentIndex - 1
            }
            lazyLoadContents(at:index)
            
            if offset.x <= 0 {
                // 左边界
                leftIndex = 0
                rightIndex = leftIndex
            }
            else if (offset.x >= scrollView.contentSize.width - scrollView.frame.width) {
                //右边界
                leftIndex = itemButtons.count - 1
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
            currentIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
//            lazyLoadContents(at:currentIndex)
            self.resetTabScrollViewFrame()
        }
    }
    
}


extension CKSlideMenu {
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
}

    
private extension UIButton {
    private struct AssociatedKeys {
        static var textWidthName = "key_textWidth"
    }
    
    /// title的文本长度
    var textWidth:CGFloat {
        get{
            return objc_getAssociatedObject(self, &AssociatedKeys.textWidthName) as? CGFloat ?? 0
        }
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.textWidthName, newValue , objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var textMinX:CGFloat {
        get {
            return (self.frame.width - self.textWidth)/2 + self.frame.minX
        }
    }
    
    var textMaxX:CGFloat {
        get {
            return self.frame.maxX - (self.frame.width - self.textWidth)/2
        }
    }
}



