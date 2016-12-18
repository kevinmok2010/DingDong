//
//  RegisterViewController.h
//  wertyui
//
//  Created by Kevin Mok on 2016-10-16.
//  Copyright © 2016 Kevin Mok. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>
@property (retain, nonatomic) IBOutlet UITextField *unique_username;
@property (retain, nonatomic) IBOutlet UITextField *unique_pw;
@property (retain, nonatomic) IBOutlet UITextField *unique_retype;
@property (retain, nonatomic) IBOutlet UIButton *submit_button;
@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UIButton *face_button;
@property (weak, nonatomic) IBOutlet UIImageView *Profile_pic;



@end
