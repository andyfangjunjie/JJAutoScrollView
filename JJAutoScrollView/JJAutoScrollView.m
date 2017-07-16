//
//  JJAutoScrollView.m
//  Banner滑动
//
//  Created by 房俊杰 on 2015/2/6.
//  Copyright © 2015年 上海涵予信息科技有限公司. All rights reserved.
//

#import "JJAutoScrollView.h"


@interface JJAutoScrollView () <UIScrollViewDelegate>

/** scrollView */
@property (nonatomic,strong) UIScrollView *scrollView;
/** 页码控件 */
@property (nonatomic,strong) UIPageControl *pageControl;
/** 页码 */
@property (nonatomic,assign) NSInteger totalPagesCount;
/** 当前页码 */
@property (nonatomic,assign) NSInteger currentPageIndex;
/** 存放三张数据源 */
@property (nonatomic,strong) NSMutableArray *contentViews;

/** 动画时间 */
@property (nonatomic,strong) NSTimer *animationTimer;

@end

@implementation JJAutoScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        [self setup];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}
- (void)setup {
    self.autoresizesSubviews = YES;
    [self addSubview:self.scrollView];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    
    CGFloat superViewWidth = CGRectGetWidth(self.frame);
    CGFloat superViewHeight = CGRectGetHeight(self.frame);
    CGFloat width = _totalPagesCount * 18;
    CGFloat height = 20;
    CGFloat x = 0;
    CGFloat y = 0;
    switch (self.JJPageControlPosition) {
        case JJPageControlPositionBottomCenter:
        {
            x = (superViewWidth - width) / 2;
            y = superViewHeight - height;
            break;
        }
        case JJPageControlPositionBottomLeft:
        {
            y = superViewHeight - height;
            break;
        }
        case JJPageControlPositionBottomRight:
        {
            x = superViewWidth - width;
            y = superViewHeight - height;
            break;
        }
        case JJPageControlPositionTopCenter:
        {
            x = (superViewWidth - width) / 2;
            y = 0;
            break;
        }
        case JJPageControlPositionTopLeft:
        {
            x = 0;
            y = 0;
            break;
        }
        case JJPageControlPositionTopRight:
        {
            x = superViewWidth - width;
            y = 0;
            break;
        }
        default:
            break;
    }
    self.pageControl.frame = CGRectMake(x, y, width, height);
}

#pragma mark - getter

//页码控件
- (UIPageControl *)pageControl
{
    if(_pageControl == nil)
    {
        _pageControl = [[UIPageControl alloc]init];
        _pageControl.pageIndicatorTintColor = [UIColor grayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
        _pageControl.currentPage = 0;
        _pageControl.numberOfPages = self.totalPagesCount;
    }
    return _pageControl;
}

//scrollView
- (UIScrollView *)scrollView
{
    if(_scrollView == nil)
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.autoresizingMask = 0xFF;
        _scrollView.contentMode = UIViewContentModeCenter;
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor whiteColor];
    }
    return _scrollView;
}
//contentViews
- (NSMutableArray *)contentViews
{
    if(_contentViews == nil)
    {
        _contentViews = [[NSMutableArray alloc] init];
    }
    return _contentViews;
}
#pragma mark - setter
- (void)setPageControlHidden:(BOOL)pageControlHidden {
    _pageControlHidden = pageControlHidden;
    self.pageControl.hidden = pageControlHidden;
}
- (void)setAnimationDuration:(NSTimeInterval)animationDuration {
    _animationDuration = animationDuration;
    if (animationDuration > 0) {
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationDuration target:self selector:@selector(animationTimerDidFired:) userInfo:nil repeats:YES];
        [self.animationTimer setFireDate:[NSDate distantFuture]];
        [[NSRunLoop mainRunLoop] addTimer:self.animationTimer forMode:NSRunLoopCommonModes];
    }
}
- (void)setJJPageControlPosition:(JJPageControlPosition)JJPageControlPosition {
    _JJPageControlPosition = JJPageControlPosition;
}
- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    _currentPageIndicatorTintColor  = currentPageIndicatorTintColor;
    self.pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
}
- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    _pageIndicatorTintColor = pageIndicatorTintColor;
    self.pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
}
- (void)setDataSource:(id<JJAutoScrollViewDataSource>)dataSource
{
    _dataSource = dataSource;
    
    self.totalPagesCount = [self.dataSource numberOfPagesInJJAutoScrollView:self];
    
    [self configContentViews];
    
    [self reconfig];
    
}
- (void)setNumberOfPages:(NSInteger (^)(void))numberOfPages
{
    self.totalPagesCount = numberOfPages();
    
    [self reconfig];
}

#pragma mark - 私有方法

- (void)reconfig
{
    self.currentPageIndex = 0;
    if(self.totalPagesCount > 1)
    {
        [self addSubview:self.pageControl];
        self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
        self.scrollView.contentSize = CGSizeMake(3 * CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        
        [self configContentViews];
        
        [self.animationTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.animationDuration]];
    }
    else if (self.totalPagesCount == 1)
    {
        UIView *contentView = nil;
        if(self.fetchContentViewAtIndex)
        {
            contentView = self.fetchContentViewAtIndex(0);
        }
        if([self.dataSource respondsToSelector:@selector(autoScrollView:contentViewAtIndex:)])
        {
            contentView = [self.dataSource autoScrollView:self contentViewAtIndex:0];
        }
        contentView.userInteractionEnabled = YES;
        contentView.frame = self.scrollView.bounds;
        [self.scrollView addSubview:contentView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewTap:)];
        [contentView addGestureRecognizer:tap];
    }
}
//配置contetnView
- (void)configContentViews
{
    //移除掉之前的三个view
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self.contentViews removeAllObjects];
    //重新添加三个view
    
    NSInteger previousPageIndex = [self getAndJudgeIndexWithIndex:self.currentPageIndex - 1];
    NSInteger nextPageIndex = [self getAndJudgeIndexWithIndex:self.currentPageIndex + 1];
    if (self.contentViews == nil)
    {
        self.contentViews = [@[] mutableCopy];
    }
    if(self.fetchContentViewAtIndex)
    {
        [self.contentViews addObject:self.fetchContentViewAtIndex(previousPageIndex)];
        [self.contentViews addObject:self.fetchContentViewAtIndex(self.currentPageIndex)];
        [self.contentViews addObject:self.fetchContentViewAtIndex(nextPageIndex)];
    }
    if([self.dataSource respondsToSelector:@selector(autoScrollView:contentViewAtIndex:)])
    {
        [self.contentViews addObject:[self.dataSource autoScrollView:self contentViewAtIndex:previousPageIndex]];
        [self.contentViews addObject:[self.dataSource autoScrollView:self contentViewAtIndex:self.currentPageIndex]];
        [self.contentViews addObject:[self.dataSource autoScrollView:self contentViewAtIndex:nextPageIndex]];
    }

    //重新计算三个view的坐标
    NSInteger counter = 0;
    for (UIView *contentView in self.contentViews)
    {
        contentView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewTap:)];
        [contentView addGestureRecognizer:tapGesture];
        CGRect rightRect = contentView.frame;
        rightRect.size = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        rightRect.origin = CGPointMake(CGRectGetWidth(self.scrollView.frame) * (counter ++), 0);
        contentView.frame = rightRect;
        [self.scrollView addSubview:contentView];
    }
    [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.scrollView.frame), 0)];
}
//判断越界问题
- (NSInteger)getAndJudgeIndexWithIndex:(NSInteger)index
{
    if(index == -1)//左边越界 选择最后一个
    {
        return self.totalPagesCount-1;
    }
    if(index == self.totalPagesCount)//右边越界 选择第0个
    {
        return 0;
    }
    return index;
}
#pragma mark - 点击事件
- (void)contentViewTap:(UITapGestureRecognizer *)tap
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(autoScrollView:contentViewAtIndex:)])
    {
        [self.delegate autoScrollView:self didSelectScrollViewAtIndex:self.currentPageIndex];
        return;
    }
    !self.didSelectContentViewAtIndex ? : self.didSelectContentViewAtIndex(self.currentPageIndex);
}
#pragma mark - 定时器
- (void)animationTimerDidFired:(NSTimer *)timer
{
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x+CGRectGetWidth(self.scrollView.frame), 0) animated:YES];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.animationTimer setFireDate:[NSDate distantFuture]];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.animationTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.animationDuration]];
}
//滑动的过程中
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    
    if(contentOffsetX <= 0)
    {
        self.currentPageIndex = [self getAndJudgeIndexWithIndex:self.currentPageIndex - 1];
        [self configContentViews];
    }
    if(contentOffsetX >= 2*CGRectGetWidth(self.scrollView.frame))
    {
        self.currentPageIndex = [self getAndJudgeIndexWithIndex:self.currentPageIndex + 1];
        [self configContentViews];
    }
    self.pageControl.currentPage = self.currentPageIndex;
    //判断两张图片的时候 复用改变内存
    if(self.totalPagesCount == 2 && self.contentViews.count)
    {
        if(contentOffsetX < CGRectGetWidth(self.scrollView.frame))
        {
            UIView *contentView = self.contentViews[0];
            CGRect rect = contentView.frame;
            rect.origin.x = 0;
            contentView.frame = rect;
        }
        if(contentOffsetX > CGRectGetWidth(self.scrollView.frame))
        {
            UIView *contentView = self.contentViews[0];
            CGRect rect = contentView.frame;
            rect.origin.x = CGRectGetWidth(self.scrollView.frame)*2;
            contentView.frame = rect;
        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0) animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(autoScrollView:showScrollViewAtIndex:)]) {
        [self.delegate autoScrollView:self showScrollViewAtIndex:self.currentPageIndex];
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEndDecelerating:scrollView];
}
@end






































