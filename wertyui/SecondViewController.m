//
//  SecondViewController.m
//  wertyui
//
//  Created by Kevin Mok on 2016-10-11.
//  Copyright © 2016 Kevin Mok. All rights reserved.
//

#import "SecondViewController.h"
#import "AppDelegate.h"
#import "UserLoginViewController.h"
#import "AFNetworking.h"
#import "DejalActivityView.h"

static NSString * const BaseURLString = @"https://api.mlab.com/api/1/databases/jukejuke/collections/usersinfo?apiKey=BwvONax567WvFHAlBXqQFiG0fDpJJJVF";

NSString *pic_temp = nil;

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self init_];
    
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
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"Profile_pic"] == pic_temp) {
        NSLog(@"Waiting...");
        
    }
    else {
        [DejalBezelActivityView removeViewAnimated:YES];
        [theTimer invalidate];
    }
}


#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Uploading image..."].showNetworkActivityIndicator = YES;
    UIImage *chosenImage = [info objectForKey:UIImagePickerControllerEditedImage];
    self.Profile_pic.image = chosenImage;
    NSString *picture_string = [self encodeToBase64String:chosenImage];
    NSMutableString *Modified_url = [NSMutableString stringWithCapacity: 150];
    [Modified_url appendString: @"https://api.mlab.com/api/1/databases/jukejuke/collections/pictures/"];
    [Modified_url appendFormat: @"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"pic_oid"]];
    [Modified_url appendString: @"?apiKey=BwvONax567WvFHAlBXqQFiG0fDpJJJVF"];
    //NSLog(@"%@", Modified_url);
    
    NSDictionary *body = @{@"Identification": @{@"picture":picture_string}};
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&error];
    NSString *jsonString4 = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    AFURLSessionManager *manager_post = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *req_post = [[AFJSONRequestSerializer serializer] requestWithMethod:@"PUT" URLString:Modified_url  parameters:nil error:nil];
    //NSLog(@"changing picture!!");
    req_post.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
    [req_post setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req_post setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req_post setHTTPBody:[jsonString4 dataUsingEncoding:NSUTF8StringEncoding]];
    [[manager_post dataTaskWithRequest:req_post completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"%@", responseObject);
        NSMutableDictionary *response_json = [[responseObject valueForKey:@"Identification"]mutableCopy];
        NSString *pic_string = [response_json valueForKey:@"picture"];
        NSMutableDictionary *response_oid = [[responseObject valueForKey:@"_id"]mutableCopy];
        NSString *pic_oid_string = [response_oid valueForKey:@"$oid"];
        NSLog(@"%@", pic_oid_string);
        pic_temp = [[NSUserDefaults standardUserDefaults] objectForKey:@"Profile_pic"];
        [[NSUserDefaults standardUserDefaults] setObject:pic_string forKey:@"Profile_pic"];
        [[NSUserDefaults standardUserDefaults] setObject:pic_oid_string forKey:@"pic_oid"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [NSTimer scheduledTimerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(wait_for_pic:)
                                       userInfo:nil repeats:YES];
        if (error == nil) {
        } else {
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];

    
    
    
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
    
    
    
   /* NSMutableString *Modified_url = [NSMutableString stringWithCapacity: 150];
    [Modified_url appendString: @"https://api.mlab.com/api/1/databases/jukejuke/collections/pictures/"];
    [Modified_url appendFormat: @"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user_oid"]];
    [Modified_url appendString: @"?apiKey=BwvONax567WvFHAlBXqQFiG0fDpJJJVF"];
    NSLog(@"%@", Modified_url);
    
    NSDictionary *body = @{@"Identification": @{@"Username":@"bob",@"Password":@"bob"}};
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&error];
    NSString *jsonString4 = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"Dict: %@", jsonString4);
    AFURLSessionManager *manager_post = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *req_post = [[AFJSONRequestSerializer serializer] requestWithMethod:@"PUT" URLString:Modified_url  parameters:nil error:nil];
    
    req_post.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
    [req_post setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req_post setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req_post setHTTPBody:[jsonString4 dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[manager_post dataTaskWithRequest:req_post completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (error == nil) {
                    } else {
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
    */
   
}



- (void) init_ {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    _User.text = [standardUserDefaults objectForKey:@"User_id"];
    //NSLog(@"NSDATA: %@", [standardUserDefaults objectForKey:@"Profile_pic"]);
    
    if ([[standardUserDefaults objectForKey:@"Profile_pic"] isEqualToString:@""]) {
        UIImage *profile_pic = [UIImage imageNamed: @"man-303792_960_720.png"];
        NSString *Profile_string = [self encodeToBase64String:profile_pic];
        _Profile_pic.image = [self decodeBase64ToImage:Profile_string];
    }
    else{
    NSString *Profile_string = [standardUserDefaults objectForKey:@"Profile_pic"];
    _Profile_pic.image = [self decodeBase64ToImage:Profile_string];
    }
    _Profile_pic.layer.cornerRadius = 25.0f;
    _Profile_pic.clipsToBounds = YES;
    
}

- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImageJPEGRepresentation(image,0.8) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Logout_Button:(id)sender {
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:@{@"": @""} forName:[NSBundle mainBundle].bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@""];
    
    //NSLog(@"%@", [[NSUserDefaults standardUserDefaults] persistentDomainForName:[NSBundle mainBundle].bundleIdentifier]);
    [standardUserDefaults synchronize];
    
    if (!([standardUserDefaults objectForKey:@"User_id"] == nil || [standardUserDefaults objectForKey:@"local_hash_pw"] == nil)) {
    
        NSLog(@"standardUserDefaults has not been cleared!");
        NSLog(@"%@", [standardUserDefaults objectForKey:@"Plain_pw"]);
        NSLog(@"%@", [standardUserDefaults objectForKey:@"local_hash_pw"]);
        NSLog(@"%@", [standardUserDefaults objectForKey:@"User_id"]);
    
    
    }
    
    
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UserLoginViewController *initView =  (UserLoginViewController*)[storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
    [initView setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:initView animated:YES completion:nil];

    
    
  }

@end
