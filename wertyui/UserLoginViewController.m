//
//  UserLoginViewController.m
//  wertyui
//
//  Created by Kevin Mok on 2016-10-16.
//  Copyright © 2016 Kevin Mok. All rights reserved.
//

#import "UserLoginViewController.h"
#import "AFNetworking.h"
#import "JFBCrypt.h"
#import "AppDelegate.h"
#import "DejalActivityView.h"
static NSString * const BaseURLString = @"https://api.mlab.com/api/1/databases/jukejuke/collections/usersinfo?apiKey=BwvONax567WvFHAlBXqQFiG0fDpJJJVF";

static NSString * const PicURLString = @"https://api.mlab.com/api/1/databases/jukejuke/collections/pictures?apiKey=BwvONax567WvFHAlBXqQFiG0fDpJJJVF";


@interface UserLoginViewController ()

@end

@implementation UserLoginViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
    self.pw_unique.delegate = self;
    }



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)wait_for_pic:(NSTimer*)theTimer{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"Profile_pic"] == nil) {
        NSLog(@"Waiting...");

    }
    else {
        [DejalBezelActivityView removeViewAnimated:YES];
        [theTimer invalidate];
        UITabBarController *tbc = [self.storyboard instantiateViewControllerWithIdentifier:@"tbcon"];
        tbc.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:tbc animated:YES completion:nil];
    }
}

- (IBAction)textFieldDidBeginEditing:(id)sender
{
    UITextField *txtFld = ((UITextField *)sender);
    NSLog(@"sender --> %@",sender);
    [txtFld selectAll:self];
}


- (void)getpicture{
    NSMutableString *Modified_url = [NSMutableString stringWithCapacity: 150];
    [Modified_url appendString: @"https://api.mlab.com/api/1/databases/jukejuke/collections/pictures/"];
    [Modified_url appendFormat: @"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"pic_oid"]];
    [Modified_url appendString: @"?apiKey=BwvONax567WvFHAlBXqQFiG0fDpJJJVF"];
    NSURL *URL = [NSURL URLWithString:Modified_url];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [[manager GET:URL.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSMutableDictionary *response = [[responseObject valueForKey:@"Identification"]mutableCopy];
        NSString *pic_string = [response valueForKey:@"picture"];
        NSMutableDictionary *response_oid = [[responseObject valueForKey:@"_id"]mutableCopy];
        NSString *pic_oid_string = [response_oid valueForKey:@"$oid"];
        [[NSUserDefaults standardUserDefaults] setObject:pic_string forKey:@"Profile_pic"];
        [[NSUserDefaults standardUserDefaults]setObject:pic_oid_string forKey:@"pic_oid"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        NSLog(@"%@",pic_oid_string);
        
        if ([pic_string isEqualToString:@""]){
            [DejalBezelActivityView removeViewAnimated:YES];
            UITabBarController *tbc = [self.storyboard instantiateViewControllerWithIdentifier:@"tbcon"];
            [self presentViewController:tbc animated:YES completion:nil];
        }
        
        [NSTimer scheduledTimerWithTimeInterval:0.5
                                                          target:self
                                                        selector:@selector(wait_for_pic:)
                                                        userInfo:nil repeats:YES];
        
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }]resume];
}


-(void) dismissKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)Login_button:(id)sender{
    NSString *ID = _id_unique.text;
    NSString *password = _pw_unique.text;
    
    if (ID.length <=0 || password.length <= 0) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                       message:@"Please input correct credential!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"FUCK!" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;

    }
    
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Logging in..."].showNetworkActivityIndicator = YES;
    //GET:JSON - Download user's info from db
    NSString *string = BaseURLString;
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:string  parameters:nil error:nil];
    
    req.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Reply JSON: %@", responseObject);
            NSArray *info_array = [responseObject valueForKey:@"Identification"];
            NSArray *pw_array = [info_array mutableArrayValueForKey:@"Password"];
            NSArray *users_array = [info_array mutableArrayValueForKey:@"Username"];
            NSArray *_id_array = [responseObject valueForKey:@"_id"];
            NSArray *pic_oid_array = [info_array mutableArrayValueForKey:@"pic_oid"];
            NSInteger array_count = (unsigned) [info_array count];
            for (NSInteger k = 0; k < array_count; k++) {
                NSLog(@"Username: %@", [info_array objectAtIndex:k]);
                if ([[users_array objectAtIndex:k] isEqualToString:ID]) {
                    NSString *hash_from_db = [pw_array objectAtIndex:k];
                    NSString *salt = [hash_from_db substringWithRange:NSMakeRange(0, 29)];
                    NSString *computedHash = [JFBCrypt hashPassword:password withSalt:salt];
                    
            
                    if ([computedHash isEqualToString:hash_from_db]) {
                        NSLog(@"Credential Matched!");
                        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
                        [[NSUserDefaults standardUserDefaults] setObject:computedHash forKey:@"local_hash_pw"];
                        [[NSUserDefaults standardUserDefaults] setObject:ID forKey:@"User_id"];
                        NSString *user_oid = [_id_array objectAtIndex:k];
                        NSString *pic_oid = [pic_oid_array objectAtIndex:k];
                        NSLog(@"pic_oid_from_db = %@", pic_oid);
                        [[NSUserDefaults standardUserDefaults] setObject:user_oid forKey:@"oid"];
                        [[NSUserDefaults standardUserDefaults] setObject:pic_oid forKey:@"pic_oid"];
                        [standardUserDefaults synchronize];
                        [self getpicture];
                        return;
                        //UITabBarController *tbc = [self.storyboard instantiateViewControllerWithIdentifier:@"tbcon"];
                        //[self presentViewController:tbc animated:YES completion:nil];
                                            }
                    else {
                        NSLog(@"PW not match!");
                        [DejalBezelActivityView removeViewAnimated:YES];
                        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                       message:@"Username/Password not match!"
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"FUCK!" style:UIAlertActionStyleDefault
                                                                              handler:^(UIAlertAction * action) {}];
                        
                        [alert addAction:defaultAction];
                        [self presentViewController:alert animated:YES completion:nil];
                        return;
                    }
                }
                else {
                    NSLog(@"No Match!!");
                    
                    NSInteger j = k + 1;
                    NSLog(@"array_count --> %ld", (long)array_count);
                    NSLog(@"j --> %ld", (long)j);
                    if (j == array_count) {
                        [DejalBezelActivityView removeViewAnimated:YES];
                        NSLog(@"No account records!");
                        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                       message:@"Username/Password not match!"
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"FUCK!" style:UIAlertActionStyleDefault
                                                                              handler:^(UIAlertAction * action) {}];
                        
                        [alert addAction:defaultAction];
                        [self presentViewController:alert animated:YES completion:nil];
                        return;

                    }
                }

            }
            
            } else {
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
