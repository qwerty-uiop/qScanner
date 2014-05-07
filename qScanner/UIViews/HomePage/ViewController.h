//
//  ViewController.h
//  qScanner
//
//  Created by Jeethu on 22/03/14.
//  Copyright (c) 2014 InApp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Parse/Parse.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import "GADBannerView.h"
#import "ZBarSDK.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController : UIViewController<UIAlertViewDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,ZBarReaderViewDelegate>
{
    GADBannerView *bannerView_;
    ZBarReaderView *zView;
    SystemSoundID soundClick;
    SystemSoundID qwSoundObj;
}

@property (strong, nonatomic) IBOutlet UIButton *startScanBtn;
- (IBAction)StartScanFn:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *previewView;

- (IBAction)AboutUsFn:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *AboutUsView;
- (IBAction)SendSmsFn:(id)sender;
- (IBAction)SendMailFn:(id)sender;
- (IBAction)ShareViaFbFn:(id)sender;
- (IBAction)ShareViaTwitterFn:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *aboutUsBtn;
@property (strong, nonatomic) ZBarReaderView *zView;
@end
