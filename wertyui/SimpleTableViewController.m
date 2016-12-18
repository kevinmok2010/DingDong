//
//  SimpleTableViewController.m
//  
//
//  Created by Kevin Mok on 2016-11-02.
//
//

#import "SimpleTableViewController.h"
#import "AFNetworking.h"
#import "DejalActivityView.h"


static NSString * const BaseURLString = @"https://api.mlab.com/api/1/databases/food/collections/users?apiKey=BwvONax567WvFHAlBXqQFiG0fDpJJJVF";

NSMutableArray *oid_array = nil;
NSMutableArray *users_array = nil;
NSMutableArray *min_price = nil;
NSMutableArray *delivery = nil;

@interface SimpleTableViewController ()

@end

@implementation SimpleTableViewController

{
    NSArray *tableData;
    NSArray *thumbnails;
}
@synthesize Thumbnail = _Thumbnail;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"order_array"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Fetching..."].showNetworkActivityIndicator = YES;

   /* NSMutableString *Modified_url = [NSMutableString stringWithCapacity: 150];
    [Modified_url appendString: @"https://api.mlab.com/api/1/databases/jukejuke/collections/pictures/"];
    [Modified_url appendFormat: @"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"pic_oid"]];
    [Modified_url appendString: @"?apiKey=BwvONax567WvFHAlBXqQFiG0fDpJJJVF"];
    //NSLog(@"%@", Modified_url);*/
    

    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:BaseURLString  parameters:nil error:nil];
    req.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"%@", responseObject);
                if (error == nil) {
                    NSArray *info_array = [responseObject valueForKey:@"_id"];
                    users_array = [responseObject mutableArrayValueForKey:@"name"];
                    oid_array = [info_array mutableArrayValueForKey:@"$oid"];
                    min_price = [responseObject mutableArrayValueForKey:@"min_order"];
                    delivery = [responseObject mutableArrayValueForKey:@"delivery"];
                    [NSTimer scheduledTimerWithTimeInterval:0.5
                                                     target:self
                                                   selector:@selector(wait_for_info:)
                                                   userInfo:nil repeats:YES];
                    [self.table_view reloadData];
                    
                   // NSArray *_id_array = [responseObject valueForKey:@"_id"];
                  //  NSArray *pic_oid_array = [info_array mutableArrayValueForKey:@"pic_oid"];
                    
                            } else {
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
   
   /* tableData = [NSArray arrayWithObjects:@"Egg Benedict", @"Mushroom Risotto", @"Full Breakfast", @"Hamburger", @"Ham and Egg Sandwich", @"Creme Brelee", @"White Chocolate Donut", @"Starbucks Coffee", @"Vegetable Curry", @"Instant Noodle with Egg", @"Noodle with BBQ Pork", @"Japanese Noodle with Pork", @"Green Tea", @"Thai Shrimp Cake", @"Angry Birds Cake", @"Ham and Cheese Panini", nil];*/
    thumbnails = [NSArray arrayWithObjects:@"creme_brelee.jpg", @"creme_brelee.jpg", @"creme_brelee.jpg", @"creme_brelee.jpg", @"creme_brelee.jpg", @"creme_brelee.jpg", @"creme_brelee.jpg",nil];
    NSLog(@"thumbnails: %@", thumbnails);

}

- (void)wait_for_info:(NSTimer*)theTimer{
    if ([users_array count] == 0) {
        NSLog(@"Waiting...");
        
    }
    else {
        [DejalBezelActivityView removeViewAnimated:YES];
        [theTimer invalidate];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [users_array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
 
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SimpleTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        _namelabel.text = [users_array objectAtIndex:indexPath.row];
        _Thumbnail.image = [UIImage imageNamed:[thumbnails objectAtIndex:0/*indexPath.row*/]];
        _Thumbnail.layer.cornerRadius = 10.0f;
        _Thumbnail.clipsToBounds = YES;
    }

    

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 77;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
    NSInteger row_num = (long)indexPath.row;
    NSString *restuarant_selected = [oid_array objectAtIndex:row_num];
    NSString *min_order = [min_price objectAtIndex:row_num];
    NSString *delivery_charge =  [delivery objectAtIndex:row_num];
    [self tableView:_table_view didDeselectRowAtIndexPath:indexPath];
    [[NSUserDefaults standardUserDefaults] setObject:restuarant_selected forKey:@"restuarant_selected"];
    [[NSUserDefaults standardUserDefaults] setObject:min_order forKey:@"min_price"];
    [[NSUserDefaults standardUserDefaults] setObject:delivery_charge forKey:@"delivery"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"order_start"];
    vc.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    NSLog(@"%lu", (long)indexPath.row);
    NSLog(@"%@", restuarant_selected);
    [self presentViewController:vc animated:YES completion:nil];


}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Change the selected background view of the cell.
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
