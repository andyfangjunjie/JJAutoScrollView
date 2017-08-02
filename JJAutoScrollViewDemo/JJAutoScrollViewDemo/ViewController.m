//
//  ViewController.m
//  JJAutoScrollViewDemo
//
//  Created by 房俊杰 on 2017/7/14.
//  Copyright © 2017年 房俊杰. All rights reserved.
//

#import "ViewController.h"

#import "JJAutoScrollView.h"

@interface ViewController () <JJAutoScrollViewDelegate,JJAutoScrollViewDataSource>

@property (weak, nonatomic) IBOutlet JJAutoScrollView *bottomScrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    JJAutoScrollView *autoScrollView = [[JJAutoScrollView alloc] initWithFrame:CGRectMake(10,64 , 355, 200)];
    autoScrollView.pageControlPosition = JJPageControlPositionBottomCenter;
    autoScrollView.delegate = self;
    autoScrollView.dataSource = self;
    [self.view addSubview:autoScrollView];
    
    self.bottomScrollView.pageControlPosition = JJPageControlPositionTopCenter;
    self.bottomScrollView.delegate = self;
    self.bottomScrollView.dataSource = self;
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

#pragma mark - 代理


/**
 显示的内容控件
 
 @param autoScrollView scrollView
 @param index 数组索引
 @return 返回索引下的数组中的元素
 */
- (UIView *)autoScrollView:(JJAutoScrollView *)autoScrollView contentViewAtIndex:(NSInteger)index {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"banner"]];
    return imageView;
}

/**
 页码总个数
 
 @param autoScrollView scrollView
 @return 页码总个数
 */
- (NSInteger)numberOfPagesInJJAutoScrollView:(JJAutoScrollView *)autoScrollView {
    return 3;
}

/**
 点击了哪一个
 
 @param autoScrollView scrollView
 @param index 点击的页码
 */
- (void)autoScrollView:(JJAutoScrollView *)autoScrollView didSelectScrollViewAtIndex:(NSInteger)index {
    NSLog(@"%zd",index);
}
@end































