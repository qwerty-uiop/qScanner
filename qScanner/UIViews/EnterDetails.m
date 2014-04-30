//
//  EnterDetails.m
//  qScanner
//
//  Created by Jeethu on 22/03/14.
//  Copyright (c) 2014 InApp. All rights reserved.
//

#import "EnterDetails.h"
#import <Parse/Parse.h>
#import "UIView+bounce.h"
#import "Reachability.h"

@interface EnterDetails ()

@end

@implementation EnterDetails

NSArray* tableData;
int tableF;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    tableF=0;
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    
    
    _productCode.text=_pCode;
    _pName.text=_pNamep;
    _pPrice.text=_pPricep;
    _pAmount.text=_pAmountp;
    _pShop.text=_pShopp;
    
    if(_pCategoryp!=nil)
    {
         [_categoryBtn setTitle:_pCategoryp forState:UIControlStateNormal];
    }
    if(_pCurrencyp!=nil)
    {
         [_currencyBtn setTitle:_pCurrencyp forState:UIControlStateNormal];
    }
    
    
    if(_pIDp!=nil)
    {
        _submitBtn.hidden=YES;
    }
    if(![self IsNetworkAvailable])
    {
        _submitBtn.hidden=YES;
    }
    
   [_tableView removeFromSuperview];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    if(tableF==2)
    {
    cell.textLabel.text = [NSString stringWithFormat:@"%@   %@",[[tableData objectAtIndex:indexPath.row]objectForKey:@"name"],[[tableData objectAtIndex:indexPath.row]objectForKey:@"code"]];
    }
    else if(tableF==1)
    {
        cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    }
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [_tableView removeFromSuperview];
    if(tableF==2)
    {
      
        
        [_currencyBtn setTitle:[NSString stringWithFormat:@"%@   %@",[[tableData objectAtIndex:indexPath.row]objectForKey:@"name"],[[tableData objectAtIndex:indexPath.row]objectForKey:@"code"]] forState:UIControlStateNormal];
    
    }
    else if(tableF==1)
    {
        [_categoryBtn setTitle:[tableData objectAtIndex:indexPath.row] forState:UIControlStateNormal];
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)SubmitFn:(id)sender {
    
    if(_pName.text.length>0&&_categoryBtn.titleLabel.text.length>0&&![_categoryBtn.titleLabel.text isEqualToString:@"<Category>"])
    {
        
        if(_pIDp!=nil)
        {
        PFQuery *query = [PFQuery queryWithClassName:@"ProductDetailsTable"];
        
        // Retrieve the object by id
        [query getObjectInBackgroundWithId:_pIDp block:^(PFObject *testObject, NSError *error) {
            
            // Now let's update it with some new data. In this case, only cheatMode and score
            // will get sent to the cloud. playerName hasn't changed.
            testObject[@"product_name"] = _pName.text;
            testObject[@"product_price"] = _pPrice.text;
            testObject[@"product_amount"] = _pAmount.text;
            testObject[@"product_currency"] = _currencyBtn.titleLabel.text;
            testObject[@"product_category"] =  _categoryBtn.titleLabel.text;
            testObject[@"product_shop"] = _pShop.text;
            [testObject saveInBackground]; }];
        }
        else
        {
        
        
        PFObject *testObject = [PFObject objectWithClassName:@"ProductDetailsTable"];
        testObject[@"product_code"] = _pCode;
        testObject[@"product_name"] = _pName.text;
       
        testObject[@"product_price"] = _pPrice.text;
            testObject[@"product_amount"] = _pAmount.text;
            testObject[@"product_currency"] = _currencyBtn.titleLabel.text;
            testObject[@"product_category"] =  _categoryBtn.titleLabel.text;
            testObject[@"product_shop"] = _pShop.text;
            
        [testObject saveInBackground];
         }
        
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"Sucessfully Added" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
//        EnterDetails *controller = (EnterDetails *)[self.storyboard instantiateViewControllerWithIdentifier:@"EnterDetailsID"];
//        controller.pCode=[NSString stringWithFormat:@"Product code : %@",detectionString];
        [self dismissViewControllerAnimated:YES completion:nil];
        
        

        
    }
    else
    {
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"Must fill Name and Category" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}
- (IBAction)BackFn:(id)sender {
     [self dismissViewControllerAnimated:YES completion:nil];
}
-(void) keyboardWillShow
{
    if([self IsNetworkAvailable])
    {
    _submitBtn.hidden=NO;
    }
}
- (IBAction)SelectCategoryFn:(id)sender {
    tableF=1;
    tableData = [NSArray arrayWithObjects:@"Home Appliance", @"Food & Beverages", @"Automobile", @"Electronics", @"Excersice", @"Clothes", @"Toys",@"Vegetables",@"Utility",@"Entertainment",@"Office",@"Sanitary",@"People",@"Cosmetics",@"Books",@"Places",@"VCards",@"Address",@"Websites",@"Phone Numbers",@"Misc",@"Others", nil];
    [_tableView reloadData];
    [self.view addSubview:_tableView];
  [self.view presentSubviewWithBounce:[self tableView]];

}

- (IBAction)SelectCurrencyFn:(id)sender {
    tableF=2;
    tableData = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Countries" ofType:@"plist"]];
    [_tableView reloadData];
    [self.view addSubview:_tableView];
    [self.view presentSubviewWithBounce:[self tableView]];
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
@end
