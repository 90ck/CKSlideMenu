//
//  CKSlideMenu.m
//  CKSlideMenu-OC
//
//  Created by ck on 2017/8/21.
//  Copyright © 2017年 caike. All rights reserved.
//

#import "CKSlideMenu.h"
#import <objc/runtime.h>

// 在运行时关联的关键方法
static NSString *textWidth_Key;
static NSString *textMinX_Key;
static NSString *textMaxX_Key;

@interface UIButton (textWith)
/** text长度 */
@property (nonatomic,assign)CGFloat textWidth;

/** text的MinX */
@property (nonatomic,assign,readonly)CGFloat textMinX;

/** text的MaxX */
@property (nonatomic,assign,readonly)CGFloat textMaxX;
@end

@interface CKSlideMenu ()<UIScrollViewDelegate>
{
    
    NSInteger   _leftIndex;         /** 左边索引 */
    
    NSInteger   _rightIndex;        /** 右边索引 */
}
/** 子控制器数组 */
@property (nonatomic,strong)NSArray *controllers;

/** title数组 */
@property (nonatomic,strong)NSArray *titleArr;

/** item数组 */
@property (nonatomic,strong)NSMutableArray *itemArr;

/** 底部分割线 */
@property (nonatomic,strong)UIView *sepertateView;

/** 菜单滚动视图 */
@property (nonatomic,strong)UIScrollView *tabScrollView;

/** body滚动视图 */
@property (nonatomic,strong)UIScrollView *bodyScrollView;

/** 下标视图 */
@property (nonatomic,strong)UIView *indicatorView;

/** 选中索引 */
@property (nonatomic,assign)NSInteger currentIndex;

/** item文字边距 */
@property (nonatomic,assign)CGFloat itemPadding;

@end

@implementation CKSlideMenu

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles controllers:(NSArray *)controllers;
{
    if (self = [super initWithFrame:frame]) {
        _controllers = controllers;
        _titleArr = titles;
        [self initSetting];
        [self addSubview:self.tabScrollView];
        [self.tabScrollView addSubview:self.indicatorView];
        [self addSubview:self.sepertateView];
    }
    return self;
}

- (void)reloadTitles:(NSArray *)titles controllers:(NSArray *)controllers atIndex:(NSInteger)index
{
    _titleArr = titles;
    _controllers = controllers;
    _currentIndex = index;
    [self setNeedsLayout];
}

//初始化参数
- (void)initSetting
{
    _selectedColor = [UIColor redColor];
    _unselectedColor = [UIColor blackColor];
    _indicatorColor = _selectedColor;
    _indicatorWidth = 20;
    _indicatorHeight = 2;
    _indicatorOffsety = 0;
    _itemPadding = 15;
    _indicatorAnimatePadding = 8;
    _titleStyle = SlideMenuTitleStyleNormal;
    _indicatorStyle = SlideMenuIndicatorStyleNormal;
    _isFixed = NO;
    _itemArr = [NSMutableArray array];
    _font = [UIFont systemFontOfSize:14];
}

//布局
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.tabScrollView.frame = self.bounds;
    self.sepertateView.frame = CGRectMake(0, self.frame.size.height - 0.5, self.frame.size.width, 0.5);
    
    [self setupTabContents];
    
    [self setupBodyScrollView];
    
    [self loadBodyContentAtIndex:_currentIndex];
    
    [self resetTabScrollViewFrame];
    
    _bodyScrollView.contentSize = CGSizeMake(_bodyScrollView.frame.size.width*_controllers.count, _bodyScrollView.frame.size.height);
    [_bodyScrollView setContentOffset:CGPointMake(_bodyScrollView.frame.size.width*_currentIndex, 0) animated:NO];
    
    [self setupIndicatorView];
}


/**
 配置indicator的UI
 */
- (void)setupIndicatorView
{
    UIButton *currentItem =  _itemArr[_currentIndex];
    CGRect frame = currentItem.frame;
    frame.origin.y = self.frame.size.height - _indicatorOffsety - _indicatorHeight;
    frame.size.height = _indicatorHeight;
    
    if (_indicatorStyle == SlideMenuIndicatorStyleNormal) {
        frame.origin.x = CGRectGetMidX(frame) - _indicatorWidth/2;
        frame.size.width = _indicatorWidth;
    }
    else{
        frame.origin.x = currentItem.textMinX;
        frame.size.width = currentItem.textWidth;
    }
    self.indicatorView.frame = frame;
}

/**
 配置menu
 */
- (void)setupTabContents
{
    for (UIButton *item in self.itemArr) {
        [item removeFromSuperview];
    }
    [self.itemArr removeAllObjects];
    
    
    CGFloat originX = 0;
    CGFloat totalTextLength = 0;
    for (int i = 0; i < self.titleArr.count; i++) {
        UIButton *item = [UIButton new];
        [item setTitleColor:_selectedColor forState:UIControlStateSelected];
        [item setTitleColor:_unselectedColor forState:UIControlStateNormal];
        item.titleLabel.textColor = _unselectedColor;
        item.reversesTitleShadowWhenHighlighted = YES;
        item.titleLabel.font = _font;
        [item setTitle:_titleArr[i] forState:UIControlStateNormal];
        [item addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        CGSize size = [_titleArr[i] sizeWithAttributes:@{NSFontAttributeName:_font}];
        item.frame = CGRectMake(originX, 0, size.width+_itemPadding*2, self.frame.size.height);
        item.textWidth = size.width;
        originX = CGRectGetMaxX(item.frame);
        [self.itemArr addObject:item];
        [self.tabScrollView addSubview:item];
        item.selected = i == _currentIndex;
        totalTextLength += size.width;
    }
    
    //固定型修正
    if (_isFixed) {
        if (totalTextLength > self.frame.size.width) {
            CGFloat width = self.frame.size.width / _titleArr.count;
            for (UIButton *item in _itemArr) {
                NSInteger index = [_itemArr indexOfObject:item];
                item.frame = CGRectMake(width*index, 0, width, item.frame.size.height);
                item.textWidth = width;
            }
        }
        else {
            //未超过，按照文本长度计算padding
            CGFloat itemPadding = (self.frame.size.width - totalTextLength)/(_titleArr.count*2);
            originX = 0;
            for (UIButton *item in _itemArr) {
                //                NSInteger index = [_itemArr indexOfObject:item];
                item.frame = CGRectMake(originX, 0, item.textWidth+2*itemPadding, item.frame.size.height);
                originX = CGRectGetMaxX(item.frame);
            }
        }
    }
    if (_titleStyle == SlideMenuTitleStyleTransfrom || _titleStyle == SlideMenuTitleStyleAll) {
        [self transfromItem:_itemArr[_currentIndex] percent:1];
    }
    _tabScrollView.contentSize = CGSizeMake(originX, self.frame.size.height);
}

/**
 添加bodyScorllView视图
 */
- (void)setupBodyScrollView
{
    if (self.bodySuperView == nil) {
        [self.superview addSubview:self.bodyScrollView];
    }
    else{
        [self.bodySuperView addSubview:self.bodyScrollView];
    }
}

//加载子控制器
- (void)loadBodyContentAtIndex:(NSInteger)index
{
    if (_lazyLoad) {
        UIViewController *vc = _controllers[index];
        if (!vc.viewLoaded) {
            vc.view.frame = _bodyScrollView.bounds;
            vc.view.center = CGPointMake(CGRectGetWidth(_bodyScrollView.frame)*(index+0.5), _bodyScrollView.frame.size.height/2);
            [_bodyScrollView addSubview:vc.view];
        }
    }
    else{
        for (int i = 0; i < _controllers.count; i++) {
            UIViewController *vc = _controllers[i];
            vc.view.frame = _bodyScrollView.bounds;
            vc.view.center = CGPointMake(CGRectGetWidth(_bodyScrollView.frame)*(i+0.5), _bodyScrollView.frame.size.height/2);
            [_bodyScrollView addSubview:vc.view];
        }
    }
}

#pragma mark setter
- (void)setBodyFrame:(CGRect)bodyFrame
{
    self.bodyScrollView.frame = bodyFrame;
    self.bodyScrollView.contentSize = CGSizeMake(bodyFrame.size.width*self.controllers.count, bodyFrame.size.height);
}

- (void)setIndicatorWidth:(CGFloat)indicatorWidth
{
    _indicatorWidth = indicatorWidth;
    [self setNeedsLayout];
}

- (void)setIndicatorHeight:(CGFloat)indicatorHeight
{
    _indicatorHeight = indicatorHeight;
    [self setNeedsLayout];
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;
    [self setNeedsLayout];
}

- (void)setUnselectedColor:(UIColor *)unselectedColor
{
    _unselectedColor = unselectedColor;
    [self setNeedsLayout];
}

- (void)setIndicatorOffsety:(CGFloat)indicatorOffsety
{
    _indicatorOffsety = indicatorOffsety;
    [self setNeedsLayout];
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    [self setNeedsLayout];
}

- (void)setTitleStyle:(SlideMenuTitleStyle)titleStyle
{
    _titleStyle = titleStyle;
    [self setNeedsLayout];
}

- (void)setIndicatorStyle:(SlideMenuIndicatorStyle)indicatorStyle
{
    _indicatorStyle = indicatorStyle;
    [self setNeedsLayout];
}

-(void)setShowLine:(BOOL)showLine
{
    self.sepertateView.hidden = !showLine;
}

- (void)setShowIndicator:(BOOL)showIndicator
{
    _showIndicator = showIndicator;
    self.indicatorView.hidden = !showIndicator;
    if (showIndicator) {
        [self setupIndicatorView];
    }
}

- (void)setIndicatorColor:(UIColor *)indicatorColor
{
    _indicatorColor = indicatorColor;
    self.indicatorView.backgroundColor = indicatorColor;
}

#pragma mark Private
- (void)itemClicked:(UIButton *)button
{
    if (button.selected) {
        return;
    }
    [self scrollToIndex:[_itemArr indexOfObject:button]];
}

- (void)scrollToIndex:(NSInteger)toIndex
{
    
    if (_itemArr.count <= toIndex) {
        _currentIndex = toIndex;
        return;
    }
    
    UIButton *fromItem = _itemArr[_currentIndex];
    UIButton *toItem = _itemArr[toIndex];
    
    _currentIndex = toIndex;
    
    //title样式
    if (_titleStyle == SlideMenuTitleStyleTransfrom || _titleStyle == SlideMenuTitleStyleAll) {
        [UIView animateWithDuration:0.25 animations:^{
            [self transfromItem:fromItem percent:0];
            [self transfromItem:toItem percent:1];
        }];
    }
    else{
        fromItem.selected = NO;
        toItem.selected = YES;
    }
    
    void (^completeAction)() = ^(){
        [_bodyScrollView setContentOffset:CGPointMake(_bodyScrollView.frame.size.width*toIndex, 0) animated:NO];
        [self resetTabScrollViewFrame];
    };
    
    if (self.indicatorView.hidden) {
        completeAction();
        return;
    }
    //更新indicator样式
    switch (_indicatorStyle) {
        case SlideMenuIndicatorStyleNormal:
        {
            [UIView animateWithDuration:0.25 animations:^{
                self.indicatorView.center = CGPointMake(toItem.center.x, self.indicatorView.center.y);
            } completion:^(BOOL finished) {
                completeAction();
            }];
        }
            break;
        case SlideMenuIndicatorStyleFollowText:
        {
            CGRect bounds = self.indicatorView.bounds;
            bounds.size.width = toItem.textWidth;
            [UIView animateWithDuration:0.25 animations:^{
                self.indicatorView.bounds = bounds;
                self.indicatorView.center = CGPointMake(toItem.center.x, self.indicatorView.center.y);
            } completion:^(BOOL finished) {
                completeAction();
            }];
        }
            break;
        case SlideMenuIndicatorStyleStretch:
        {
            CGRect frame = self.indicatorView.frame;
            frame.size.width = toItem.textWidth;
            CGRect finnalFrame = frame;
            
            CGFloat max = fromItem.textWidth + toItem.textWidth + 2*_itemPadding;
            frame.size.width = max - _indicatorAnimatePadding*2;
            
            CGFloat x = (CGRectGetMaxX(toItem.frame) - CGRectGetMinX(fromItem.frame))/2 + CGRectGetMinX(fromItem.frame) + _itemPadding;
            
            [UIView animateKeyframesWithDuration:0.25 delay:0 options:UIViewKeyframeAnimationOptionCalculationModePaced animations:^{
                
                [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.125 animations:^{
                    self.indicatorView.frame = frame;
                    self.indicatorView.center = CGPointMake(x, self.indicatorView.center.y);
                }];
                
                [UIView addKeyframeWithRelativeStartTime:0.125 relativeDuration:0.125 animations:^{
                    self.indicatorView.frame = finnalFrame;
                    self.indicatorView.center = CGPointMake(toItem.center.x, self.indicatorView.center.y);
                }];
                
                
            } completion:^(BOOL finished) {
                completeAction();
            }];
        }
            break;
            
        default:
            break;
    }
}

- (void)updateIndicatorStyle:(CGFloat)relativeLocation
{
    if (self.indicatorView.hidden) {
        return;
    }
    UIButton *leftItem = self.itemArr[_leftIndex];
    UIButton *rightItem = self.itemArr[_rightIndex];
    switch (_indicatorStyle) {
        case SlideMenuIndicatorStyleNormal:
        {
            //常规模式 只需更新中心点即可
            CGFloat max = rightItem.center.x - leftItem.center.x;
            self.indicatorView.center = CGPointMake(leftItem.center.x + max*relativeLocation, self.indicatorView.center.y);
        }
            break;
        case SlideMenuIndicatorStyleFollowText:
        {
            CGRect frame = self.indicatorView.frame;
            CGFloat maxWidth = rightItem.textWidth - leftItem.textWidth;
            frame.size.width = leftItem.textWidth + maxWidth*relativeLocation;
            self.indicatorView.frame = frame;
            
            CGFloat max = rightItem.center.x - leftItem.center.x;
            self.indicatorView.center = CGPointMake(leftItem.center.x + max*relativeLocation, self.indicatorView.center.y);
        }
            break;
        case SlideMenuIndicatorStyleStretch:
        {
            //仔细观察位移效果，分析出如下计算公式
            CGRect frame = self.indicatorView.frame;
            
            CGFloat maxWidth = rightItem.textMaxX - leftItem.textMinX - _indicatorAnimatePadding*2;
            if (relativeLocation <= 0.5) {
                frame.size.width = leftItem.textWidth + (maxWidth - leftItem.textWidth)*(relativeLocation/0.5);
                frame.origin.x = leftItem.textMinX + _indicatorAnimatePadding*(relativeLocation/0.5);
            }
            else{
                frame.size.width = rightItem.textWidth + (maxWidth - rightItem.textWidth)*((1-relativeLocation)/0.5);
                frame.origin.x = rightItem.textMaxX - frame.size.width - _indicatorAnimatePadding*((1-relativeLocation)/0.5);
            }
            self.indicatorView.frame = frame;
        }
            break;
            
        default:
            break;
    }
}

- (void)updateTitleStyle:(CGFloat)relativeLocation
{
    UIButton *leftItem = self.itemArr[_leftIndex];
    UIButton *rightItem = self.itemArr[_rightIndex];
    
    switch (_titleStyle) {
        case SlideMenuTitleStyleNormal:
        {
            leftItem.selected = relativeLocation <= 0.5;
            rightItem.selected = !leftItem.selected;
        }
            break;
        case SlideMenuTitleStyleGradient:
        {
            leftItem.selected = relativeLocation <= 0.5;
            rightItem.selected = !leftItem.selected;
            
            CGFloat percent = relativeLocation <= 0.5 ? (1-relativeLocation) : relativeLocation;
            [leftItem setTitleColor:[self averageColorFrom:_unselectedColor to:_selectedColor percent:percent] forState:UIControlStateSelected];
            [leftItem setTitleColor:[self averageColorFrom:_selectedColor to:_unselectedColor percent:percent] forState:UIControlStateNormal];
            
            [rightItem setTitleColor:[self averageColorFrom:_unselectedColor to:_selectedColor percent:percent] forState:UIControlStateSelected];
            [rightItem setTitleColor:[self averageColorFrom:_selectedColor to:_unselectedColor percent:percent] forState:UIControlStateNormal];
        }
            break;
        case SlideMenuTitleStyleTransfrom:
        {

            [self transfromItem:leftItem percent:1-relativeLocation];
            [self transfromItem:rightItem  percent:relativeLocation];
        }
            break;
        case SlideMenuTitleStyleAll:
        {
            CGFloat percent = relativeLocation <= 0.5 ? (1-relativeLocation) : relativeLocation;
            [leftItem setTitleColor:[self averageColorFrom:_unselectedColor to:_selectedColor percent:percent] forState:UIControlStateSelected];
            [leftItem setTitleColor:[self averageColorFrom:_selectedColor to:_unselectedColor percent:percent] forState:UIControlStateNormal];
            
            [rightItem setTitleColor:[self averageColorFrom:_unselectedColor to:_selectedColor percent:percent] forState:UIControlStateSelected];
            [rightItem setTitleColor:[self averageColorFrom:_selectedColor to:_unselectedColor percent:percent] forState:UIControlStateNormal];
            [self transfromItem:leftItem percent:1-relativeLocation];
            [self transfromItem:rightItem  percent:relativeLocation];
        }
            break;
        default:
            break;
    }
}

- (void)transfromItem:(UIButton *)item percent:(CGFloat)percent
{
    item.selected = percent >= 0.5 ;
    item.transform = CGAffineTransformMakeScale(1+0.1*percent, 1+0.1*percent);
}

/**
 * 修正tabScrollView的位置
 */
- (void)resetTabScrollViewFrame
{
    if (self.isFixed) {
        return;
    }
    UIButton *selectedItem = self.itemArr[_currentIndex];
    CGFloat tab_width = self.tabScrollView.frame.size.width;
    CGFloat reviseX;
    if (selectedItem.center.x + tab_width/2 >= self.tabScrollView.contentSize.width) {
        reviseX = self.tabScrollView.contentSize.width - tab_width;
    }
    else if (selectedItem.center.x - tab_width/2 <= 0) {
        reviseX = 0;
    }
    else{
        reviseX = selectedItem.center.x - tab_width/2;
    }
    
    [self.tabScrollView setContentOffset:CGPointMake(reviseX, 0) animated:YES];
}


#pragma mark Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.bodyScrollView) {
        CGFloat offsetX = scrollView.contentOffset.x;

        if (_lazyLoad) {
            _currentIndex = lroundf(offsetX / scrollView.frame.size.width);
            NSInteger index = _currentIndex;
            if (offsetX > scrollView.frame.size.width*_currentIndex) {
                index = (_currentIndex + 1) >= _itemArr.count ? _currentIndex : _currentIndex + 1;
            }
            else if (offsetX < scrollView.frame.size.width * _currentIndex) {
                index = (_currentIndex - 1) < 0 ? 0 : _currentIndex - 1;
            }
            [self loadBodyContentAtIndex:index];
        }
        
        if (offsetX <= 0) { //左边界
            _leftIndex = 0;
            _rightIndex = _leftIndex;
        }
        else if (offsetX >= scrollView.contentSize.width - scrollView.frame.size.width) {  //右边界
            _leftIndex = self.itemArr.count - 1;
            _rightIndex = _leftIndex;
        }
        else{
            _leftIndex = (NSInteger)(offsetX/scrollView.frame.size.width);
            _rightIndex = _leftIndex + 1;
        }
        
        CGFloat relativeLocation = (offsetX/scrollView.frame.size.width - _leftIndex);
        if (relativeLocation == 0) {
            return;
        }
        [self updateIndicatorStyle:relativeLocation];
        [self updateTitleStyle:relativeLocation];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.bodyScrollView) {
        _currentIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
        [self resetTabScrollViewFrame];
    }
}



#pragma mark - 懒加载 UI
- (UIScrollView *)tabScrollView
{
    if (!_tabScrollView) {
        _tabScrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _tabScrollView.showsVerticalScrollIndicator = NO;
        _tabScrollView.showsHorizontalScrollIndicator = NO;
        _tabScrollView.backgroundColor = [UIColor clearColor];
    }
    return _tabScrollView;
}

- (UIView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [UIView new];
        _indicatorView.backgroundColor = self.indicatorColor;
    }
    return _indicatorView;
}

- (UIView *)sepertateView
{
    if (_sepertateView == nil) {
        _sepertateView = [[UIView alloc]init];
        _sepertateView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    }
    return _sepertateView;
}

- (UIScrollView *)bodyScrollView
{
    if (_bodyScrollView == nil) {
        _bodyScrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
        _bodyScrollView.showsVerticalScrollIndicator = NO;
        _bodyScrollView.showsHorizontalScrollIndicator = NO;
        _bodyScrollView.bounces = NO;
        _bodyScrollView.delegate = self;
        _bodyScrollView.pagingEnabled = YES;
    }
    return _bodyScrollView;
}


#pragma mark other

//渐变颜色
- (UIColor *)averageColorFrom:(UIColor *)fromColor to:(UIColor *)toColor percent:(CGFloat)percent
{
    CGFloat fromRed = 0;
    CGFloat fromGreen = 0;
    CGFloat fromBlue = 0;
    CGFloat fromeAlpha = 0;
    [fromColor getRed:&fromRed green:&fromGreen blue:&fromBlue alpha:&fromeAlpha];
    
    CGFloat toRed = 0;
    CGFloat toGreen = 0;
    CGFloat toBlue = 0;
    CGFloat toAlpha = 0;
    [toColor getRed:&toRed green:&toGreen blue:&toBlue alpha:&toAlpha];
    
    CGFloat nowRed = fromRed + (toRed - fromRed)*percent;
    CGFloat nowGreen = fromGreen + (toGreen - fromGreen)*percent;
    CGFloat nowBlue = fromBlue + (toBlue - fromBlue)*percent;
    CGFloat nowAlpha = fromeAlpha + (toAlpha - fromeAlpha)*percent;
    return [UIColor colorWithRed:nowRed green:nowGreen blue:nowBlue alpha:nowAlpha];
}


@end



#pragma mark Buttton 分类
@implementation UIButton (textWith)

- (void)setTextWidth:(CGFloat)textWidth
{
    objc_setAssociatedObject(self, &textWidth_Key, @(textWidth), OBJC_ASSOCIATION_RETAIN);
}

- (CGFloat)textWidth
{
    id obj = objc_getAssociatedObject(self, &textWidth_Key);
    if (obj != nil && [obj isKindOfClass:[NSNumber class]]) {
        return  [(NSNumber*)obj floatValue];
    }
    return 0;
}


- (CGFloat)textMinX
{
    return (self.frame.size.width - self.textWidth)/2 + self.frame.origin.x;
}

- (CGFloat)textMaxX
{
    return CGRectGetMaxX(self.frame) - (self.frame.size.width - self.textWidth)/2;
}

@end
