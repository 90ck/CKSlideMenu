//
//  CKSlideMenu.h
//  CKSlideMenu-OC
//
//  Created by ck on 2017/8/21.
//  Copyright © 2017年 caike. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,SlideMenuTitleStyle){
    SlideMenuTitleStyleNormal,           //默认 无效果
    SlideMenuTitleStyleGradient,         //颜色渐变
    SlideMenuTitleStyleTransfrom,        //放大
    SlideMenuTitleStyleAll               //颜色渐变+放大
};

typedef NS_ENUM(NSInteger,SlideMenuIndicatorStyle){
    SlideMenuIndicatorStyleNormal,          //默认
    SlideMenuIndicatorStyleFollowText,      //跟随文本长度
    SlideMenuIndicatorStyleStretch          //伸缩
};


@interface CKSlideMenu : UIView

/** title风格 */
@property (nonatomic,assign)SlideMenuTitleStyle titleStyle;

/** indicator风格 */
@property (nonatomic,assign)SlideMenuIndicatorStyle indicatorStyle;
/** 菜单是否固定  默认不固定*/
@property (nonatomic,assign)BOOL isFixed;

/** 是否懒加载自控制器 */
@property (nonatomic,assign)BOOL lazyLoad;

/** 选中颜色 */
@property (nonatomic,strong)UIColor *selectedColor;

/** 未选中颜色 */
@property (nonatomic,strong)UIColor *unselectedColor;

/** 菜单字体 */
@property (nonatomic,strong)UIFont *font;

/** 下标宽度 */
@property (nonatomic,assign)CGFloat indicatorWidth;

/** 下标高度 */
@property (nonatomic,assign)CGFloat indicatorHeight;

/** 下标颜色 默认为选中颜色*/
@property (nonatomic,strong)UIColor *indicatorColor;

/** 下标距离底部偏移量 */
@property (nonatomic,assign)CGFloat indicatorOffsety;

/** 下标伸缩动画的偏移量 SlideMenuIndicatorStyleStretch生效 */
@property (nonatomic,assign)CGFloat indicatorAnimatePadding;

/** bodyScrollView的父视图 默认为SlideMenu的父视图*/
@property (nonatomic,weak)UIView *bodySuperView;

/** bodyScrollView的frame */
@property (nonatomic,assign)CGRect bodyFrame;

/** 是否显示分割线 */
@property (nonatomic,assign)BOOL showLine;

/** 是否显示下标 默认显示*/
@property (nonatomic,assign)BOOL showIndicator;

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles controllers:(NSArray *)controllers;


/**
 刷新数据

 @param titles 标题数组
 @param controllers 控制器数组
 @param index 显示位置
 */
- (void)reloadTitles:(NSArray *)titles controllers:(NSArray *)controllers atIndex:(NSInteger)index;

/**
 滚动到对应位置

 @param toIndex 需要显示的位置
 */
- (void)scrollToIndex:(NSInteger)toIndex;

@end


