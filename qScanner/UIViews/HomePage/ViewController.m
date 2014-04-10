//
//  ViewController.m
//  qScanner
//
//  Created by Jeethu on 22/03/14.
//  Copyright (c) 2014 InApp. All rights reserved.
//

#import "ViewController.h"
#import "EnterDetails.h"
#import "Reachability.h"
@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self InitializeBannerView];
    _boarderFrame=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Boarder"]];
      _boarderLine=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"BoarderLine"]];
   
    
//    [self startSessionWithDelegate:NO];
//    [_session startRunning];
    
    
    
//    
//    ad = [[RevMobAds session] bannerView];
//    ad.delegate = self;
//    [ad loadAd];
}


//- (void)revmobAdDidReceive {
//    [self.view addSubview:ad];
//}
//
//- (void)revmobAdDidFailWithError:(NSError *)error
//{
//    
//}

-(void)viewWillAppear:(BOOL)animated
{
    [_startScanBtn setImage:[UIImage imageNamed:@"Scanning"] forState:UIControlStateNormal];
    [self startSessionWithDelegate:YES];
    [_boarderFrame removeFromSuperview];
    [_boarderLine removeFromSuperview];
    
    CGRect thFrm;
    thFrm = [self.AboutUsView frame];
    thFrm.origin.y = self.view.frame.size.height-30;
    [_AboutUsView setFrame:thFrm];
}
-(void)startSessionWithDelegate:(BOOL)isDelegate
{
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    
    [_session addOutput:_output];
    
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
    
    _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _prevLayer.frame = self.previewView.bounds;
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.previewView.layer addSublayer:_prevLayer];
    
    if(isDelegate)
    {
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    }
    
    
    
    [_session startRunning];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        
        
        
        
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString != nil)
        {

//            _label.text = detectionString;
//            _prevLayer.frame = highlightViewRect;
            
             [_output setMetadataObjectsDelegate:nil queue:dispatch_get_main_queue()];
//            [_startScanBtn setTitle:@"Rescan" forState:UIControlStateNormal];
             [_startScanBtn setImage:[UIImage imageNamed:@"StartScan"] forState:UIControlStateNormal];
             [_session stopRunning];
            if(highlightViewRect.size.height<10||highlightViewRect.size.width<10)
            {
                _boarderLine.frame=highlightViewRect;
                [self.previewView addSubview:_boarderLine];
            }
            else
            {
           
            _boarderFrame.frame=highlightViewRect;
            [self.previewView addSubview:_boarderFrame];
            }
            NSLog(@"%@",NSStringFromCGRect(highlightViewRect));
            
            if([self IsNetworkAvailable])
            {
            
            
            PFQuery *query = [PFQuery queryWithClassName:@"ProductDetailsTable"];
            [query whereKey:@"product_code" equalTo:detectionString];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if (object) {
                    // The find succeeded.
//                    NSLog(@"Successfully retrieved %d scores.", objects.count);
                    
                    EnterDetails *controller = (EnterDetails *)[self.storyboard instantiateViewControllerWithIdentifier:@"EnterDetailsID"];
                    controller.pCode=[NSString stringWithFormat:@"%@",detectionString];
                    
                    
              
                        
                        
                        controller.pNamep=[object objectForKey:@"product_name"];
                        controller.pPricep=[object objectForKey:@"product_price"];
                        controller.pAmountp=[object objectForKey:@"product_amount"];
                        controller.pShopp=[object objectForKey:@"product_shop"];
                        controller.pCategoryp=[object objectForKey:@"product_category"];
                        controller.pCurrencyp=[object objectForKey:@"product_currency"];
                        controller.pIDp=object.objectId;
                        
                        [self presentViewController:controller animated:YES completion:NULL];
                
                    
                } else {
                    EnterDetails *controller = (EnterDetails *)[self.storyboard instantiateViewControllerWithIdentifier:@"EnterDetailsID"];
                    controller.pCode=[NSString stringWithFormat:@"%@",detectionString];
                     [self presentViewController:controller animated:YES completion:NULL];
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
            
            
            
        }
            else
            {
                EnterDetails *controller = (EnterDetails *)[self.storyboard instantiateViewControllerWithIdentifier:@"EnterDetailsID"];
                controller.pCode=[NSString stringWithFormat:@"%@",detectionString];
                [self presentViewController:controller animated:YES completion:NULL];
                
                NSLog(@"No network" );
            }
            
            
        }
       
//        else
//            _label.text = @"(none)";
    }
    
    
}
- (IBAction)StartScanFn:(id)sender {
    
   
   
    
    if(!_session.isRunning)
    {
        [_startScanBtn setImage:[UIImage imageNamed:@"Scanning"] forState:UIControlStateNormal];
        [self startSessionWithDelegate:YES];
//        [_session startRunning];
        [_boarderFrame removeFromSuperview];
         [_boarderLine removeFromSuperview];
    }
    else
    {
         [_startScanBtn setImage:[UIImage imageNamed:@"StartScan"] forState:UIControlStateNormal];
        [_session stopRunning];
//        [self startSessionWithDelegate:NO];
    }
    
}
- (IBAction)AboutUsFn:(id)sender {
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect thFrm;
                         thFrm = [self.AboutUsView frame];
                         if (thFrm.origin.y<self.view.frame.size.height/2) {
                             thFrm.origin.y = self.view.frame.size.height-30;
//                             [_aboutUsBtn setImage:[UIImage imageNamed:@"ArrowDown"] forState:UIControlStateNormal];
                             
                         }
                         else{
//                             [_aboutUsBtn setImage:[UIImage imageNamed:@"ArrowUp"] forState:UIControlStateNormal];
                             thFrm.origin.y = self.previewView.frame.origin.y;
                         }
                         [_AboutUsView setFrame:thFrm];
                     }
                     completion:^(BOOL finished){
                         
                         
                         
                     }
     ];
    
}
- (IBAction)SendSmsFn:(id)sender {
    //check if the device can send text messages
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device cannot send text messages" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //set receipients
//    NSArray *recipients = [NSArray arrayWithObjects:@"0650454323",@"0434320943",@"0560984122", nil];
    
    //set message text
    NSString * message = @"Share the app -> link";
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
//    [messageController setRecipients:recipients];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];

    
}

- (IBAction)SendMailFn:(id)sender {
    //check if the device can send text messages
    if(![MFMailComposeViewController canSendMail]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device cannot send text messages" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //set receipients
    //    NSArray *recipients = [NSArray arrayWithObjects:@"0650454323",@"0434320943",@"0560984122", nil];
    
    //set message text
    NSString * message = @"Share the app";
    
    MFMailComposeViewController *messageController = [[MFMailComposeViewController alloc] init];
    messageController.mailComposeDelegate = self;
    //    [messageController setRecipients:recipients];
    [messageController setSubject:message];
    [messageController setMessageBody:@"Body of mail" isHTML:NO ];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

- (IBAction)ShareViaFbFn:(id)sender {
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:@"Test Post"];
        [controller addURL:[NSURL URLWithString:@"http://think-n-relax.blogspot.in"]];
//        [controller addImage:[UIImage imageNamed:@"socialsharing-facebook-image.jpg"]];
        [self presentViewController:controller animated:YES completion:Nil];
    }
}

- (IBAction)ShareViaTwitterFn:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"http://think-n-relax.blogspot.in"];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate methods
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result {
    switch (result) {
        case MessageComposeResultCancelled: break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Oups, error while sendind SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
        }
            break;
            
        case MessageComposeResultSent: break;
            
        default: break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MessageComposeResultCancelled: break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Oups, error while sendind Mail!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
        }
            break;
            
        case MessageComposeResultSent: break;
            
        default: break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)IsNetworkAvailable
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        return false;
    } else {
        
        return true;
        
        
    }
}
-(void)InitializeBannerView
{
    // Create a view of the standard size at the top of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    bannerView_ = [[GADBannerView alloc] initWithAdSize:([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)?kGADAdSizeLeaderboard:kGADAdSizeBanner];
    
    // Specify the ad unit ID.
    bannerView_.adUnitID = @"a1533403b23b859";
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:[GADRequest request]];
    
//    GADRequest *request = [GADRequest request];
//    request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil];
//[bannerView_ loadRequest:request];
}

@end
