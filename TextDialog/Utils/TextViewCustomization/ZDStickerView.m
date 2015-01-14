//
//  ZDStickerView.m
//  TextDialog
//
//  Created by Bin Jin on 12/19/14.
//  Copyright (c) 2014 Bin Jin. All rights reserved.
//

#import "ZDStickerView.h"
#import <QuartzCore/QuartzCore.h>

@interface ZDStickerView ()

@property (strong, nonatomic) UIImageView *resizingControl;
@property (strong, nonatomic) UIImageView *deleteControl;

@property (nonatomic) BOOL preventsLayoutWhileResizing;

@property (nonatomic) float deltaAngle;
@property (nonatomic) CGPoint prevPoint;
@property (nonatomic) CGAffineTransform startTransform;

@property (nonatomic) CGPoint touchStart;

@end

@implementation ZDStickerView
@synthesize contentView, touchStart;

@synthesize prevPoint;
@synthesize deltaAngle, startTransform; //rotation
@synthesize resizingControl, deleteControl;
@synthesize preventsPositionOutsideSuperview;
@synthesize preventsResizing;
@synthesize preventsDeleting;
@synthesize minWidth, minHeight;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)singleTap:(UIPanGestureRecognizer *)recognizer
{
    if (NO == self.preventsDeleting) {
        UIView * close = (UIView *)[recognizer view];
        [close.superview removeFromSuperview];
    }
    
    if([_delegate respondsToSelector:@selector(stickerViewDidClose:)]) {
        [_delegate stickerViewDidClose:self];
    }
}

-(void)resizeTranslate:(UIGestureRecognizer *)recognizer
{
    static BOOL enable = YES;
    if ([recognizer state]== UIGestureRecognizerStateBegan)
        enable = YES;
    
    if (enable == NO)
        return;
    
    if ([recognizer state]== UIGestureRecognizerStateBegan)
    {
        prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged)
    {
        if (self.bounds.size.width < minWidth || self.bounds.size.width < minHeight)
        {
            self.bounds = CGRectMake(self.bounds.origin.x,
                                     self.bounds.origin.y,
                                     minWidth,
                                     minHeight);
            resizingControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                       self.bounds.size.height-kZDStickerViewControlSize,
                                              kZDStickerViewControlSize,
                                              kZDStickerViewControlSize);
            deleteControl.frame = CGRectMake(0, 0,
                                             kZDStickerViewControlSize, kZDStickerViewControlSize);
            prevPoint = [recognizer locationInView:self];
             
        }
        else {
            CGPoint point = [recognizer locationInView:self];
            NSLog(@"%f, %f", point.x, point.y);
            if (point.x > self.superview.frame.size.width)
            {
                enable = NO;
                return;
            }
            
            float wChange = 0.0, hChange = 0.0;
            
            wChange = (point.x - prevPoint.x);
            hChange = (point.y - prevPoint.y);
          
            
            self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y,
                                     self.bounds.size.width + (wChange),
                                     self.bounds.size.height + (hChange));
            resizingControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                              self.bounds.size.height-kZDStickerViewControlSize,
                                              kZDStickerViewControlSize, kZDStickerViewControlSize);
            deleteControl.frame = CGRectMake(0, 0,
                                             kZDStickerViewControlSize, kZDStickerViewControlSize);
            prevPoint = [recognizer locationInView:self];
        }
        
        borderView.frame = CGRectMake(kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset, self.bounds.size.width -  kSPUserResizableViewGlobalInset * 2, self.bounds.size.height - kSPUserResizableViewGlobalInset * 2);
        [borderView setNeedsDisplay];

        if ([self.delegate respondsToSelector:@selector(stickerViewDidSizeChanged)])
        {
            [self.delegate stickerViewDidSizeChanged];
        }
        
        [self setNeedsDisplay];
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
    }
}

-(void)moveTranslate:(UIPanGestureRecognizer *)recognizer
{
    if ([recognizer state]== UIGestureRecognizerStateBegan)
    {
        prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged)
    {
        CGPoint point = [recognizer locationInView:self];
        float wChange = 0.0, hChange = 0.0;
        
        wChange = (point.x - prevPoint.x);
        hChange = (point.y - prevPoint.y);

        if ([self.delegate respondsToSelector:@selector(moveToLeft:Top:)])
        {
            [self.delegate moveToLeft:wChange Top:hChange];
        }
        
        [self setNeedsDisplay];
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
    }
}

- (void)setupDefaultAttributes {
    borderView = [[SPGripViewBorderView alloc] initWithFrame:CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset)];
    [borderView setHidden:YES];
    [self addSubview:borderView];
    
    if (kSPUserResizableViewDefaultMinWidth > self.bounds.size.width*0.5) {
        self.minWidth = kSPUserResizableViewDefaultMinWidth;
        self.minHeight = self.bounds.size.height * (kSPUserResizableViewDefaultMinWidth/self.bounds.size.width);
    } else {
        self.minWidth = self.bounds.size.width*0.5;
        self.minHeight = self.bounds.size.height*0.5;
    }
    self.preventsPositionOutsideSuperview = YES;
    self.preventsLayoutWhileResizing = YES;
    self.preventsResizing = NO;
    self.preventsDeleting = NO;
    
    deleteControl = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,
                                                                 kZDStickerViewControlSize, kZDStickerViewControlSize)];
    deleteControl.backgroundColor = [UIColor clearColor];
    deleteControl.image = [UIImage imageNamed:@"Close.png" ];
    deleteControl.userInteractionEnabled = YES;
    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(singleTap:)];
    [deleteControl addGestureRecognizer:singleTap];
    [self addSubview:deleteControl];
    
    resizingControl = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-kZDStickerViewControlSize,
                                                                   self.frame.size.height-kZDStickerViewControlSize,
                                                                   kZDStickerViewControlSize, kZDStickerViewControlSize)];
    resizingControl.backgroundColor = [UIColor clearColor];
    resizingControl.userInteractionEnabled = YES;
    resizingControl.image = [UIImage imageNamed:@"Move.png" ];
    UIGestureRecognizer* panResizeGesture = [[UIPanGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(resizeTranslate:)];
    [resizingControl addGestureRecognizer:panResizeGesture];
    [self addSubview:resizingControl];
    
    UIPanGestureRecognizer* panResizeGesture1 = [[UIPanGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(moveTranslate:)];
    [borderView addGestureRecognizer:panResizeGesture1];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupDefaultAttributes];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupDefaultAttributes];
    }
    return self;
}

- (void)setContentView:(UITextView *)newContentView {
    [contentView removeFromSuperview];
    contentView = newContentView;
    contentView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);
    contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:contentView];
    
    [self bringSubviewToFront:borderView];
    [self bringSubviewToFront:resizingControl];
    [self bringSubviewToFront:deleteControl];
}

- (void)setFrame:(CGRect)newFrame {
    [super setFrame:newFrame];
    contentView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);
    borderView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset);
    resizingControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                      self.bounds.size.height-kZDStickerViewControlSize,
                                      kZDStickerViewControlSize,
                                      kZDStickerViewControlSize);
    deleteControl.frame = CGRectMake(0, 0,
                                     kZDStickerViewControlSize, kZDStickerViewControlSize);
    [borderView setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    touchStart = [touch locationInView:self.superview];
    if([_delegate respondsToSelector:@selector(stickerViewDidBeginEditing:)]) {
        [_delegate stickerViewDidBeginEditing:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Notify the delegate we've ended our editing session.
    if([_delegate respondsToSelector:@selector(stickerViewDidEndEditing:)]) {
        [_delegate stickerViewDidEndEditing:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // Notify the delegate we've ended our editing session.
    if([_delegate respondsToSelector:@selector(stickerViewDidCancelEditing:)]) {
        [_delegate stickerViewDidCancelEditing:self];
    }
}

- (void)translateUsingTouchLocation:(CGPoint)touchPoint {
    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - touchStart.x,
                                    self.center.y + touchPoint.y - touchStart.y);
    
    if (self.preventsPositionOutsideSuperview) {
        // Ensure the translation won't cause the view to move offscreen.
        CGFloat midPointX = CGRectGetMidX(self.bounds);
        if (newCenter.x > self.superview.bounds.size.width - midPointX) {
            newCenter.x = self.superview.bounds.size.width - midPointX;
        }
        if (newCenter.x < midPointX) {
            newCenter.x = midPointX;
        }
        CGFloat midPointY = CGRectGetMidY(self.bounds);
        if (newCenter.y > self.superview.bounds.size.height - midPointY) {
            newCenter.y = self.superview.bounds.size.height - midPointY;
        }
        if (newCenter.y < midPointY) {
            newCenter.y = midPointY;
        }
    }
//    self.center = newCenter;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touch = [[touches anyObject] locationInView:self.superview];
    [self translateUsingTouchLocation:touch];
    touchStart = touch;
}

- (void)hideDelHandle
{
    deleteControl.hidden = YES;
}

- (void)showDelHandle
{
    deleteControl.hidden = NO;
}

- (void)hideEditingHandles
{
    resizingControl.hidden = YES;
    deleteControl.hidden = YES;
    [borderView setHidden:YES];
}

- (void)showEditingHandles
{
    resizingControl.hidden = NO;
    deleteControl.hidden = NO;
    [borderView setHidden:NO];
}

@end
