//
//  RegisterViewController.m
//  wertyui
//
//  Created by Kevin Mok on 2016-10-16.
//  Copyright © 2016 Kevin Mok. All rights reserved.
//

#import "RegisterViewController.h"
#import "AFNetworking.h"
#import "JFBCrypt.h"
#import "AppDelegate.h"
#import "DejalActivityView.h"


//APIKey -> BwvONax567WvFHAlBXqQFiG0fDpJJJVF

static NSString * const BaseURLString = @"https://api.mlab.com/api/1/databases/jukejuke/collections/usersinfo?apiKey=BwvONax567WvFHAlBXqQFiG0fDpJJJVF";

static NSString * const PicURLString = @"https://api.mlab.com/api/1/databases/jukejuke/collections/pictures?apiKey=BwvONax567WvFHAlBXqQFiG0fDpJJJVF";



NSString *entries = nil;
NSInteger Flag = 1;
NSString *picture_string = nil;
NSDictionary *body_pic = nil;
@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.unique_username setDelegate:self];
    [self.unique_pw setDelegate:self];
    [self.unique_retype setDelegate:self];
    [self.email setDelegate:self];
    
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
    
    _face_button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _face_button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_face_button setTitle: @"PUT YOUR FACE\nHERE" forState: UIControlStateNormal];
    
    
    _Profile_pic.layer.cornerRadius = 15.0f;
    _Profile_pic.clipsToBounds = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

-(void)camera_check{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Camera Error!"
                                                                       message:@"No camera detected!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"FUCK!" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)take_pic{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)choose_pic{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}


- (void)wait_for_pic:(NSTimer*)theTimer{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"Profile_pic"] == nil) {
        NSLog(@"Waiting...");
        
    }
    else {
        [DejalBezelActivityView removeViewAnimated:YES];
        [theTimer invalidate];
    }
}


#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [_face_button setTitle: @"" forState: UIControlStateNormal];
    UIImage *chosenImage = [info objectForKey:UIImagePickerControllerEditedImage];
    self.Profile_pic.image = chosenImage;
    picture_string = [self encodeToBase64String:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


- (IBAction)Edit_Profile:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"My Alert"
                                                                   message:@"Editing Profile Picture"
                                                            preferredStyle:UIAlertControllerStyleActionSheet]; // 1
    UIAlertAction *Take_pic = [UIAlertAction actionWithTitle:@"Take photo"
                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           [self camera_check];
                                                           [self take_pic];
                                                       }]; // 2
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"Choose from photo library"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               [self choose_pic];
                                                           }]; // 3
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                         NSLog(@"Cancel!");
                                                     }];
    
    [alert addAction:Take_pic]; // 4
    [alert addAction:secondAction]; // 5
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil]; // 6
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dismissKeyboard:(id)sender
{
    [self.view endEditing:YES];
}


- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImageJPEGRepresentation(image,0.8) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

- (IBAction)submit_button:(id)sender{
    NSString *unique_username = _unique_username.text;
    NSString *unique_password = _unique_pw.text;
    NSString *unique_retype = _unique_retype.text;
    NSString *unique_email = _email.text;
    

    
   if (unique_password.length <=0 || unique_retype.length <=0 || unique_username.length <= 0 || unique_email.length <=0 ){
    
        
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Input error!"
                                                                           message:@"Missing necessary information for registering a new account!"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"FUCK!" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
    }
    if (![unique_password isEqualToString:unique_retype]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Password not match!"
                                                                       message:@"Input passwords do not match!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"FUCK!" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    else if (unique_password.length < 6 || unique_password.length > 16) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Password error!"
                                                                       message:@"Password must be 6 - 16 characters long!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"FUCK!" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    else if ([unique_email rangeOfString:@"@"].location == NSNotFound || unique_email.length < 6) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Email Format Error!"
                                                                       message:@"Invalid email address format!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"FUCK!" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    else{
        NSLog(@"connecting to db!..");
        
        //Saving Users Input from Text Fields
        NSString *Username = _unique_username.text;
        NSString *Password = _unique_pw.text;
        NSString *email = _email.text;
        
        
        
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [standardUserDefaults removePersistentDomainForName:@"Plain_pw"];
        [standardUserDefaults removePersistentDomainForName:@"local_hash_pw"];
        [standardUserDefaults removePersistentDomainForName:@"User_id"];
        [standardUserDefaults removePersistentDomainForName:@"Profile_pic"];
        [standardUserDefaults removePersistentDomainForName:@"email_add"];
        [standardUserDefaults synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:Username forKey:@"User_id"];
        [[NSUserDefaults standardUserDefaults] setObject:Password forKey:@"Plain_pw"];
        [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"email_add"];
        if (picture_string == nil || picture_string.length < 1) {
            picture_string = [NSString stringWithFormat:@""];
        }
        [[NSUserDefaults standardUserDefaults] setObject:picture_string forKey:@"Profile_pic"];
        
        //NSLog(@"%@", Profile_string);
        //Generate Hash Password
        NSString *salt = [JFBCrypt generateSaltWithNumberOfRounds: 10];
        NSString *computedHash = [JFBCrypt hashPassword:Password withSalt:salt];
        NSLog(@"%@", Password);
        NSLog(@"%@", salt);
        NSLog(@"%@", computedHash);
        NSString *hashed_pw = computedHash;
        [[NSUserDefaults standardUserDefaults] setObject:hashed_pw forKey:@"local_hash_pw"];
        [standardUserDefaults synchronize];
        //JSON: GET, check DB current status, check if user name duplicated
        
        NSString *string = BaseURLString;
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:string  parameters:nil error:nil];
        
        req.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
        [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            
            if (!error) {
                //NSLog(@"Reply JSON: %@", responseObject);
                
                NSLog(@"%@", [responseObject valueForKey:@"Identification"]);
                NSArray *info_array = [responseObject valueForKey:@"Identification"];
                NSArray *pw_array = [info_array mutableArrayValueForKey:@"Password"];
                NSArray *users_array = [info_array mutableArrayValueForKey:@"Username"];
                NSInteger array_count = (unsigned long)[info_array count];
                NSLog(@"%@", users_array);
                NSLog(@"%@", pw_array);
                NSLog(@"%lu", (long)array_count);
                for (NSInteger k = 0; k < array_count; k++) {
                    NSLog(@"Username in Testing %@", [users_array objectAtIndex:k]);
                    NSLog(@"Comparing to %@", Username);
                    if([[users_array objectAtIndex:k] isEqualToString:Username]){
                        Flag = 0;
                        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Username Error!"
                                                                                       message:@"Username Duplicated!"
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"FUCK!" style:UIAlertActionStyleDefault
                                                                              handler:^(UIAlertAction * action) {}];
                        
                        [alert addAction:defaultAction];
                        [self presentViewController:alert animated:YES completion:nil];

                        return;
                    }
                }
                Flag = 1;
                NSInteger new_user_index = array_count;
                NSString *index = [NSString stringWithFormat:@"%lu", (long)new_user_index];
                [[NSUserDefaults standardUserDefaults] setObject:index forKey:@"index"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if(Flag){
                    NSLog(@"Registrating!");
                     NSDictionary *body = @{@"Identification": @{@"Username":Username,@"Password":hashed_pw,@"pic_oid":@""}};
                    
                     NSError *error = nil;
                     NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&error];
                     NSString *jsonString4 = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    NSLog(@"Dict: %@", jsonString4);
                     AFURLSessionManager *manager_post = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                     
                     NSMutableURLRequest *req_post = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:BaseURLString  parameters:nil error:nil];
                     
                     req.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
                     [req_post setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                     [req_post setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                     [req_post setHTTPBody:[jsonString4 dataUsingEncoding:NSUTF8StringEncoding]];
                     
                     [[manager_post dataTaskWithRequest:req_post completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                     
                     if (error == nil) {
                         NSArray *response_id = [responseObject valueForKey:@"_id"];
                         NSString *response_oid = [response_id valueForKey:@"$oid"];
                         [[NSUserDefaults standardUserDefaults] setObject: response_oid forKey:@"user_oid"];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                         
                         if (picture_string == nil || [picture_string  isEqualToString:@""]) {
                             body_pic = @{@"Identification":@{@"picture":@""}};
                         }
                         else{
                             body_pic = @{@"Identification":@{@"picture":picture_string}};
                         }
                         NSError *error = nil;
                         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body_pic options:0 error:&error];
                         NSString *jsonString5 = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                         AFURLSessionManager *manager_post_pic = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                         
                         NSMutableURLRequest *req_post = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:PicURLString  parameters:nil error:nil];
                         
                         req_post.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
                         [req_post setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                         [req_post setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                         [req_post addValue:@"sercert_token" forHTTPHeaderField:@"Authorization"];
                         [req_post setHTTPBody:[jsonString5 dataUsingEncoding:NSUTF8StringEncoding]];
                         NSLog(@"req_post: %@", req_post);
                         [[manager_post_pic dataTaskWithRequest:req_post completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                             if (error == nil) {
                                 NSLog(@"Profile Picture upload successed!");
                                 NSArray *temp = [responseObject valueForKey:@"_id"];
                                 NSString *pic_oid = [temp valueForKey:@"$oid"];
                                 [[NSUserDefaults standardUserDefaults] setObject:pic_oid forKey:@"pic_oid"];
                                 [[NSUserDefaults standardUserDefaults]synchronize];
                                 NSLog(@"Pic:oid = %@", pic_oid);
                                 
                                 NSDictionary *body_1 = @{@"Identification": @{@"Username":Username,@"Password":hashed_pw,@"pic_oid":pic_oid}};
                                 NSMutableString *Modified_url = [NSMutableString stringWithCapacity: 150];
                                 [Modified_url appendString: @"https://api.mlab.com/api/1/databases/jukejuke/collections/usersinfo/"];
                                 [Modified_url appendFormat: @"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user_oid"]];
                                 [Modified_url appendString: @"?apiKey=BwvONax567WvFHAlBXqQFiG0fDpJJJVF"];
                                 NSError *error = nil;
                                 NSData *jsonData_1 = [NSJSONSerialization dataWithJSONObject:body_1 options:0 error:&error];
                                 NSString *jsonString6 = [[NSString alloc] initWithData:jsonData_1 encoding:NSUTF8StringEncoding];
                                 AFURLSessionManager *manager_put = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                                 
                                 NSMutableURLRequest *req_put = [[AFJSONRequestSerializer serializer] requestWithMethod:@"PUT" URLString:Modified_url  parameters:nil error:nil];
                                 
                                 req_put.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
                                 [req_put setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                                 [req_put setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                                 [req_put addValue:@"sercert_token" forHTTPHeaderField:@"Authorization"];
                                 [req_put setHTTPBody:[jsonString6 dataUsingEncoding:NSUTF8StringEncoding]];
                                 NSLog(@"req_post: %@", req_put);
                                 [[manager_put dataTaskWithRequest:req_put completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                     if (error == nil) {
                                     }
                                     else {
                                         NSLog(@"Error: %@, %@, %@", error, response, responseObject);
                                     }
                                 }]resume];
                                 
                             }
                             else {
                                 NSLog(@"Error: %@, %@, %@", error, response, responseObject);
                             }
                         }]resume];
                     if ([responseObject isKindOfClass:[NSDictionary class]]) {
                     NSLog(@"It is a kind of class!");
                     }
                     } else {
                     NSLog(@"Error: %@, %@, %@", error, response, responseObject);
                     }
                     }] resume];
                     
                     Flag = 0;
                    
                    UITabBarController *tbc = [self.storyboard instantiateViewControllerWithIdentifier:@"tbcon"];
                    [self presentViewController:tbc animated:YES completion:nil];
                }
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    NSLog(@"It is a kind of class!");
                }
            } else {
                NSLog(@"Error: %@, %@, %@", error, response, responseObject);
            }
        }] resume];
        //JSON: POST, registering new users
        
        
        }
    
    
}











@end
