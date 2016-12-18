//
//  MyTableViewCell.m
//  wertyui
//
//  Created by Kevin Mok on 2016-11-21.
//  Copyright © 2016 Kevin Mok. All rights reserved.
//

#import "MyTableViewCell.h"
#import "OrderViewController.h"

@implementation MyTableViewCell


@synthesize prep_time = _prep_time;
@synthesize namelabel = _namelabel;
@synthesize Thumbnail = _Thumbnail;
@synthesize order_value = _order_value;


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
        
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}






- (IBAction)valueChanged:(UIStepper *)sender{
    double stepperValue = [sender value];
    _order_value.text = [NSString stringWithFormat:@"x%d", (int)stepperValue];
    NSInteger i = _stepper.tag;
    
    
    NSMutableArray *order_array = [NSMutableArray array];
    order_array = [[NSUserDefaults standardUserDefaults] objectForKey:@"order_array"];
    NSInteger j = [order_array count];
    NSLog(@"sender tag: %ld", (long)i);
    NSNumber *temp = [NSNumber numberWithDouble:stepperValue];
    
    NSMutableArray *new_order_array = [NSMutableArray arrayWithCapacity:j];
    for (int k = 0; k < j; k++) {
            [new_order_array addObject:order_array[k]];
    }
    [new_order_array replaceObjectAtIndex:i withObject:temp];
    NSString *add_flag = @"1";
    [[NSUserDefaults standardUserDefaults] setObject:add_flag forKey:@"add_flag"];
    [[NSUserDefaults standardUserDefaults]setObject:new_order_array forKey:@"order_array"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSLog(@"NEW_ORDER_ARRAY: %@", new_order_array);
    
    
    
    

    
    
}

@end
