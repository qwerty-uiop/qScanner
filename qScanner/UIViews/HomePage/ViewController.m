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
    
    
//    [self relocateReaderPopover:[self interfaceOrientation]];
    
    [zView start];
    isNotScanning=FALSE;
    [_previewView addSubview: zView];
    
}



- (void) readerView: (ZBarReaderView*) readerView
     didReadSymbols: (ZBarSymbolSet*) symbols
          fromImage: (UIImage*) image
{
    NSLog(@"didReadSymbols - Sucessfull");
    
    ZBarSymbol *symbol = nil;
    NSString *hiddenData;
    for(symbol in symbols)
    {
        hiddenData=[NSString stringWithString:symbol.data];
    
    }
    
    NSLog(@"SYMBOL : %@",hiddenData);
    
    if (hiddenData != nil)
    {
        
        [zView stop];
        isNotScanning=TRUE;
        if([self IsNetworkAvailable])
        {
            
            
            PFQuery *query = [PFQuery queryWithClassName:@"ProductDetailsTable"];
            [query whereKey:@"product_code" equalTo:hiddenData];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if (object) {
                    // The find succeeded.
                    //                    NSLog(@"Successfully retrieved %d scores.", objects.count);
                    
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
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
            
            
            
        }
        else
        {
            EnterDetails *controller = (EnterDetails *)[self.storyboard instantiateViewControllerWithIdentifier:@"EnterDetailsID"];
            controller.pCode=[NSString stringWithFormat:@"%@",hiddenData];
            [self presentViewController:controller animated:YES completion:NULL];
            
            NSLog(@"No network" );
        }
        
        
    }

    
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
    // Dispose of any resources that can be recreated.
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
