//
//  FirstViewController.h
//  wertyui
//
//  Created by Kevin Mok on 2016-10-11.
//  Copyright © 2016 Kevin Mok. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FirstViewController <NSObject>
@end

@interface FirstViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *PostalcodeText;


/*- (IBAction)Hashpw:(id)sender;
- (IBAction)CALLJSON:(id)sender;
- (IBAction)POSTJSON:(id)sender;
- (IBAction)Reset:(id)sender;*/
@end

