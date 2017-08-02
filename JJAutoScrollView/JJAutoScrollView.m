//
//  JJAutoScrollView.m
//  Banner滑动
//
//  Created by 房俊杰 on 2015/2/6.
//  Copyright © 2015年 上海涵予信息科技有限公司. All rights reserved.
//

#import "JJAutoScrollView.h"


@interface JJAutoScrollView () <UICollectionViewDelegate,UICollectionViewDataSource>

/** layout */
@property (nonatomic,strong) UICollectionViewFlowLayout *layout;
/** collectionView */
@property (nonatomic,strong) UICollectionView *collectionView;
/** 页码控制 */
@property (nonatomic,strong) UIPageControl *pageControl;
/** 定时器 */
@property (nonatomic,strong) NSTimer *animationTimer;
/** 总页码 */
@property (nonatomic,assign) NSInteger totalPageCount;
/** 乘数 */
@property (nonatomic,assign) NSInteger multiplier;
/** 数据源 */
@property (nonatomic,strong) NSMutableArray *dataArray;

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
    
    [self addSubview:self.collectionView];
    [self addSubview:self.pageControl];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"layoutSubviews");
    self.layout.itemSize = self.bounds.size;
    self.collectionView.collectionViewLayout = self.layout;
    self.collectionView.frame = self.bounds;
    //页码控制器
    CGFloat superViewWidth = CGRectGetWidth(self.frame);
    CGFloat superViewHeight = CGRectGetHeight(self.frame);
    CGFloat width = self.totalPageCount * 18;
    CGFloat height = 20;
    CGFloat x = 0;
    CGFloat y = 0;
    switch (self.pageControlPosition) {
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
    [self resumeTimer:self.animationTimer];
    [self.collectionView reloadData];
}
#pragma mark - 懒加载
/** layout */
- (UICollectionViewFlowLayout *)layout
{
    if(!_layout){
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.itemSize = self.bounds.size;
        _layout.minimumLineSpacing = 0;
        _layout.minimumInteritemSpacing = 0;
    }
    return _layout;
}
/** collectionView */
- (UICollectionView *)collectionView
{
    if(!_collectionView){
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[JJAutoScrollViewCell class] forCellWithReuseIdentifier:@"JJAutoScrollViewCell"];
    }
    return _collectionView;
}
/** 页码控制 */
- (UIPageControl *)pageControl
{
    if(!_pageControl){
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.pageIndicatorTintColor = [UIColor grayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor blueColor];
        _pageControl.currentPage = 0;
    }
    return _pageControl;
}
/** 乘数 */
- (NSInteger)multiplier {
    return 100000;
}
/** 定时器 */
- (NSTimer *)animationTimer
{
    if(!_animationTimer){
        _animationDuration = 3.0;
        _animationTimer = [NSTimer scheduledTimerWithTimeInterval:self.animationDuration target:self selector:@selector(animationTimerDidFired:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_animationTimer forMode:NSRunLoopCommonModes];
        [self pasueTimer:_animationTimer];
    }
    return _animationTimer;
}
- (void)animationTimerDidFired:(NSTimer *)timer {
    [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x + CGRectGetWidth(self.collectionView.frame), 0) animated:YES];
}
/** 数据源 */
- (NSMutableArray *)dataArray
{
    if(!_dataArray){
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
#pragma mark - 代理UICollectionViewDelegate,UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.totalPageCount <= 1) return self.totalPageCount;
    return self.totalPageCount * self.multiplier;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JJAutoScrollViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JJAutoScrollViewCell" forIndexPath:indexPath];
    if (self.totalPageCount > 0) {
        cell.showView = self.dataArray[indexPath.row % self.totalPageCount];
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(autoScrollView:didSelectScrollViewAtIndex:)]) {
        [self.delegate autoScrollView:self didSelectScrollViewAtIndex:indexPath.row % self.totalPageCount];
    }
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.animationDuration > 0) [self pasueTimer:self.animationTimer];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.animationDuration > 0) [self resumeTimer:self.animationTimer afterTimeInterval:self.animationDuration];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.totalPageCount < 1) return;
    NSInteger index = (NSInteger)(scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame)) % self.totalPageCount;
    self.pageControl.currentPage = index;
    // 判断第一张/最后一张 跳到中间
    if (scrollView.contentOffset.x == 0 || scrollView.contentOffset.x == CGRectGetWidth(scrollView.frame) * (self.totalPageCount * self.multiplier - 1)) {
        [self.collectionView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame) * self.totalPageCount * self.multiplier / 2, 0) animated:NO];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(autoScrollView:showScrollViewAtIndex:)]) {
        [self.delegate autoScrollView:self showScrollViewAtIndex:self.pageControl.currentPage];
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEndDecelerating:scrollView];
}
#pragma mark - setter
- (void)setDataSource:(id<JJAutoScrollViewDataSource>)dataSource {
    _dataSource = dataSource;
    
    self.totalPageCount = [self.dataSource numberOfPagesInJJAutoScrollView:self];
    
    [self.dataArray removeAllObjects];
    for (NSInteger i = 0;i < self.totalPageCount;i++) {
        UIView *view = [self.dataSource autoScrollView:self contentViewAtIndex:i];
        [self.dataArray addObject:view];
    }
    if (self.totalPageCount <= 1) {
        self.collectionView.scrollEnabled = NO;
        self.pageControl.hidden = YES;
        [self.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
        [self pasueTimer:self.animationTimer];
    } else {
        self.collectionView.pagingEnabled = YES;
        //设置页码控制
        self.pageControl.hidden = NO;
        self.pageControl.numberOfPages = self.totalPageCount;
        [self.collectionView setContentOffset:CGPointMake(CGRectGetWidth(self.collectionView.frame) * (self.totalPageCount * self.multiplier / 2), 0) animated:NO];
        [self resumeTimer:self.animationTimer afterTimeInterval:self.animationDuration];
    }
    self.totalPageCount = self.dataArray.count;
    [self.collectionView reloadData];
}
- (void)setAnimationDuration:(NSTimeInterval)animationDuration {
    _animationDuration = animationDuration;
    if (animationDuration > 0 && self.totalPageCount > 1) {
        [self resumeTimer:self.animationTimer];
    } else {
        [self pasueTimer:self.animationTimer];
    }
}
- (void)setPageControlPosition:(JJPageControlPosition)pageControlPosition{
    _pageControlPosition = pageControlPosition;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
- (void)setPageControlHidden:(BOOL)pageControlHidden {
    _pageControlHidden = pageControlHidden;
    self.pageControl.hidden = pageControlHidden;
}
- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    _pageIndicatorTintColor = pageIndicatorTintColor;
    self.pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
}
- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    self.pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
}
#pragma mark - 定时器function
//暂停
- (void)pasueTimer:(NSTimer *)timer {
    if (!timer.valid) return;
    timer.fireDate = [NSDate distantFuture];
}
//重启
- (void)resumeTimer:(NSTimer *)timer {
    if (!timer.valid) return;
    timer.fireDate = [NSDate date];
}
//经过timeInterval重启
- (void)resumeTimer:(NSTimer *)timer afterTimeInterval:(NSTimeInterval)timeInterval {
    if (!timer.valid) return;
    timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
}
@end

#pragma mark -
#pragma mark - collectionViewCell
@interface JJAutoScrollViewCell()

@end

@implementation JJAutoScrollViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.showView.frame = self.bounds;
}
- (void)setShowView:(UIView *)showView {
    _showView = showView;
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.contentView addSubview:showView];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end



































