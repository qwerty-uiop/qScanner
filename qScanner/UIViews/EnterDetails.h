//
//  EnterDetails.h
//  qScanner
//
//  Created by Jeethu on 22/03/14.
//  Copyright (c) 2014 InApp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@interface EnterDetails : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UILabel *productCode;
@property(strong,nonatomic)NSString* pCode;
@property(strong,nonatomic)NSString* pNamep;
@property(strong,nonatomic)NSString* pPricep;
@property(strong,nonatomic)NSString* pIDp;
@property(strong,nonatomic)NSString* pAmountp;
@property(strong,nonatomic)NSString* pShopp;
@property(strong,nonatomic)NSString* pCategoryp;
@property(strong,nonatomic)NSString* pCurrencyp;



- (IBAction)SubmitFn:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *pName;
@property (strong, nonatomic) IBOutlet UITextField *pPrice;
- (IBAction)BackFn:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *submitBtn;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)SelectCategoryFn:(id)sender;
- (IBAction)SelectCurrencyFn:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *currencyBtn;
@property (strong, nonatomic) IBOutlet UIButton *categoryBtn;
@property (strong, nonatomic) IBOutlet UITextField *pAmount;
@property (strong, nonatomic) IBOutlet UITextField *pShop;

@end
