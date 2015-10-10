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
// 根据约束计算出所有子VC应该的frame
@property(nonatomic, assign) CGRect selectedVCFrame;

@end

@implementation DSSPPViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //    for (UIViewController *vc in self.childViewControllers) {
    //        [vc beginAppearanceTransition:YES animated:animated];
    //    }
//    [self.selectedVC beginAppearanceTransition:YES animated:animated];
    [self
        addObserver:self
         forKeyPath:@"currentIndex"
            options:NSKeyValueObservingOptionInitial |
                    NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
            context:NULL];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //    for (UIViewController *vc in self.childViewControllers) {
    //        [vc endAppearanceTransition];
    //    }
//    [self.selectedVC endAppearanceTransition];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.selectedVCFrame = self.selectedVC.view.frame;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //    for (UIViewController *vc in self.childViewControllers) {
    //        [vc beginAppearanceTransition:NO animated:animated];
    //    }
//    [self.selectedVC beginAppearanceTransition:NO animated:animated];
    [self removeObserver:self forKeyPath:@"currentIndex"];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //    for (UIViewController *vc in self.childViewControllers) {
    //        [vc endAppearanceTransition];
    //    }
//    [self.selectedVC endAppearanceTransition];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    [self.view addSubview:self.spaceView];
    self.currentIndex = 0;
}

#pragma mark - 监听currentIndex
// 关闭currentIndex的自动KVO，改为手动模式，以便排除点击选中cell仍然执行耗时操作
+ (BOOL)automaticallyNotifiesObserversOfCurrentIndex {
    return NO;
}
- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (_currentIndex != currentIndex) {
        [self willChangeValueForKey:@"currentIndex"];
        _currentIndex = currentIndex;
        [self didChangeValueForKey:@"currentIndex"];
    } else {
        _currentIndex = currentIndex;
    }
}
- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSString *, id> *)change
                       context:(nullable void *)context {
    if ([keyPath isEqualToString:@"currentIndex"]) {
        NSInteger newIndex = [change[@"new"] integerValue];
        UIViewController *newVC = self.viewControllers[newIndex];
        if (change[@"old"] == nil) {
            [self.ppCollectionView
                selectItemAtIndexPath:[NSIndexPath indexPathForItem:newIndex
                                                          inSection:0]
                             animated:NO
                       scrollPosition:
                           UICollectionViewScrollPositionCenteredHorizontally];
//            [self collectionView:self.ppCollectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:newIndex inSection:0]];
            // 添加childViewController的view
            [self addChildViewController:newVC];
            [self.view addSubview:newVC.view];
            //            NSLog(@"%@",
            //            NSStringFromCGRect(self.spaceView.frame));
            //            newVC.view.frame = self.spaceView.frame;

            // 设置newVC的root view的约束
            newVC.view.translatesAutoresizingMaskIntoConstraints = NO;
            // 为了防止冲突，先删除原有的约束
            NSDictionary *viewDict = @{
                @"scrollableView" : self.ppCollectionView,
                @"childCV" : newVC.view,
                @"bottomLayoutGuide" : self.bottomLayoutGuide
            };
            NSArray<NSLayoutConstraint *> *cst1 = [NSLayoutConstraint
                constraintsWithVisualFormat:
                    @"V:[scrollableView][childCV][bottomLayoutGuide]"
                                    options:0
                                    metrics:nil
                                      views:viewDict];
            NSArray<NSLayoutConstraint *> *cst2 =
                [NSLayoutConstraint constraintsWithVisualFormat:@"|[childCV]|"
                                                        options:0
                                                        metrics:nil
                                                          views:viewDict];
            [NSLayoutConstraint
                activateConstraints:[cst1 arrayByAddingObjectsFromArray:cst2]];
            [newVC didMoveToParentViewController:self];
            self.selectedVC = newVC;
        } else {
            //            return;
            NSInteger oldIndex = [change[@"old"] integerValue];

            UIViewController *oldVC =
                self.viewControllers[[change[@"old"] integerValue]];
            [self.view addSubview:newVC.view];

            [oldVC willMoveToParentViewController:nil];
            [self addChildViewController:newVC];

            CGRect oldVCNewFrame;
            CGFloat offsetX = self.view.frame.size.width;
            if (newIndex > oldIndex) {
                newVC.view.frame =
                    CGRectOffset(self.selectedVCFrame, offsetX, 0);
                oldVCNewFrame = CGRectOffset(self.selectedVCFrame, -offsetX, 0);
            } else {
                newVC.view.frame =
                    CGRectOffset(self.selectedVCFrame, -offsetX, 0);
                oldVCNewFrame = CGRectOffset(self.selectedVCFrame, offsetX, 0);
            }

            // 进行新旧VC的切换
            [self transitionFromViewController:oldVC
                toViewController:newVC
                duration:0.5
                options:UIViewAnimationOptionCurveEaseInOut
                animations:^{
                    newVC.view.frame = self.selectedVCFrame;
                    oldVC.view.frame = oldVCNewFrame;
                }
                completion:^(BOOL finished) {
                    [oldVC.view removeFromSuperview];
                    [oldVC removeFromParentViewController];
                    [newVC didMoveToParentViewController:self];
                    self.selectedVC = newVC;
                }];
        }
    }
}

#pragma mark - collectionViewDelegate
- (void)collectionView:(nonnull UICollectionView *)collectionView
    didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
        NSLog(@"%s %ld", __PRETTY_FUNCTION__, indexPath.item);
    self.currentIndex = indexPath.item;
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
- (void)addChildViewController:(nonnull UIViewController *)childController {
    [super addChildViewController:childController];

    // 首先设置viewControllers数组，后边的self.viewControllers使用的是getter
    _viewControllers =
        [self.viewControllers arrayByAddingObject:childController];
    [self.ppCollectionView reloadData];
    //
    [childController didMoveToParentViewController:self];
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
