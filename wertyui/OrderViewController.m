//
//  OrderViewController.m
//  wertyui
//
//  Created by Kevin Mok on 2016-11-15.
//  Copyright © 2016 Kevin Mok. All rights reserved.
//

#import "OrderViewController.h"
#import "AFNetworking.h"
#import "DejalActivityView.h"
#import "MyTableViewCell.h"

static NSString * const BaseURLString = @"https://api.mlab.com/api/1/databases/food/collections/menus?apiKey=BwvONax567WvFHAlBXqQFiG0fDpJJJVF";

NSMutableArray *dish_oid_array = nil;
NSMutableArray *users_id_array = nil;
NSMutableArray *prep_time_array = nil;
NSMutableArray *description_array = nil;
NSMutableArray *image_url_array = nil;
NSMutableArray *price_array = nil;
NSMutableArray *dish_name_array = nil;
NSMutableArray *menu_array = nil;
NSMutableArray *Menu_index_array = nil;
NSMutableArray *new_dish_array = nil;
NSMutableArray *new_index_array = nil;
NSMutableArray *new_price = nil;
NSMutableArray *new_img = nil;
NSMutableArray *new_prep_time = nil;
NSMutableArray *new_description = nil;
NSMutableArray *height_array = nil;
NSInteger start_flag = 0;
NSInteger done_Flag = 0;
NSInteger cancel_flag = 0;
NSInteger add_flag = 0;
NSInteger search_update_flag = 0;
NSInteger cell_count = 0;
NSInteger last_cell = 0;
NSInteger order_cancel_flag = 0;
NSIndexPath *my_index_path = nil;
NSData *imageData = nil;
NSNumber *total_price = 0;

@interface OrderViewController () 

@end

@implementation OrderViewController
{
    NSArray *tableData;
    NSArray *thumbnails;
    //NSArray *prepTime;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _cancel_button.target = self;
    _cancel_button.action = @selector(barButtonCustomPressed:);
    
    _min_order.text = [NSString stringWithFormat:@"$ %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"min_price"]];
    _total_price.text = [NSString stringWithFormat:@"$0.00"];;
    _Restuarant_name.text =[[NSUserDefaults standardUserDefaults] objectForKey:@"restuarant_selected"];
    NSString *restuarant_selected_oid = [[NSUserDefaults standardUserDefaults] objectForKey:@"restuarant_selected"];
    
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Fetching..."].showNetworkActivityIndicator = YES;
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:BaseURLString  parameters:nil error:nil];
    req.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"%@", responseObject);
        if (error == nil) {
            NSArray *info_array = [responseObject valueForKey:@"_id"];
            users_id_array = [responseObject mutableArrayValueForKey:@"user_id"];
            NSLog(@"user_id --> %@", users_id_array);
            NSInteger count = [users_id_array count];
            Menu_index_array = [NSMutableArray array];
            for (int k = 0; k < count ; k++) {
                if ([[users_id_array objectAtIndex:k] isEqualToString:restuarant_selected_oid]) {
                    NSNumber *index = [NSNumber numberWithInt:k];
                    [Menu_index_array addObject:index];
                    NSLog(@"MATCH!! :%@ at index %@", Menu_index_array,index);
                }
            }
            NSInteger menu_index_count = [Menu_index_array count];
            if (menu_index_count == 0) {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                               message:@"Failed to retrive menu."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"FUCK!" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                [DejalBezelActivityView removeViewAnimated:YES];
                [self performSelector:@selector(refreshLabel) withObject:nil afterDelay:1];
                return;
            }
            
            else {
                imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://gentle-peak-37468.herokuapp.com/img/menus/_0007331-2027.jpg"]];
                dish_name_array = [NSMutableArray arrayWithCapacity:menu_index_count];
                prep_time_array = [NSMutableArray arrayWithCapacity:menu_index_count];
                description_array = [NSMutableArray arrayWithCapacity:menu_index_count];
                image_url_array = [NSMutableArray arrayWithCapacity:menu_index_count];
                price_array = [NSMutableArray arrayWithCapacity:menu_index_count];
                dish_oid_array = [NSMutableArray arrayWithCapacity:menu_index_count];
            for (int j = 0; j < menu_index_count; j++) {
                NSInteger menu_index_int = [Menu_index_array[j] intValue];
                [description_array addObject:[[responseObject valueForKey:@"description"] objectAtIndex:menu_index_int]];
                [image_url_array addObject:[[responseObject mutableArrayValueForKey:@"img_url"] objectAtIndex:menu_index_int]];
                [dish_name_array addObject:[[responseObject mutableArrayValueForKey:@"name"] objectAtIndex:menu_index_int]];
                [prep_time_array addObject:[[responseObject mutableArrayValueForKey:@"prep_time"] objectAtIndex:menu_index_int]];
                [price_array addObject:[[responseObject mutableArrayValueForKey:@"price"] objectAtIndex:menu_index_int]];
                NSString *price_string = price_array[j];
                NSNumber *price_tag = [NSNumber numberWithDouble:[price_string doubleValue]];
                NSLog(@"%@", price_tag);
                
                [dish_oid_array addObject:[[info_array mutableArrayValueForKey:@"$oid"] objectAtIndex:menu_index_int]];
                NSLog(@"Dishes: %@", [[responseObject mutableArrayValueForKey:@"name"] objectAtIndex:menu_index_int]);
                NSLog(@"image_url_array: %@", [[responseObject mutableArrayValueForKey:@"img_url"] objectAtIndex:menu_index_int]);
                NSLog(@"description: %@", [[responseObject valueForKey:@"description"] objectAtIndex:menu_index_int]);
            }
            NSLog(@"restuarant selected: --> %@", restuarant_selected_oid);
            NSLog(@"menu_index_array --> %@", Menu_index_array);
            NSLog(@"dish_name_array --> %@", dish_name_array);
                if ([[NSUserDefaults standardUserDefaults]objectForKey:@"order_array"] == nil || [[[NSUserDefaults standardUserDefaults]objectForKey:@"order_array"]  count] != [Menu_index_array count]){
            NSMutableArray *order_array = [NSMutableArray arrayWithCapacity:menu_index_count];
            int k = 0;
            for (k=0; k<menu_index_count; k++) {
                [order_array addObject:[NSNumber numberWithInt:0]];
            }
            NSLog(@"order array: %@", order_array);
            [[NSUserDefaults standardUserDefaults] setObject:order_array forKey:@"order_array"];
            [[NSUserDefaults standardUserDefaults] setObject:price_array forKey:@"price_array"];
            [[NSUserDefaults standardUserDefaults] setObject:dish_oid_array forKey:@"dish_oid_array"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            }
            [NSTimer scheduledTimerWithTimeInterval:0.5
                                             target:self
                                           selector:@selector(wait_for_info:)
                                           userInfo:nil repeats:YES];
            [self.menu reloadData];
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"add_flag"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self performSelector:@selector(refreshLabel) withObject:nil afterDelay:1];
            } }else {
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];

    
    
    // Do any additional setup after loading the view.
     tableData = [NSArray arrayWithObjects:@"Egg Benedict", @"Mushroom Risotto", @"Full Breakfast", @"Hamburger", @"Ham and Egg Sandwich", @"Creme Brelee", nil];
    thumbnails = [NSArray arrayWithObjects:@"creme_brelee.jpg", @"creme_brelee.jpg", @"creme_brelee.jpg", @"creme_brelee.jpg", @"creme_brelee.jpg", @"creme_brelee.jpg", nil];
    NSLog(@"thumbnails: %@", thumbnails);
    //prepTime = [NSArray arrayWithObjects:@"30 mins", @"30 mins", @"20 mins", @"10 mins", @"33 mins", @"15 mins", nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)wait_for_info:(NSTimer*)theTimer{
    if ([users_id_array count] == 0 || imageData == nil){
        NSLog(@"Waiting...");
        
    }
    else {
        [DejalBezelActivityView removeViewAnimated:YES];
        [theTimer invalidate];
    }
}


-(IBAction)barButtonCustomPressed:(UIBarButtonItem*)btn
{
    NSLog(@"button tapped !");
    dish_oid_array = nil;
    new_dish_array = nil;
    users_id_array = nil;
    prep_time_array = nil;
    description_array = nil;
    image_url_array = nil;
    price_array = nil;
    dish_name_array = nil;
    menu_array = nil;
    Menu_index_array = nil;
    my_index_path = nil;
    height_array = nil;
    start_flag = 1;
    total_price = 0;
    order_cancel_flag = 1;
    search_update_flag = 0;
    UITabBarController *tbc = [self.storyboard instantiateViewControllerWithIdentifier:@"tbcon"];
    tbc.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:tbc animated:YES completion:nil];
}

-(void) dismissKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    search_update_flag = 0;
    cancel_flag = 1;
    height_array = nil;
    height_array = [NSMutableArray arrayWithCapacity:[dish_name_array count]];
    [_menu reloadData];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"test");
    last_cell = 0;
    if ([searchText isEqualToString:@""]) {
        search_update_flag = 0;
        height_array = 0;
        cancel_flag = 1;
        [_menu reloadData];
    }else{
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchText];
    NSArray *temp = nil;
    temp = [dish_name_array filteredArrayUsingPredicate:filterPredicate];
    new_dish_array = [NSMutableArray arrayWithCapacity:[temp count]];
    new_dish_array = [temp mutableCopy];
    NSLog(@"new_dish_array: %@", new_dish_array);
    NSInteger old_count = [dish_name_array count];
    new_index_array = [NSMutableArray arrayWithCapacity:[temp count]];
    new_price = [NSMutableArray arrayWithCapacity:[temp count]];
    new_img = [NSMutableArray arrayWithCapacity:[temp count]];
    new_prep_time = [NSMutableArray arrayWithCapacity:[temp count]];
    new_description = [NSMutableArray arrayWithCapacity:[temp count]];
    
    for (int k = 0; k < [new_dish_array count]; k++) {
        for (int j = 0; j < old_count; j++) {
            if ([dish_name_array[j] isEqualToString:new_dish_array[k]]) {
                [new_index_array addObject:[NSNumber numberWithInt:j]];
                [new_price addObject:price_array[j]];
                [new_img addObject:image_url_array[j]];
                [new_prep_time addObject:prep_time_array[j]];
                [new_description addObject:description_array[j]];
                NSLog(@"searching!");
            }
        }
    }
    NSLog(@"New_index_array: %@", new_index_array);
    NSLog(@"new_price: %@", new_price);
    NSLog(@"new_img: %@", new_img);
    NSLog(@"new_prep_time: %@", new_prep_time);
    NSLog(@"new_description: %@", new_description);
        search_update_flag = 1;
        [_menu reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (search_update_flag == 1) {
        NSLog(@"new_dish_array_count --> %lu", (unsigned long)[new_dish_array count]);
        return [new_dish_array count];
    }
    return [dish_name_array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"OrderTableCell";
    self.menu.delegate = self;
    
    MyTableViewCell *cell = (MyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil && search_update_flag == 0)
    {   start_flag = 1;
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"OrderTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.stepper.tag = indexPath.row;
        cell.order_value.tag = indexPath.row;
        cell.namelabel.text = [dish_name_array objectAtIndex:indexPath.row];
        cell.Thumbnail.image = [UIImage imageWithData: imageData];//[UIImage imageNamed:[thumbnails objectAtIndex:indexPath.row]];
        cell.prep_time.text = [prep_time_array objectAtIndex:indexPath.row];
        cell.Discription_field.text = [description_array objectAtIndex:indexPath.row];
        cell.Price_tag.text = [NSString stringWithFormat:@"$ %@",[price_array objectAtIndex:indexPath.row]];//[price_array objectAtIndex:indexPath.row];
        cell.Thumbnail.layer.cornerRadius = 10.0f;
        cell.Thumbnail.clipsToBounds = YES;
        cell.stepper.value = 0;
        height_array = [NSMutableArray arrayWithCapacity:[dish_name_array count]];
        for (int k = 0; k < [dish_name_array count]; k++) {
            [height_array addObject:[NSString stringWithFormat:@"0"]];
        }
        NSLog(@"height array: %@", height_array);
    }
    
    else if (search_update_flag == 1){
        start_flag = 1;
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"OrderTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.stepper.tag = [[new_index_array objectAtIndex:indexPath.row] integerValue];
        cell.order_value.tag = [[new_index_array objectAtIndex:indexPath.row] integerValue];
        cell.namelabel.text = [new_dish_array objectAtIndex:indexPath.row];
        NSLog(@"new_dishes_being_add_to_the_table ---> %@ at index %ld" , [new_dish_array objectAtIndex:indexPath.row], (long)indexPath.row);
        cell.Thumbnail.image = [UIImage imageWithData: imageData];//[UIImage imageNamed:[thumbnails objectAtIndex:indexPath.row]];
        cell.prep_time.text = [new_prep_time objectAtIndex:indexPath.row];
        cell.Discription_field.text = [new_description objectAtIndex:indexPath.row];
        cell.Price_tag.text = [NSString stringWithFormat:@"$ %@",[new_price objectAtIndex:indexPath.row]];
        cell.Thumbnail.layer.cornerRadius = 10.0f;
        cell.Thumbnail.clipsToBounds = YES;
        //[[new_index_array objectAtIndex:indexPath.row] integerValue]
        NSArray *refresh_data = [[NSUserDefaults standardUserDefaults] objectForKey:@"order_array"];
        cell.order_value.text = [NSString stringWithFormat:@"x%@",[refresh_data objectAtIndex:[[new_index_array objectAtIndex:indexPath.row] integerValue]]];
        cell.stepper.value = [[refresh_data objectAtIndex:[[new_index_array objectAtIndex:indexPath.row] integerValue]] integerValue];
        my_index_path = nil;
        height_array = [NSMutableArray arrayWithCapacity:[new_dish_array count]];
        for (int k = 0; k < [new_dish_array count]; k++) {
            [height_array addObject:[NSString stringWithFormat:@"0"]];
        }
        NSLog(@"height array: %@", height_array);
        return cell;
    }
    NSArray *refresh_data = [[NSUserDefaults standardUserDefaults] objectForKey:@"order_array"];
    cell.order_value.text = [NSString stringWithFormat:@"x%@",[refresh_data objectAtIndex:indexPath.row]];
    cell.stepper.value = [[refresh_data objectAtIndex:indexPath.row] integerValue];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (my_index_path == nil && done_Flag == 1 && [height_array count] == [dish_name_array count]) {
        my_index_path = indexPath;
        cancel_flag = 0;
    }
    else if (my_index_path == nil && done_Flag == 0){
        return 77;
    }
    
    else if (my_index_path && indexPath.row == my_index_path.row && start_flag == 1){
        start_flag = 0;
        cell_count = 0;
        cancel_flag = 0;
        last_cell = indexPath.row;
        [height_array replaceObjectAtIndex:indexPath.row withObject:@"1"];
        NSLog(@"height array --> %@", height_array);
        return 175;
        
    }
    else if(my_index_path && indexPath.row == my_index_path.row && cancel_flag == 0 && start_flag == 0) {
        NSLog(@"JUKE!!");
        if ([[height_array objectAtIndex:indexPath.row] isEqualToString:@"1"] && last_cell == indexPath.row ) {
            [height_array replaceObjectAtIndex:indexPath.row withObject:@"0"];
            NSLog(@"height array --> %@", height_array);
            return 77;
        }
        else if ([[height_array objectAtIndex:indexPath.row] isEqualToString:@"1"] && last_cell != indexPath.row ) {
            [height_array replaceObjectAtIndex:last_cell withObject:@"0"];
            [height_array replaceObjectAtIndex:indexPath.row withObject:@"0"];
            last_cell = indexPath.row;
            NSLog(@"height array --> %@", height_array);
            return 77;
            }
        else if ([[height_array objectAtIndex:indexPath.row] isEqualToString:@"0"] && last_cell == indexPath.row ){
            [height_array replaceObjectAtIndex:indexPath.row withObject:@"1"];
            last_cell = indexPath.row;
            NSLog(@"height array --> %@", height_array);
            return 175;
            }
        else if ([[height_array objectAtIndex:indexPath.row] isEqualToString:@"0"] && last_cell != indexPath.row ){
            [height_array replaceObjectAtIndex:last_cell withObject:@"0"];
            [height_array replaceObjectAtIndex:indexPath.row withObject:@"1"];
            last_cell = indexPath.row;
            NSLog(@"height array --> %@", height_array);
            return 175;
        }

    }
    if (cancel_flag == 1){
        last_cell = 0;
        my_index_path = nil;
        start_flag = 1;
        cell_count++;
        if (cell_count <[dish_name_array count]-1){
            done_Flag = 1;
            NSLog(@"cell count! --> %ld", (long)cell_count);
            NSLog(@"done!");
        }
        [height_array addObject:[NSString stringWithFormat:@"0"]];
        NSLog(@"cell count! --> %ld", (long)cell_count);
        return 77;
        
    
    }
    return 77;
}


- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    my_index_path = indexPath;
    [tableView beginUpdates];
    [self tableView:self.menu didDeselectRowAtIndexPath:indexPath];
    [tableView endUpdates];
    
    NSLog(@"didSelectRowAtIndexPath --> %lu", (long)my_index_path.row);
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Change the selected background view of the cell.
    [self.menu deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)submit_order:(id)sender{
    if ([total_price integerValue] < [[[NSUserDefaults standardUserDefaults] objectForKey:@"min_price"] integerValue]){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                       message:@"Order more for delivery service ;)"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"FUCK!" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    else{
        NSLog(@"Submit!");
        start_flag = 1;
        order_cancel_flag = 1;
        search_update_flag = 0;
        //[[NSUserDefaults standardUserDefaults] objectForKey:@"order_array"]
        //[[NSUserDefaults standardUserDefaults] objectForKey:@"restuarant_selected"];
        [[NSUserDefaults standardUserDefaults] setObject:dish_name_array forKey:@"dish_name_array"];
        [[NSUserDefaults standardUserDefaults] setObject:dish_oid_array forKey:@"dish_oid_array"];
        [[NSUserDefaults standardUserDefaults] setObject:price_array forKey:@"price_array"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"order_summary"];
        vc.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        [self presentViewController:vc animated:YES completion:nil];

    }
    
}
- (void)refreshLabel
{
    NSLog(@"Label refreshing...");
    //refresh the label.text on the main thread
    dispatch_async(dispatch_get_main_queue(),^{
        
        NSArray *refresh_data = [[NSUserDefaults standardUserDefaults] objectForKey:@"order_array"];
        NSString *add_flag_string =[[NSUserDefaults standardUserDefaults] objectForKey:@"add_flag"];
        NSInteger count = [refresh_data count];
        if (order_cancel_flag == 0){
            if ([add_flag_string isEqualToString:@"0"]) {
            [self performSelector:@selector(refreshLabel) withObject:nil afterDelay:0.1];
        }
        
        else{
            float temp_total = 0;
        for (int z = 0; z < count ; z++) {
            NSString *unit_price_string = [price_array objectAtIndex:z];
            NSString *unit = [refresh_data objectAtIndex:z];
            float float_price = [unit_price_string floatValue];
            float float_unit = [unit floatValue];
            temp_total += float_price * float_unit;
        }
            total_price = [NSNumber numberWithFloat: temp_total];
            _total_price.text = [NSString stringWithFormat:@"$%.2f",temp_total];;
            //NSLog(@"Total Price: %.2f", temp_total);
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"add_flag"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self performSelector:@selector(refreshLabel) withObject:nil afterDelay:0.1];
        }
        }else{
            order_cancel_flag = 0;
        }
    });
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
