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
        [self addSubview:_titleLabel];
        
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

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}
@end
