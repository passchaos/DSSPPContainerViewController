//
//  DSSCollectionViewCell.m
//  ContainerVC
//
//  Created by passchaos on 15/10/9.
//  Copyright © 2015年 passchaos. All rights reserved.
//

#import "DSSCollectionViewCell.h"

@implementation DSSCollectionViewCell

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _titleLabel = [[UILabel alloc] init];
//        _titleLabel.highlightedTextColor = [UIColor redColor];
        [self.contentView addSubview:_titleLabel];

        // 添加观察者，监测selected状态
        //        [_titleLabel addObserver:self
        //                      forKeyPath:@"highlighted"
        //                         options:NSKeyValueObservingOptionNew
        //                         context:NULL];
        [self initializeFrame];
    }
    return self;
}

- (void)initializeFrame {
    // titleLabel的约束
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary<NSString *, id> *viewDict =
        @{ @"titleLabel" : self.titleLabel };
    NSArray<NSLayoutConstraint *> *cst1 =
        [NSLayoutConstraint constraintsWithVisualFormat:@"|[titleLabel]|"
                                                options:0
                                                metrics:nil
                                                  views:viewDict];
    NSArray<NSLayoutConstraint *> *cst2 =
        [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel]|"
                                                options:0
                                                metrics:nil
                                                  views:viewDict];
    [NSLayoutConstraint
        activateConstraints:[cst1 arrayByAddingObjectsFromArray:cst2]];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSString *, id> *)change
                       context:(nullable void *)context {
    //    if ([keyPath isEqualToString:@"selected"]) {
    //        NSLog(@"%@ %@", change, [self class]);
    //        self.titleLabel.highlighted = [change[@"new"] boolValue];
    //    }
    //    NSLog(@"%@ %@", change, self);
    //    NSLog(@"%@ %s", keyPath, __PRETTY_FUNCTION__);
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}
@end
