//
//  DSSViewController.m
//  ContainerVC
//
//  Created by passchaos on 15/10/9.
//  Copyright © 2015年 passchaos. All rights reserved.
//

#import "DSSViewController.h"

@interface DSSViewController ()
@property(nonatomic, strong) UILabel *titleLabel;
@end

@implementation DSSViewController

//- (void)willMoveToParentViewController:(nullable UIViewController *)parent {
//    [super willMoveToParentViewController:parent];
//    NSLog(@"%@ %s %@", [self class], __PRETTY_FUNCTION__, parent);
//}
//
//- (void)didMoveToParentViewController:(nullable UIViewController *)parent {
//    [super didMoveToParentViewController:parent];
//    NSLog(@"%@ %s %@", [self class], __PRETTY_FUNCTION__, parent);
//}
//- (void)removeFromParentViewController {
//    [super removeFromParentViewController];
//    NSLog(@"%@ %s", [self class], __PRETTY_FUNCTION__);
//}

- (void)setTitle:(NSString *_Nullable)title {
    [super setTitle:title];
    self.titleLabel.text = title;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.frame = CGRectMake(50, 200, 80, 50);
        [self.view addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
