//
//  UserLoginViewController.h
//  wertyui
//
//  Created by Kevin Mok on 2016-10-16.
//  Copyright © 2016 Kevin Mok. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol UserLoginViewController <NSObject>


@end

@interface UserLoginViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *id_unique;
@property (strong, nonatomic) IBOutlet UITextField *pw_unique;
@property (weak, nonatomic) IBOutlet UIButton *Login_button;
@property (weak, nonatomic) IBOutlet UIButton *Register_button;
@property (nonatomic, assign) id <UserLoginViewController> delegate;
@property (nonatomic, retain) UserLoginViewController *loginview;
@property (weak, nonatomic) UIWindow *window;

@end
