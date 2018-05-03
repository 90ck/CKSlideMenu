//
//  CKChildViewController.m
//  CKSlideMenu-OC
//
//  Created by ck on 2017/8/21.
//  Copyright © 2017年 caike. All rights reserved.
//

#import "CKChildViewController.h"
#import "CKSlideMenu.h"
#import "CkViewController.h"
@interface CKChildViewController ()

@end

@implementation CKChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (self.type == 0) {
        NSArray *titles = @[@"今日",@"阿萨德",@"爱迪生",@"暗示",@"说的",@"粉丝",@"阿萨德",@"爱迪生",@"暗示",@"说的"];
        NSMutableArray *arr = [NSMutableArray array];
        for (int i = 0; i <titles.count ; i++) {
            [arr addObject:[CkViewController new]];
        }
        CKSlideMenu *slideMenu = [[CKSlideMenu alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 40) titles:titles controllers:arr];
        slideMenu.bodyFrame = CGRectMake(0,  64 + 40, self.view.frame.size.width, self.view.frame.size.height - 40 - 64);
        [slideMenu scrollToIndex:3];
        [self.view addSubview:slideMenu];
    }
    else if (self.type == 1){
        NSArray *titles = @[@"今日",@"阿萨德",@"爱迪生",@"暗示",@"说的",@"粉丝",@"阿萨德",@"爱迪生",@"暗示",@"说的"];
        NSMutableArray *arr = [NSMutableArray array];
        for (int i = 0; i <titles.count ; i++) {
            [arr addObject:[CkViewController new]];
        }
        CKSlideMenu *slideMenu = [[CKSlideMenu alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 40) titles:titles controllers:arr];
        slideMenu.bodyFrame = CGRectMake(0,  64 + 40, self.view.frame.size.width, self.view.frame.size.height - 40 - 64);
        slideMenu.bodySuperView = self.view;
        slideMenu.indicatorOffsety = 2;
        slideMenu.indicatorWidth = 25;
        slideMenu.titleStyle = SlideMenuTitleStyleGradient;
        slideMenu.selectedColor = [UIColor orangeColor];
        slideMenu.unselectedColor = [UIColor grayColor];
        [self.view addSubview:slideMenu];
    }
    else if (self.type == 2){
        NSArray *titles = @[@"今日",@"爱迪生",@"暗示"];
        NSMutableArray *arr = [NSMutableArray array];
        for (int i = 0; i <titles.count ; i++) {
            [arr addObject:[CkViewController new]];
        }
        CKSlideMenu *slideMenu = [[CKSlideMenu alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width*0.6, 40) titles:titles controllers:arr];
        slideMenu.bodyFrame = CGRectMake(0,  64, self.view.frame.size.width, self.view.frame.size.height - 64);
        slideMenu.bodySuperView = self.view;
        slideMenu.indicatorStyle = SlideMenuIndicatorStyleStretch;
        slideMenu.indicatorOffsety = 1.5;
        slideMenu.titleStyle = SlideMenuTitleStyleTransfrom;
        slideMenu.isFixed = YES;
        slideMenu.font = [UIFont systemFontOfSize:12];
        slideMenu.indicatorAnimatePadding = 15;
        slideMenu.showLine = NO;
        self.navigationItem.titleView = slideMenu;
        
    }
    else if (self.type == 3){
        NSArray *titles = @[@"今日",@"阿萨德",@"爱迪生",@"暗示",@"说的",@"粉丝",@"阿萨德",@"爱迪生",@"暗示",@"说的"];
        NSMutableArray *arr = [NSMutableArray array];
        for (int i = 0; i <titles.count ; i++) {
            [arr addObject:[CkViewController new]];
        }
        CKSlideMenu *slideMenu = [[CKSlideMenu alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 40) titles:titles controllers:arr];
        slideMenu.bodyFrame = CGRectMake(0,  64 + 40, self.view.frame.size.width, self.view.frame.size.height - 40 - 64);
        slideMenu.bodySuperView = self.view;
        slideMenu.indicatorStyle = SlideMenuIndicatorStyleFollowText;
        slideMenu.indicatorOffsety = 0;
        slideMenu.titleStyle = SlideMenuTitleStyleAll;
        slideMenu.indicatorHeight = 2;
        slideMenu.showIndicator = NO;
        [self.view addSubview:slideMenu];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
