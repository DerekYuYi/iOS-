//
//  RYCoachMarksView.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/5/15.
//  Copyright © 2019 RuiYu. All rights reserved.
//

#import "RYCoachMarksView.h"

static const CGFloat KRYRadiusPointer = 2;
static const CGFloat KRYWidthConnector = 1;
static const CGFloat KRYHeightConnector = 88;
static const CGFloat KRYWidthButton = 66;
static const CGFloat KRYWidthMargin = 16;
static const CGFloat KRYHeightMargin = 16;

static NSInteger KRYTagControl = 1963237612;

static NSString* const KRYKeyHolesAnimationProgress = @"KRYKeyHolesAnimationProgress";
static NSString* const KRYTitleButt = @"知道啦";


@interface RYCoachMarksView () <CAAnimationDelegate>
{
    NSTimer* animationTimer;
}
@end

@implementation RYCoachMarksView

#pragma mark - Init
/// this is the designated initializer: https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class
/// but this is not called when the cell is initialized from storyboard
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self doInit_RYCoachMarksView];
    }
    return self;
}

/// when the cell is initialized from storyboard, this is called instead of the designated initializer - initWithFrame:
/// as stated in https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self doInit_RYCoachMarksView];
    }
    return self;
}

// NOTE: designing designated initializer requires careful design and well documented initializers
//  for simplicity, use a common initialization methods instead, and use 'uniqe' method name to prevent inheritance (which may cause init 'leaks')
// NOTE2: this function doesn't guarantee to be called only once
// httRY://developer.apple.com/library/ios/documentation/General/Conceptual/CocoaEncyclopedia/Initialization/Initialization.html#//apple_ref/doc/uid/TP40010810-CH6-SW3
- (void)doInit_RYCoachMarksView {
    _isShowHoles = NO;
    _holes = nil;
    _texts = nil;
    
    animationTimer = nil;

    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.80];
}

#pragma mark - Animation Delegate (for holes)
- (void)animationDidStart:(CAAnimation *)anim {
    if (animationTimer == nil) {
        animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60 target:self selector:@selector(holesAnimationTimer:) userInfo:nil repeats:YES];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)animationCompleted
{
    if (animationTimer) {
        [animationTimer invalidate];
        animationTimer = nil;
    }
}

- (void)holesAnimationTimer:(NSTimer*)timer;
{
    CGRect rect = CGRectZero;
    for (UIView* view in self.holes) {
        if ([view isKindOfClass:[UIView class]]) {
            CGRect hole = [self rectForView:view];
            if (CGRectEqualToRect(rect, CGRectZero)) {
                rect = hole;
            } else {
                rect = CGRectUnion(rect, hole);
            }
        }
    }
    
    [self setNeedsDisplayInRect:rect];
}

#pragma mark -
#pragma mark ======== Interface ========

- (void)animateGuides
{
    CFTimeInterval beginHolesAnimation = 0.12;
    CFTimeInterval durationHolesAnimation = 0.88;

    [self _animateHolesFrom:beginHolesAnimation to:durationHolesAnimation];
    [self performSelector:@selector(_animateHints) withObject:nil afterDelay:beginHolesAnimation+durationHolesAnimation];
}

- (void)_animateHolesFrom:(CFTimeInterval)begin to:(CFTimeInterval)duration
{
    CABasicAnimation* holdAnimate = [CABasicAnimation animationWithKeyPath:KRYKeyHolesAnimationProgress];
    [holdAnimate setFromValue:@(0.0)];
    [holdAnimate setToValue:@(1.0)];
    [holdAnimate setBeginTime:CACurrentMediaTime()+begin];
    [holdAnimate setDuration:duration];
    [holdAnimate setDelegate:self];
    [holdAnimate setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self.layer addAnimation:holdAnimate forKey:KRYKeyHolesAnimationProgress];
    [self.layer setValue:@(1.0) forKey:KRYKeyHolesAnimationProgress];
}

- (void)_animateHints
{
    [self.texts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:NSString.class]) {
            [self _animateAHint:idx];
        }
    }];
}

- (void)_animateAHint:(NSInteger)idx
{
    CFTimeInterval intervalAnimation = 0.68;
    
    if (self.texts.count <= 0) { return; }
    if (self.holes.count <= 0) { return; }
    
    NSString* text = [self.texts objectAtIndex:idx];
    UIView* view = [self.holes objectAtIndex:idx];
    if (text && [text isKindOfClass:NSString.class] &&
        view && [view isKindOfClass:[UIView class]]) {
        view.tag = KRYTagControl + idx;
        BOOL isDown = [self viewOnTop:view];
        
        [self animatePointerForAnchor:view direction:isDown afterDelay:0];
        [self animateConnectorForAnchor:view direction:isDown afterDelay:intervalAnimation*idx+0.1 duration:0.26];
        [self animateLabel:text forAnchorView:view direction:isDown afterDelay:intervalAnimation*idx+0.36 duration:0.36];
    }
}


- (void)animatePointerForAnchor:(UIView*)anchorView direction:(BOOL)isDown afterDelay:(CFTimeInterval)delay
{
    // 1st
    UIView* pointer1 = [[UIView alloc] initWithFrame:[self rectForAnchorPointer:anchorView direction:isDown]];
    pointer1.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.88];
    pointer1.layer.cornerRadius = pointer1.frame.size.width/2.0;
    pointer1.alpha = 0;
    [self addSubview:pointer1];
    
    [UIView animateWithDuration:0.01 delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
        pointer1.alpha = 1.0;
    } completion:^(BOOL finished) {
    }];
    
    
    // 2nd
    UIView* pointer2 = [[UIView alloc] initWithFrame:[self rectForAnchorPointer:anchorView direction:isDown]];
    pointer2.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.68];
    pointer2.layer.cornerRadius = pointer2.frame.size.width/2.0;
    pointer2.alpha = 0;
    [self addSubview:pointer2];
    
    [UIView animateWithDuration:0.01 delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
        pointer2.alpha = 1.0;
    } completion:^(BOOL finished) {
    }];
}

- (void)animateConnectorForAnchor:(UIView*)anchorView direction:(BOOL)isDown afterDelay:(CFTimeInterval)delay duration:(CFTimeInterval)duration
{
    UIView* connector = [[UIView alloc] initWithFrame:[self rectForConnectStartForAnchor:anchorView direction:isDown]];
    connector.backgroundColor = [UIColor whiteColor];
    [self addSubview:connector];
    
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseIn animations:^{
        connector.frame = [self rectForConnectEndForAnchor:anchorView direction:isDown];
    } completion:nil];
}

- (void)animateLabel:(NSString*)text forAnchorView:(UIView*)anchorView direction:(BOOL)isDown afterDelay:(CFTimeInterval)delay duration:(CFTimeInterval)duration
{
    // use container for: 1. label margin; 2. animation
    CGRect rect = [self rectForLabel:text forAnchorView:anchorView direction:isDown];
    UIView* container = [[UIView alloc] initWithFrame:rect];
    container.tag = anchorView.tag;
    container.backgroundColor = [UIColor colorWithRed:232.0/255.0 green:249.0/255.0 blue:1.0 alpha:1.0];
    container.layer.masksToBounds = YES;
    container.layer.cornerRadius = 5.0;
    [self addSubview:container];
    
    // real label inside container
    CGRect labelFrame = container.bounds;
    labelFrame.origin.x += KRYWidthMargin/2.0;
    labelFrame.size.width -= KRYWidthMargin;
    UILabel* label = [[UILabel alloc] initWithFrame:labelFrame];
    label.tag = anchorView.tag;
    label.backgroundColor = [UIColor clearColor];
    label.font = [self font];
    label.textColor = UIColor.blackColor;
    label.text = text;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    [container addSubview:label];
    
    CGRect rectStart = CGRectMake(rect.origin.x, rect.origin.y, 0, rect.size.height);
    container.frame = rectStart;
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
        container.frame = rect;
    } completion:^(BOOL finished) {
        [self animateButton:container forAnchorView:anchorView];
    }];
}

- (void)animateButton:(UIView*)label forAnchorView:(UIView*)anchorView
{
    if (label) {
        UIButton* button = [[UIButton alloc] initWithFrame:[self rectForButtonBeside:label forAnchorView:anchorView]];
        button.tag = label.tag;
        button.backgroundColor = [UIColor clearColor];
        button.titleLabel.font = [self font];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:KRYTitleButt forState:UIControlStateNormal];
        
        // border
        button.layer.masksToBounds = true;
        button.layer.cornerRadius = 5.0;
        button.layer.borderWidth = 0.5;
        button.layer.borderColor = UIColor.whiteColor.CGColor;
        
        // hook
        [button addTarget:self action:@selector(buttTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        // animate
        //label.transform = CGAffineTransformMakeScale(0.1, 0.1);
        /*
        PORYpringAnimation* animation = [PORYpringAnimation animation];
        animation.property = [POPAnimatableProperty propertyWithName:kPOPLayerScaleXY];
        animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.1, 0.1)];
        animation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
        animation.springSpeed = 20;
        animation.springBounciness = 20;
        animation.name = @"animateTranslationXY";
        [button.layer pop_addAnimation:animation forKey:@"animateTranslationXY"];
        */
    }
}

#pragma mark -
#pragma mark ======== Actions ========
- (void)buttTapped:(UIButton*)button
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self removeFromSuperview];
    
    UIView* targetView = nil;
    if (button) {
        NSInteger idx = button.tag - KRYTagControl;
        if (idx >= 0 && idx < self.holes.count) {
            targetView = [self.holes objectAtIndex:idx];
        }
    }
    if (self.block) {
        self.block(targetView);
    }
}

#pragma mark -
#pragma mark ======== Layout ========

- (BOOL)viewOnTop:(UIView*)view
{
    CGRect rect = [self rectForView:view];
    return rect.origin.y + rect.size.height/2.0 < self.bounds.size.height/2.0;
}

- (CGRect)rectForView:(UIView*)view
{
    return [self convertRect:view.bounds fromView:view];
}

- (CGRect)rectForAnchorPointer:(UIView*)anchorView direction:(BOOL)isDown
{
    CGRect rect = [self rectForView:anchorView];
    
    if (isDown) {
        CGPoint pt = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect) + KRYRadiusPointer*3 + 1);
        return CGRectMake(pt.x - KRYRadiusPointer, pt.y - KRYRadiusPointer, KRYRadiusPointer*2, KRYRadiusPointer*2);
    } else {
        CGPoint pt = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect) - KRYRadiusPointer*3 - 1);
        return CGRectMake(pt.x - KRYRadiusPointer, pt.y - KRYRadiusPointer, KRYRadiusPointer*2, KRYRadiusPointer*2);
    }
}

- (CGRect)rectForConnectStartForAnchor:(UIView*)anchorView direction:(BOOL)isDown
{
    CGRect rectPointer = [self rectForAnchorPointer:anchorView direction:isDown];
    return CGRectMake(CGRectGetMidX(rectPointer) - KRYWidthConnector/2.0,
                      CGRectGetMidY(rectPointer) - KRYWidthConnector/2.0,
                      KRYWidthConnector,
                      KRYWidthConnector);
    
}

- (CGRect)rectForConnectEndForAnchor:(UIView*)anchorView direction:(BOOL)isDown
{
    CGRect rectConnectStart = [self rectForConnectStartForAnchor:anchorView direction:isDown];
    if (isDown) {
        rectConnectStart.size.height += KRYHeightConnector;
    } else {
        rectConnectStart.size.height -= KRYHeightConnector;
    }
    
    return rectConnectStart;
}


- (CGRect)rectForLabel:(NSString*)text forAnchorView:(UIView*)anchorView direction:(BOOL)isDown
{
    CGFloat width = [self widthForOneLineText:text withFont:[self font]];
    width += KRYWidthMargin;
    
    if (width > self.bounds.size.width*5.0/6.0 - KRYWidthButton) {
        width = self.bounds.size.width*5.0/6.0 - KRYWidthButton;
    }
    CGFloat height = [self heightForText:text withFixedWidth:width-KRYWidthMargin withFont:[self font]];
    height += KRYHeightMargin;
    
    CGRect refRect = [self rectForConnectEndForAnchor:anchorView direction:isDown];
    CGRect rect;
    if (isDown) {
        rect = CGRectMake(CGRectGetMidX(refRect) - width/2.0,
                          CGRectGetMaxY(refRect),
                          width,
                          height);
    } else {
        rect = CGRectMake(CGRectGetMidX(refRect) - width/2.0,
                          CGRectGetMinY(refRect) - height,
                          width,
                          height);
    }
    
    // 1. restrict the rect in bounds
    if (CGRectGetMaxX(rect) > CGRectGetMaxX(self.bounds) - KRYWidthMargin) {
        rect = CGRectOffset(rect, CGRectGetMaxX(self.bounds) - KRYWidthMargin - CGRectGetMaxX(rect) , 0);
    } else if (CGRectGetMinX(rect) < CGRectGetMinX(self.bounds) + KRYWidthMargin) {
        rect = CGRectOffset(rect, CGRectGetMinX(self.bounds) + KRYWidthMargin - CGRectGetMinX(rect) , 0);
    }
    
    // 2. leave enough space for button
    if ([self isButtonOnRight:anchorView]) {
        // button on the right
        if (CGRectGetMaxX(rect) > CGRectGetMaxX(self.bounds) - KRYWidthMargin - KRYWidthButton) {
            rect = CGRectOffset(rect, CGRectGetMaxX(self.bounds) - KRYWidthMargin - KRYWidthButton - CGRectGetMaxX(rect) , 0);
        }
    } else {
        // button on the left
        if (CGRectGetMinX(rect) < CGRectGetMinX(self.bounds) + KRYWidthMargin + KRYWidthButton) {
            rect = CGRectOffset(rect, CGRectGetMinX(self.bounds) + KRYWidthMargin + KRYWidthButton - CGRectGetMinX(rect) , 0);
        }
    }
    
    return rect;
}


- (CGRect)rectForButtonBeside:(UIView*)sideView forAnchorView:(UIView*)anchorView
{
    if (!sideView || !anchorView) return CGRectZero;
    
    // width the button holding predefined text "Got it"
    CGFloat width = [self widthForOneLineText:KRYTitleButt withFont:[self font]];
    width += KRYWidthMargin;
    
    if ([self isButtonOnRight:anchorView]) {
        // at the right
        return CGRectMake(CGRectGetMaxX(sideView.frame) + KRYWidthMargin/2.0,
                          sideView.frame.origin.y,
                          width,
                          sideView.frame.size.height);
    } else {
        // at the left
        return CGRectMake(CGRectGetMinX(sideView.frame) - KRYWidthMargin/2.0 - width,
                          sideView.frame.origin.y,
                          width,
                          sideView.frame.size.height);
    }
}

#pragma mark -
#pragma mark ======== Methods ========

- (UIFont*)font
{
    return [UIFont boldSystemFontOfSize:16.0];
}

- (BOOL)isButtonOnRight:(UIView*)anchorView
{
    // NOTE: button is preffered at the right of the label, except that the center of the anchor view is at the right border of the screen
    CGRect anchorRect = [self rectForAnchorPointer:anchorView direction:YES];
    if (CGRectGetMidX(anchorRect) > CGRectGetMaxX(self.bounds) - KRYWidthMargin - KRYWidthButton) {
        return NO;
    }
    
    return YES;
}

- (CGFloat)heightForText:(NSString *)text withFixedWidth:(CGFloat)width withFont:(UIFont *)font {
    // input check, the default will contain 2 lines if it is empty
    if (!text) text = @"";
    if (!font) font = [UIFont systemFontOfSize:16.0];
    
    CGFloat height = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:font}
                                        context:nil].size.height;
    
    // make the size of the rect as integers
    return (CGFloat)(ceil((double)height));
}

- (CGFloat)widthForOneLineText:(NSString *)text withFont:(UIFont *)font {
    // input check, the default will contain 2 lines if it is empty
    if (!text) text = @"";
    
    CGFloat width = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:font}
                                       context:nil].size.width;
    
    // make the size of the rect as integers
    return (CGFloat)(ceil((double)width));
}

#pragma mark -
#pragma mark ======== CG Draw ========

- (void)drawRect:(CGRect)rect {
    [self.backgroundColor setFill];
    UIRectFill(rect);

    if (_isShowHoles) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // draw holes with transparent color, in round-corner rectangles
        for (UIView* view in self.holes) {
            if ([view isKindOfClass:[UIView class]]) {
                CGRect rect = [self rectForView:view];
                
                CGFloat progress = 0.0;
                NSNumber* value = [self.layer.presentationLayer valueForKey:KRYKeyHolesAnimationProgress];
                if (value && [value isKindOfClass:NSNumber.class]) {
                    progress = value.doubleValue;
                    if (progress < 0.0) progress = 0.0;
                    if (progress > 0.99) progress = 1.0;
                }
                
                [self cropHoles:rect inContext:context progress:progress];
                
                [self strokeBorder:rect inContext:context progress:progress];
            }
        }
    }
}

- (void)cropHoles:(CGRect)rect inContext:(CGContextRef)context progress:(CGFloat)progress
{
    if (progress > 1.0) progress = 1.0;
    if (progress < 0.0) progress = 0.0;
    CGFloat factor = 1.0 - powf(progress, 18.8);
    
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:3.0];
    if (path) {
        CGContextSaveGState(context);
        CGContextAddPath(context, path.CGPath);
        CGContextClip(context);
        CGContextClearRect(context, rect);
        CGContextAddPath(context, path.CGPath);
        CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.0 alpha:0.8*factor].CGColor);
        CGContextFillPath(context);
        CGContextRestoreGState(context);
    }
}

- (void)strokeBorder:(CGRect)rect inContext:(CGContextRef)context progress:(CGFloat)progress
{
    if (progress >= 1.0) return;
    
    CGFloat section1 = rect.size.width/2.0 / (rect.size.width + rect.size.height);
    CGFloat section2 = (rect.size.width/2.0 + rect.size.height) / (rect.size.width + rect.size.height);;
    
    CGFloat beginY, endY, midY;
    // 2. hanRYe the animation - lines
    if (CGRectGetMidY(rect) > CGRectGetMidY(self.bounds)) {
        // upwards
        beginY = CGRectGetMaxY(rect);
        endY = CGRectGetMinY(rect);
        midY = beginY - rect.size.height * (progress - section1)  / (section2 - section1);
    } else {
        // downwards
        beginY = CGRectGetMinY(rect);
        endY = CGRectGetMaxY(rect);
        midY = beginY + rect.size.height * (progress - section1)  / (section2 - section1);
    }
    
    if (progress < section1) {
        //   _____
        CGFloat dash = rect.size.width/2.0 * progress/(section1);
        CGContextMoveToPoint(context, CGRectGetMidX(rect) - dash, beginY);
        CGContextAddLineToPoint(context, CGRectGetMidX(rect) + dash, beginY);
    } else if (progress < section2) {
        // |_______|
        CGContextMoveToPoint(context, CGRectGetMinX(rect), midY);
        CGContextAddLineToPoint(context, CGRectGetMinX(rect), beginY);
        CGContextAddLineToPoint(context, CGRectGetMaxX(rect), beginY);
        CGContextAddLineToPoint(context, CGRectGetMaxX(rect), midY);
    } else {
        // |--   --|
        // |_______|
        CGFloat dash = rect.size.width/2.0 * (progress - section2)  / (1.0 - section2);
        CGContextMoveToPoint(context, CGRectGetMinX(rect) + dash, endY);
        CGContextAddLineToPoint(context, CGRectGetMinX(rect), endY);
        CGContextAddLineToPoint(context, CGRectGetMinX(rect), beginY);
        CGContextAddLineToPoint(context, CGRectGetMaxX(rect), beginY);
        CGContextAddLineToPoint(context, CGRectGetMaxX(rect), endY);
        CGContextAddLineToPoint(context, CGRectGetMaxX(rect) - dash, endY);
    }
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokePath(context);
}




@end
