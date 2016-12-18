//
//  SecondViewController.h
//  wertyui
//
//  Created by Kevin Mok on 2016-10-11.
//  Copyright © 2016 Kevin Mok. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SecondViewController <NSObject>
@end

@interface SecondViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *User;
@property (strong, nonatomic) IBOutlet UIImageView *Profile_pic;

- (IBAction)Logout_Button:(id)sender;
@end

