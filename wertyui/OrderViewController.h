//
//  OrderViewController.h
//  wertyui
//
//  Created by Kevin Mok on 2016-11-15.
//  Copyright © 2016 Kevin Mok. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *menu;
@property (weak, nonatomic) IBOutlet UILabel *Restuarant_name;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancel_button;
@property (weak, nonatomic) IBOutlet UILabel *total_price;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *submit_order;
@property (weak, nonatomic) IBOutlet UILabel *min_order;


@end
