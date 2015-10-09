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

@end

@implementation DSSPPViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    if (vc.title == nil) {
        cell.titleLabel.text = NSStringFromClass([vc class]);
    } else {
        cell.titleLabel.text = vc.title;
    }

    return cell;
}

#pragma mark - lazy load
- (NSNumber *)scrollableZoneHeight {
    if (_scrollableZoneHeight == nil) {
        _scrollableZoneHeight = @50;
    }
    return _scrollableZoneHeight;
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

    NSLog(@"%@", NSStringFromUIEdgeInsets(self.ppCollectionView.contentInset));
}

#pragma mark - containerViewController related
- (void)addChildViewController:(nonnull UIViewController *)childController {
    [super addChildViewController:childController];
    [self setViewControllers:self.childViewControllers];
    [self.view addSubview:childController.view];

    // 设置childController的view的约束
    childController.view.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewDict = @{
        @"scrollableView" : self.ppCollectionView,
        @"childCV" : childController.view,
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

    //
    [childController didMoveToParentViewController:self];
}

#pragma mark - viewControllers的setter和getter
@synthesize viewControllers = _viewControllers;
- (void)setViewControllers:
    (NSArray<__kindof UIViewController *> *)viewControllers {
    _viewControllers = viewControllers;
    [self.ppCollectionView reloadData];
}

- (NSArray<UIViewController *> *)viewControllers {
    if (_viewControllers == nil) {
        // 初始时从子控制器获得对应数组
        _viewControllers = self.childViewControllers;
    }
    return _viewControllers;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
