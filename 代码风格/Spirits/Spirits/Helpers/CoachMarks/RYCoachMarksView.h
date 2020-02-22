//
//  RYCoachMarksView.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/5/15.
//  Copyright © 2019 RuiYu. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RYCoachMarksView : UIView

@property (nonatomic) BOOL isShowHoles;
@property (nonatomic, copy) NSArray* holes;
@property (nonatomic, copy) NSArray* texts;
@property (nonatomic, strong) void (^block)(UIView* view);

- (void)animateGuides;

@end
