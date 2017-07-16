//
//  JJAutoScrollView.h
//  Banner滑动
//
//  Created by 房俊杰 on 2015/2/6.
//  Copyright © 2015年 上海涵予信息科技有限公司. All rights reserved.
//


/********************************
 *
 *  轮播图 加定时器自动滚动，可设置时间间隔
 *
 *  此demo采用代理和block两种方式
 *
 ********************************
 */

#import <UIKit/UIKit.h>
/** 页码控制器的位置 */
typedef NS_ENUM(NSInteger, JJPageControlPosition) {
    JJPageControlPositionBottomCenter,
    JJPageControlPositionBottomLeft,
    JJPageControlPositionBottomRight,
    JJPageControlPositionTopCenter,
    JJPageControlPositionTopLeft,
    JJPageControlPositionTopRight
};
@class JJAutoScrollView;

@protocol JJAutoScrollViewDelegate <NSObject>

@optional
/**
 点击了哪一个

 @param autoScrollView scrollView
 @param index 点击的页码
 */
- (void)autoScrollView:(JJAutoScrollView *)autoScrollView didSelectScrollViewAtIndex:(NSInteger)index;

/**
 当前显示的是哪一个（方便自定义页码用）
 
 @param autoScrollView scrollView
 @param index 页码
 */
- (void)autoScrollView:(JJAutoScrollView *)autoScrollView showScrollViewAtIndex:(NSInteger)index;

@end

@protocol JJAutoScrollViewDataSource <NSObject>

@required

/**
 显示的内容控件

 @param autoScrollView scrollView
 @param index 数组索引
 @return 返回索引下的数组中的元素
 */
- (UIView *)autoScrollView:(JJAutoScrollView *)autoScrollView contentViewAtIndex:(NSInteger)index;

/**
 页码总个数

 @param autoScrollView scrollView
 @return 页码总个数
 */
- (NSInteger)numberOfPagesInJJAutoScrollView:(JJAutoScrollView *)autoScrollView;

@end

@interface JJAutoScrollView : UIView


#pragma mark - 公用
/** 时间间隔 */
@property (nonatomic,assign) NSTimeInterval animationDuration;
/** 页码控制器的位置 */
@property (nonatomic,assign) JJPageControlPosition JJPageControlPosition;
/** 页码控件隐藏 */
@property (nonatomic,assign) BOOL pageControlHidden;
#pragma mark - 页码控制(可修改)
/** 选中颜色 */
@property (nonatomic,strong) UIColor *currentPageIndicatorTintColor;
/** 未选中颜色 */
@property (nonatomic,strong) UIColor *pageIndicatorTintColor;



#pragma mark - 传值方式

/**
 * 1.代理传值
 */

/** 代理 */
@property (nonatomic,weak) __weak id<JJAutoScrollViewDelegate>delegate;
/** 数据源代理 */
@property (nonatomic,weak) __weak id<JJAutoScrollViewDataSource>dataSource;

/**
 * 2.block传值
 */

/** 
   获取第pageIndex个位置的contentView
 *
 * 注意：必须写到numberOfPages之前
 */
@property (nonatomic,strong) UIView *(^fetchContentViewAtIndex)(NSInteger pageIndex);
/** 获取总个数 */
@property (nonatomic,strong) NSInteger (^numberOfPages)(void);
/** 点击了哪一个 */
@property (nonatomic,strong) void (^didSelectContentViewAtIndex)(NSInteger pageIndex);





@end






































