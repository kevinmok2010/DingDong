//
//  OrderSummaryViewController.m
//  wertyui
//
//  Created by Kevin Mok on 2016-12-08.
//  Copyright © 2016 Kevin Mok. All rights reserved.
//

#import "OrderSummaryViewController.h"
#import "OrderSummaryTableViewCell.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"

NSArray *dish_name = nil;
NSArray *order_array = nil;
NSArray *unit_price = nil;
NSArray *dish_oid = nil;
int non_empty_count = 0;
float subtotal = 0;


static NSString * const BaseURLString = @"https://api.mlab.com/api/1/databases/food/collections/orders?apiKey=BwvONax567WvFHAlBXqQFiG0fDpJJJVF";

@interface OrderSummaryViewController ()

@end

@implementation OrderSummaryViewController{
    NSMutableArray *order_summary_array;
    NSMutableArray *order_total_unit;
    NSMutableArray *dish_name_summary;
    NSMutableArray *summary_unit_price;
    NSMutableArray *summary_dish_oid;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.Summary_menu.allowsSelection = NO;
    self.cancel_button.target = self;
    _cancel_button.action = @selector(barButtonCustomPressed:);
    self.Go_back_button.target = self;
    _Go_back_button.action = @selector(gobackButtonCustomPressed:);
    
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
    self.Common_field.delegate = self;
    
    dish_name = [[NSUserDefaults standardUserDefaults] objectForKey:@"dish_name_array"];
    order_array = [[NSUserDefaults standardUserDefaults] objectForKey:@"order_array"];
    unit_price = [[NSUserDefaults standardUserDefaults] objectForKey:@"price_array"];
    dish_oid = [[NSUserDefaults standardUserDefaults] objectForKey:@"dish_oid_array"];
    for (int k = 0; k < [dish_name count]; k++) {
        if ([[order_array objectAtIndex:k] integerValue] > 0 ) {
            non_empty_count++;
        }
    }
    order_summary_array = [NSMutableArray arrayWithCapacity:non_empty_count];
    order_total_unit = [NSMutableArray arrayWithCapacity:non_empty_count];
    dish_name_summary = [NSMutableArray arrayWithCapacity:non_empty_count];
    summary_unit_price = [NSMutableArray arrayWithCapacity:non_empty_count];
    summary_dish_oid = [NSMutableArray arrayWithCapacity:non_empty_count];
    for (int k = 0; k < [dish_name count]; k++) {
        if ([[order_array objectAtIndex:k] integerValue] > 0 ) {
            subtotal = 0;
            NSString *index_temp = [NSString stringWithFormat:@"%d", k];
            NSString *total_temp = [NSString stringWithFormat:@"%@", [order_array objectAtIndex:k]];
            [order_summary_array addObject:index_temp];
            [order_total_unit addObject:total_temp];
            [dish_name_summary addObject:[dish_name objectAtIndex:k]];
            [summary_dish_oid addObject:[dish_oid objectAtIndex:k]];
            [summary_unit_price addObject:[unit_price objectAtIndex:k]];
            subtotal = subtotal + [total_temp floatValue] * [[unit_price objectAtIndex:k] floatValue];
        }
    }
    _restaurant_name.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"restuarant_selected"];
    _subtotal.text = [NSString stringWithFormat:@"$%.2f", subtotal];
    _delivery_fee.text = [NSString stringWithFormat:@"$%.2f", [[[NSUserDefaults standardUserDefaults] objectForKey:@"delivery"] floatValue]];
    float tax_fee = (subtotal+ [[[NSUserDefaults standardUserDefaults] objectForKey:@"delivery"] floatValue]) * 0.05;
    _tax.text = [NSString stringWithFormat:@"$%.2f", tax_fee];
    float total_ = subtotal + [[[NSUserDefaults standardUserDefaults] objectForKey:@"delivery"] floatValue] + tax_fee;
    _total_cost.text = [NSString stringWithFormat:@"$%.2f", total_];
    
    NSLog(@"order summary_index --> %@", order_summary_array);
    NSLog(@"order unit_total --> %@", order_total_unit);
    NSLog(@"DISH NAME --> %@", dish_name_summary);
    NSLog(@"Unit Price --> %@", summary_unit_price);

    
    // Do any additional setup after loading the view.
    /*CGFloat height = self.Summary_menu.rowHeight;
    height *= 4;
    
    CGRect tableFrame = self.Summary_menu.frame;
    tableFrame.size.height = height;
    self.Summary_menu.frame = tableFrame;*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dismissKeyboard:(id)sender
{
    [self.view endEditing:YES];
}


/*- (IBAction)textViewDidBeginEditing:(id)sender
{
    NSLog(@"selecting all...");
    [_Common_field selectAll:self];
}*/

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [textView selectAll:nil];
    });
    return YES;
}


-(IBAction)barButtonCustomPressed:(UIBarButtonItem*)btn
{
    NSLog(@"button tapped !");
    UITabBarController *tbc = [self.storyboard instantiateViewControllerWithIdentifier:@"tbcon"];
    tbc.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:tbc animated:YES completion:nil];
}

-(IBAction)gobackButtonCustomPressed:(UIBarButtonItem*)btn
{
    NSLog(@"button tapped !");
    UITabBarController *tbc = [self.storyboard instantiateViewControllerWithIdentifier:@"order_start"];
    tbc.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentViewController:tbc animated:YES completion:nil];
}

-(IBAction)Place_order_button:(id)sender{
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    NSString *timeString = [outputFormatter stringFromDate:now];
    NSString *instruction = nil;
    
    if ([self.Common_field.text isEqualToString:@"Add delivery instructions here..."]) {
        instruction = @"";
    }
    else {
        instruction = self.Common_field.text;
    }
    NSLog(@"timeString %@", timeString);
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"User_id"];
    NSString *rest_oid = [[NSUserDefaults standardUserDefaults] objectForKey:@"restuarant_selected"];
    NSDictionary *body = @{@"Username":username,@"Time_Placed":timeString,@"rest_oid":rest_oid, @"dish_ordered":summary_dish_oid,@"dish_name": dish_name_summary ,@"order_array":order_total_unit, @"subtotal":[NSString stringWithFormat:@"%.2f", subtotal], @"delivery_instruction":instruction};
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&error];
    NSString *jsonString4 = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"Dict: %@", jsonString4);

    AFURLSessionManager *manager_post = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *req_post = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:BaseURLString  parameters:nil error:nil];
    
    req_post.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
    [req_post setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req_post setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req_post setHTTPBody:[jsonString4 dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[manager_post dataTaskWithRequest:req_post completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (error == nil) {
            NSLog(@"order placed!");
            NSLog(@"Response: %@", responseObject);
        }
        else {
            NSLog(@"ERROR:%@", error);
        }
    }]resume];
    
    NSLog(@"button tapped !");
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Set the custom view mode to show any view.
    hud.mode = MBProgressHUDModeCustomView;
    // Set an image view with a checkmark.
    UIImage *image = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    // Looks a bit nicer if we make it square.
    hud.square = YES;
    // Optional label text.
    hud.label.text = NSLocalizedString(@"Order Placed!", @"HUD done title");
    
    [hud hideAnimated:YES afterDelay:2.f];
    [self performSelector:@selector(delaynomore) withObject:nil afterDelay:2];
}

- (void) delaynomore {
    UITabBarController *tbc = [self.storyboard instantiateViewControllerWithIdentifier:@"tbcon"];
    tbc.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:tbc animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [order_summary_array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"OrderSummaryTableViewCell";
    
    
    OrderSummaryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"OrderSummaryTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.dish_name.text = [dish_name_summary objectAtIndex:indexPath.row];
    cell.unit.text = [NSString stringWithFormat:@"x%@", [order_total_unit objectAtIndex:indexPath.row]];
    cell.price_tag.text = [NSString stringWithFormat:@"$%.2f", [[summary_unit_price objectAtIndex:indexPath.row] floatValue]];
    
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}


- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
