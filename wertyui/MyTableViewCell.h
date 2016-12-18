//
//  MyTableViewCell.h
//  wertyui
//
//  Created by Kevin Mok on 2016-11-21.
//  Copyright © 2016 Kevin Mok. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *prep_time;
@property (weak, nonatomic) IBOutlet UILabel *namelabel;
@property (weak, nonatomic) IBOutlet UIImageView *Thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *order_value;

@property (weak, nonatomic) IBOutlet UIStepper *stepper;
@property (weak, nonatomic) IBOutlet UILabel *Price_tag;
@property (weak, nonatomic) IBOutlet UILabel *Discription_field;

@end
