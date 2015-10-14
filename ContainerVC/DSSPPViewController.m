//
//  DSSPPContainerViewController.m
//  ContainerVC
//
//  Created by passchaos on 15/10/9.
//  Copyright © 2015年 passchaos. All rights reserved.
//

#import "DSSPPViewController.h"
#import "DSSCollectionViewCell.h"

NSString *reuseID = @"DSSPPViewControllerReuseID";

@interface DSSPPViewController () <UICollectionViewDataSource,
                                   UICollectionViewDelegate>

@property(nonatomic, strong) UICollectionView *ppCollectionView;
// 起填充作用，用于计算子VC的view的frame
@property(nonatomic, strong) UIView *spaceView;
// 当前选中的索引
@property(nonatomic, assign) NSInteger currentIndex;
// 用于显示VC的约束
@property(nonatomic, copy) NSArray<NSLayoutConstraint *> *selectedVCCstArray;
// 选中的VC
@property(nonatomic, strong) UIViewController *selectedVC;
// 活跃VC
@property(nonatomic, strong) UIViewController *activeViewController;
// 根据约束计算出所有子VC应该的frame
@property(nonatomic, assign) CGRect selectedVCFrame;

@end

@implementation DSSPPViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self
        addObserver:self
         forKeyPath:@"currentIndex"
            options:NSKeyValueObservingOptionInitial |
                    NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
            context:NULL];

    // 添加activeViewController的KVO
    [self
        addObserver:self
         forKeyPath:@"activeViewController"
            options:NSKeyValueObservingOptionInitial |
                    NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
            context:NULL];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.selectedVCFrame = self.selectedVC.view.frame;
    NSLog(@"%@", NSStringFromCGRect(self.activeViewController.view.frame));
    NSLog(@"%@", self.childViewControllers);
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //    for (UIViewController *vc in self.childViewControllers) {
    //        [vc beginAppearanceTransition:NO animated:animated];
    //    }

    [self removeObserver:self forKeyPath:@"currentIndex"];
    // 删除对于activeViewController的KVO监听
    [self removeObserver:self forKeyPath:@"activeViewController"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.spaceView];
    self.activeViewController = self.viewControllers.firstObject;

    // 添加转场手势
    //    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
    //    initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    //    [self.spaceView addGestureRecognizer:panGesture];
    UISwipeGestureRecognizer *swipeGestureRecognizer =
        [[UISwipeGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(handleSwipeGestureRecognizer:)];
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(handleSwipeGestureRecognizer:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.spaceView addGestureRecognizer:swipeGestureRecognizer];
    [self.spaceView addGestureRecognizer:swipeLeft];

    NSLog(@"%@", self.viewControllers);
}
- (void)handleSwipeGestureRecognizer:
    (UISwipeGestureRecognizer *)swipeGestureRecognizer {
    NSLog(@"%@", swipeGestureRecognizer);
    NSInteger index =
        [self.viewControllers indexOfObject:self.activeViewController];
    if (swipeGestureRecognizer.direction ==
        UISwipeGestureRecognizerDirectionRight) {
        if (index != 0) {
            self.activeViewController = self.viewControllers[index - 1];
        }
    } else if (swipeGestureRecognizer.direction ==
               UISwipeGestureRecognizerDirectionLeft) {
        if (index != self.viewControllers.count - 1) {
            self.activeViewController = self.viewControllers[index + 1];
        }
    }
    //    self.activeViewController = self.viewControllers[index - 1];
}
- (void)updateActiveFromeViewController:(UIViewController *)fromViewController
                                     to:(UIViewController *)toViewController
                               animated:(BOOL)animated {
    if (fromViewController != nil) {
        NSLog(@"%@ %@", fromViewController, toViewController);
        [fromViewController willMoveToParentViewController:nil];
        [self addChildViewController:toViewController];

        //        toViewController.view.frame = fromViewController.view.frame;
        //        CGRect endFrame = CGRectMake(-375, 70, 375, 597);
        UIView *containerView = fromViewController.view.superview;
        CGRect endFrame = CGRectOffset(fromViewController.view.frame,
                                       -containerView.bounds.size.width, 0);
        //        if (<#condition#>) {
        //            <#statements#>
        //        }
        [self transitionFromViewController:fromViewController
            toViewController:toViewController
            duration:1
            options:animated ? UIViewAnimationOptionCurveEaseInOut
                             : UIViewAnimationOptionTransitionNone
            animations:^{
                toViewController.view.frame = fromViewController.view.frame;
                fromViewController.view.frame = endFrame;
            }
            completion:^(BOOL finished) {
                [fromViewController removeFromParentViewController];
                [toViewController didMoveToParentViewController:self];
            }];
    } else {
        [self addChildViewController:toViewController];
        [self.spaceView addSubview:toViewController.view];
        //        toViewController.view.frame = self.spaceView.frame;
        toViewController.view.frame = self.spaceView.bounds;
        [toViewController didMoveToParentViewController:self];
    }

    // 更改对应activeViewController的cell
    NSInteger index = [self.viewControllers indexOfObject:toViewController];
    DSSCollectionViewCell *cell =
        (DSSCollectionViewCell *)[self.ppCollectionView
            cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index
                                                       inSection:0]];
    [cell.titleLabel setTextColor:[UIColor redColor]];
}

#pragma mark - KVO相关设置
// 关闭currentIndex的自动KVO，改为手动模式，以便排除点击选中cell仍然执行耗时操作
+ (BOOL)automaticallyNotifiesObserversOfCurrentIndex {
    return NO;
}
// 关闭activeViewController的自动KVO
+ (BOOL)automaticallyNotifiesObserversOfActiveViewController {
    return NO;
}
- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (_currentIndex != currentIndex) {
        [self willChangeValueForKey:@"currentIndex"];
        _currentIndex = currentIndex;
        [self didChangeValueForKey:@"currentIndex"];
    }
}
- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSString *, id> *)change
                       context:(nullable void *)context {
    if ([keyPath isEqualToString:@"activeViewController"]) {
        //        NSLog(@"%@", change);
        UIViewController *oldVC = [change valueForKey:@"old"];
        UIViewController *newVC = [change valueForKey:@"new"];
        [self updateActiveFromeViewController:oldVC to:newVC animated:YES];
    }
}

#pragma mark - collectionViewDelegate
- (void)collectionView:(nonnull UICollectionView *)collectionView
    didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSLog(@"%s %ld", __PRETTY_FUNCTION__, indexPath.item);
    self.currentIndex = indexPath.item;
    self.activeViewController = self.viewControllers[indexPath.item];

    DSSCollectionViewCell *cell = (DSSCollectionViewCell *)
        [collectionView cellForItemAtIndexPath:indexPath];
    [cell.titleLabel setTextColor:[UIColor redColor]];
    //        [cell setDss_selected:YES];
}
- (void)collectionView:(nonnull UICollectionView *)collectionView
    didDeselectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    DSSCollectionViewCell *cell = (DSSCollectionViewCell *)
        [collectionView cellForItemAtIndexPath:indexPath];
    [cell.titleLabel setTextColor:[UIColor blackColor]];
    //    [cell setDss_selected:NO];
}

#pragma mark - collectionViewDataSource
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.viewControllers.count;
}

- (nonnull UICollectionViewCell *)
        collectionView:(nonnull UICollectionView *)collectionView
cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DSSCollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:reuseID
                                                  forIndexPath:indexPath];

    UIViewController *vc = self.viewControllers[indexPath.item];
    cell.titleLabel.text =
        vc.title == nil ? NSStringFromClass([vc class]) : vc.title;

    return cell;
}

#pragma mark - lazy load
- (NSNumber *)scrollableZoneHeight {
    if (_scrollableZoneHeight == nil) {
        _scrollableZoneHeight = @50;
    }
    return _scrollableZoneHeight;
}
- (UIView *)spaceView {
    if (_spaceView == nil) {
        _spaceView = [[UIView alloc] init];
        [self.view addSubview:_spaceView];

        // 设置约束
        _spaceView.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary<NSString *, id> *viewDict = @{
            @"spaceView" : _spaceView,
            @"scrollableView" : self.ppCollectionView,
            @"bottomLayoutGuide" : self.bottomLayoutGuide
        };
        NSArray<NSLayoutConstraint *> *cst1 =
            [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[spaceView]|"
                                                    options:0
                                                    metrics:nil
                                                      views:viewDict];
        NSArray<NSLayoutConstraint *> *cst2 = [NSLayoutConstraint
            constraintsWithVisualFormat:
                @"V:[scrollableView][spaceView][bottomLayoutGuide]"
                                options:0
                                metrics:nil
                                  views:viewDict];
        [NSLayoutConstraint
            activateConstraints:[cst1 arrayByAddingObjectsFromArray:cst2]];
    }
    return _spaceView;
}
- (UICollectionView *)ppCollectionView {
    if (_ppCollectionView == nil) {
        UICollectionViewFlowLayout *flowLayout =
            [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.itemSize =
            CGSizeMake(80, self.scrollableZoneHeight.floatValue - 0.1);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

        _ppCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                               collectionViewLayout:flowLayout];

        // add to superview
        [self.view addSubview:_ppCollectionView];
        [self setupPPCollectionView];
    }
    return _ppCollectionView;
}

- (void)setupPPCollectionView {
    // register reuse collectionViewCell
    [self.ppCollectionView registerClass:[DSSCollectionViewCell class]
              forCellWithReuseIdentifier:reuseID];
    self.ppCollectionView.delegate = self;
    self.ppCollectionView.dataSource = self;
    self.ppCollectionView.showsHorizontalScrollIndicator = NO;
    self.ppCollectionView.backgroundColor = [UIColor grayColor];

    self.ppCollectionView.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary<NSString *, id> *viewDict = @{
        @"ppCV" : self.ppCollectionView,
        @"topLayoutGuide" : self.topLayoutGuide
    };
    NSDictionary<NSString *, id> *metricDict =
        @{ @"height" : self.scrollableZoneHeight };
    NSArray<NSLayoutConstraint *> *cst1 =
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[ppCV]|"
                                                options:0
                                                metrics:nil
                                                  views:viewDict];
    NSArray<NSLayoutConstraint *> *cst2 = [NSLayoutConstraint
        constraintsWithVisualFormat:@"V:|[topLayoutGuide][ppCV(height)]"
                            options:0
                            metrics:metricDict
                              views:viewDict];
    [NSLayoutConstraint
        activateConstraints:[cst1 arrayByAddingObjectsFromArray:cst2]];
}

#pragma mark - containerViewController related
//- (void)addChildViewController:(nonnull UIViewController *)childController {
//    [super addChildViewController:childController];
//
//    // 首先设置viewControllers数组，后边的self.viewControllers使用的是getter
//    _viewControllers =
//        [self.viewControllers arrayByAddingObject:childController];
//    [self.ppCollectionView reloadData];
//    //
//    [childController didMoveToParentViewController:self];
//}

#pragma mark - 设置activeViewController
// 监听activeViewController
- (void)setActiveViewController:(UIViewController *)activeViewController {
    if (_activeViewController != activeViewController) {
        [self willChangeValueForKey:@"activeViewController"];
        _activeViewController = activeViewController;
        [self didChangeValueForKey:@"activeViewController"];
    }
}

#pragma mark - viewControllers的setter和getter
@synthesize viewControllers = _viewControllers;
//- (void)setViewControllers:
//    (NSArray<__kindof UIViewController *> *)viewControllers {
//    //    _viewControllers = viewControllers;
//    //    [self.ppCollectionView reloadData];
//    for (UIViewController *vc in viewControllers) {
//        [self addChildViewController:vc];
//    }
//}

- (NSArray<UIViewController *> *)viewControllers {
    if (_viewControllers == nil) {
        // 初始时从子控制器获得对应数组
        _viewControllers = [NSArray array];
    }
    return _viewControllers;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - appearance transition
//- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
//    return NO;
//}

@end
