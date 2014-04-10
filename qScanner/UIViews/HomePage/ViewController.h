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

@interface ViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate>
{
    GADBannerView *bannerView_;
}

@property (strong, nonatomic) IBOutlet UIButton *startScanBtn;
@property(strong,retain)AVCaptureSession* session;
@property(strong,retain)AVCaptureDevice* device;
- (IBAction)StartScanFn:(id)sender;

@property(strong,retain)AVCaptureDeviceInput* input;

@property(strong,retain)AVCaptureMetadataOutput* output;
@property (strong, nonatomic) IBOutlet UIView *previewView;

- (IBAction)AboutUsFn:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *AboutUsView;
- (IBAction)SendSmsFn:(id)sender;
- (IBAction)SendMailFn:(id)sender;
- (IBAction)ShareViaFbFn:(id)sender;
- (IBAction)ShareViaTwitterFn:(id)sender;

@property(strong,retain)AVCaptureVideoPreviewLayer* prevLayer;
@property(strong,nonatomic)UIImageView* boarderFrame;
@property (strong, nonatomic) IBOutlet UIButton *aboutUsBtn;
@property(strong,nonatomic)UIImageView* boarderLine;
@end
