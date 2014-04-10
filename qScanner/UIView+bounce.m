
#import "UIView+bounce.h"


@implementation UIView (bounce)

-(void)presentSubviewWithBounce:(UIView*)theView
{
    theView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    
    [self addSubview:theView];
    
    [UIView animateWithDuration:0.4/1.5 animations:^{
        theView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4/2 animations:^{
            theView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4/2 animations:^{
                theView.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
}

@end