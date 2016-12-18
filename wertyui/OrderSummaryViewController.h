//
//  OrderSummaryViewController.h
//  wertyui
//
//  Created by Kevin Mok on 2016-12-08.
//  Copyright © 2016 Kevin Mok. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderSummaryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *restaurant_name;
@property (weak, nonatomic) IBOutlet UITableView *Summary_menu;
@property (weak, nonatomic) IBOutlet UITextView *Common_field;
@property (weak, nonatomic) IBOutlet UILabel *subtotal;
@property (weak, nonatomic) IBOutlet UILabel *delivery_fee;
@property (weak, nonatomic) IBOutlet UILabel *tax;
@property (weak, nonatomic) IBOutlet UILabel *total_cost;
@property (weak, nonatomic) IBOutlet UIButton *Place_order_button;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancel_button;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *Go_back_button;


@end
