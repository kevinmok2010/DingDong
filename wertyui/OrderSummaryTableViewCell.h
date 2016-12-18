//
//  OrderSummaryTableViewCell.h
//  wertyui
//
//  Created by Kevin Mok on 2016-12-12.
//  Copyright © 2016 Kevin Mok. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderSummaryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dish_name;
@property (weak, nonatomic) IBOutlet UILabel *unit;
@property (weak, nonatomic) IBOutlet UILabel *price_tag;

@end
