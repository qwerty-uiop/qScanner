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
@synthesize zView;
bool isNotScanning;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //find URL to audio file
    NSURL *clickSound   = [[NSBundle mainBundle] URLForResource: @"detect" withExtension: @"wav"];
    NSURL *qwSound   = [[NSBundle mainBundle] URLForResource: @"QWERTYUIOP" withExtension: @"mp3"];
    //initialize SystemSounID variable with file URL
    AudioServicesCreateSystemSoundID (CFBridgingRetain(clickSound), &soundClick);
    AudioServicesCreateSystemSoundID (CFBridgingRetain(qwSound), &qwSoundObj);
}

-(void)viewWillAppear:(BOOL)animated
{
    [_startScanBtn setImage:[UIImage imageNamed:@"Scanning"] forState:UIControlStateNormal];
    CGRect thFrm;
    thFrm = [self.AboutUsView frame];
    thFrm.origin.y = self.view.frame.size.height-30;
    [_AboutUsView setFrame:thFrm];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self InitializeScanner];
    if([self IsNetworkAvailable])
    {
        [self InitializeBannerView];
    }
    else
    {
        [self setCustomAd];
    }
}
-(void)InitializeScanner
{
    
    zView = [ZBarReaderView new];
    zView.readerDelegate = self;
    zView.tracksSymbols = YES;
    zView.frame = CGRectMake(0, 0, _previewView.frame.size.width,CGRectGetHeight(_previewView.frame));
    zView.torchMode = 0;
    ZBarImageScanner *scanner = zView.scanner;
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    [zView start];
    isNotScanning=FALSE;
    [_previewView addSubview: zView];
    
}



- (void) readerView: (ZBarReaderView*) readerView
     didReadSymbols: (ZBarSymbolSet*) symbols
          fromImage: (UIImage*) image
{
    ZBarSymbol *symbol = nil;
    NSString *hiddenData;
    for(symbol in symbols)
    {
        hiddenData=[NSString stringWithString:symbol.data];
    }
    if (hiddenData != nil)
    {
        
        AudioServicesPlaySystemSound(soundClick);
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [_startScanBtn setImage:[UIImage imageNamed:@"StartScan"] forState:UIControlStateNormal];
        [zView stop];
        isNotScanning=TRUE;

        
        if([self IsNetworkAvailable])
        {
            PFQuery *query = [PFQuery queryWithClassName:@"ProductDetailsTable"];
            [query whereKey:@"product_code" equalTo:hiddenData];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if (object) {
                    EnterDetails *controller = (EnterDetails *)[self.storyboard instantiateViewControllerWithIdentifier:@"EnterDetailsID"];
                    controller.pCode=[NSString stringWithFormat:@"%@",hiddenData];
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
                    controller.pCode=[NSString stringWithFormat:@"%@",hiddenData];
                    [self presentViewController:controller animated:YES completion:NULL];
                }
            }];
        }
        else
        {
            EnterDetails *controller = (EnterDetails *)[self.storyboard instantiateViewControllerWithIdentifier:@"EnterDetailsID"];
            controller.pCode=[NSString stringWithFormat:@"%@",hiddenData];
            [self presentViewController:controller animated:YES completion:NULL];
        }
    }
}

- (void)viewDidUnload {
	AudioServicesDisposeSystemSoundID(soundClick);
    AudioServicesDisposeSystemSoundID(qwSoundObj);
}
-(void)setCustomAd
{
    UIImageView* adView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), 50)];
    adView.image=[UIImage imageNamed:k_DeviceTypeIsIpad?@"AdiPad.jpg":@"Ad.jpg"];
    [self.view addSubview:adView];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (IBAction)StartScanFn:(id)sender {
    if(isNotScanning)
    {
        [_startScanBtn setImage:[UIImage imageNamed:@"Scanning"] forState:UIControlStateNormal];
        [zView start];
        isNotScanning=false;
    }
    else
    {
        [_startScanBtn setImage:[UIImage imageNamed:@"StartScan"] forState:UIControlStateNormal];
        [zView stop];
        isNotScanning=TRUE;
    }
}
- (IBAction)AboutUsFn:(id)sender {
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect thFrm;
                         thFrm = [self.AboutUsView frame];
                         if (thFrm.origin.y<self.view.frame.size.height/2) {
                             thFrm.origin.y = self.view.frame.size.height-30;
                             
                         }
                         else{
                              AudioServicesPlaySystemSound(qwSoundObj);
                             thFrm.origin.y = self.previewView.frame.origin.y;
                         }
                         [_AboutUsView setFrame:thFrm];
                     }
                     completion:^(BOOL finished){
                     }
     ];
    
}
- (IBAction)SendSmsFn:(id)sender {
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device cannot send text messages" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSString * message = @"qScanner - Find the app in Appstore";
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setBody:message];
    [self presentViewController:messageController animated:YES completion:nil];
    
    
}

- (IBAction)SendMailFn:(id)sender {
    if(![MFMailComposeViewController canSendMail]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device cannot send text messages" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    //set message text
    NSString * message = @"qScanner - Find the app in Appstore";
    MFMailComposeViewController *messageController = [[MFMailComposeViewController alloc] init];
    messageController.mailComposeDelegate = self;
    [messageController setSubject:message];
    [messageController setMessageBody:@"Body of mail" isHTML:NO ];
    [self presentViewController:messageController animated:YES completion:nil];
}

- (IBAction)ShareViaFbFn:(id)sender {
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:@"qScanner - Find the app in Appstore"];
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
        [tweetSheet setInitialText:@"qScanner - Find the app in Appstore"];
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
    bannerView_ = [[GADBannerView alloc] initWithAdSize:([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)?kGADAdSizeLeaderboard:kGADAdSizeBanner];
    bannerView_.adUnitID = @"a1533403b23b859";
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    [bannerView_ loadRequest:[GADRequest request]];
}

@end
