//
//  UIView+Frame.m
//  TZYJ_IPhone
//
//  Created by Weirdln on 15/9/30.
//
//

#import "UIView+Frame.h"

static NSInteger bgImageTag = -11111;

@implementation UIView (Frame)

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    UIImageView *view = (UIImageView *)[self viewWithTag:bgImageTag];
    if (!view) {
        UIImageView *v = [[UIImageView alloc] initWithImage:backgroundImage];
        v.frame = self.bounds;
        v.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        v.tag = bgImageTag;
        //        [self addSubview:v];
        [self insertSubview:v atIndex:0];
    }else{
        view.frame = self.bounds;
        [view setImage:backgroundImage];
    }
}

- (UIImage *)backgroundImage
{
    return [(UIImageView*)[self viewWithTag:bgImageTag] image];
}

- (void)setBackgroundImage:(UIImage *)backImg viewContentMode:(UIViewContentMode)viewContentMode
{
    self.backgroundImage = backImg;
    UIImageView *view = (UIImageView *)[self viewWithTag:bgImageTag];
    if (view) {
        view.contentMode = viewContentMode;
    }
}

- (CGPoint)rightBottomCorner
{
    return CGPointMake(self.x + self.width, self.y + self.height);
}

- (void)setRightBottomCorner:(CGPoint)rightBottomCorner
{
    CGRect rt = self.frame;
    CGPoint pt = rightBottomCorner;
    rt.origin.x = pt.x - self.width;
    rt.origin.y = pt.y - self.height;
    self.frame = rt;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
}

- (CGFloat)cornerRadius
{
    return self.layer.cornerRadius;
}

- (UIColor*)borderColor
{
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setBorderColor:(UIColor*)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
}

-(CGFloat)borderWidth
{
    return self.layer.borderWidth;
}
-(void)setBorderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
}

// x,y
- (CGFloat)x
{
    return self.frame.origin.x;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setX:(CGFloat)x
{
    self.frame = CGRectMake(x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (void)setY:(CGFloat)y
{
    self.frame = CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height);
}

// height, width
- (CGFloat)height
{
    return self.frame.size.height;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    CGRect newFrame = CGRectMake(self.x, self.y, self.width, height);
    self.frame = newFrame;
}

- (void)setWidth:(CGFloat)width
{
    CGRect newFrame = CGRectMake(self.x, self.y, width, self.height);
    self.frame = newFrame;
}

- (void)heightEqualToView:(UIView *)view
{
    self.height = view.height;
}

- (void)widthEqualToView:(UIView *)view
{
    self.width = view.width;
}

// bottom,right
- (CGFloat)bottom
{
    return self.frame.size.height + self.frame.origin.y;
}

- (CGFloat)right
{
    return self.frame.size.width + self.frame.origin.x;
}

// size
- (CGSize)size
{
    return self.frame.size;
}

- (void)setSize:(CGSize)size
{
    self.frame = CGRectMake(self.x, self.y, size.width, size.height);
}

// origin
- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin
{
    self.frame = CGRectMake(origin.x, origin.y, self.width, self.height);
}

// center
- (CGFloat)centerX
{
    return self.center.x;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = CGPointMake(self.centerX, self.centerY);
    center.x = centerX;
    self.center = center;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = CGPointMake(self.centerX, self.centerY);
    center.y = centerY;
    self.center = center;
}

- (void)setCornerRadius:(float)cornerRadius borderWidth:(float)borderWidth borderColor:(UIColor *)borderColor
{
    self.layer.cornerRadius = cornerRadius;
    self.layer.borderWidth =borderWidth;
    if (borderColor) {
        self.layer.borderColor = borderColor.CGColor;
    }
    self.clipsToBounds = YES;
}

- (void)applyRoundedCorners:(UIRectCorner)corners withRadius:(CGFloat)radius {
    UIBezierPath *rounded = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                  byRoundingCorners:corners
                                                        cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    self.layer.mask = shape;
    self.clipsToBounds = YES;
}

@end
