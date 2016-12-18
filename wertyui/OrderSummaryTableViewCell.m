//
//  OrderSummaryTableViewCell.m
//  wertyui
//
//  Created by Kevin Mok on 2016-12-12.
//  Copyright © 2016 Kevin Mok. All rights reserved.
//

#import "OrderSummaryTableViewCell.h"
#import "OrderSummaryViewController.h"

@implementation OrderSummaryTableViewCell

@synthesize dish_name = _dish_name;
@synthesize unit = _unit;
@synthesize price_tag = _price_tag;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
