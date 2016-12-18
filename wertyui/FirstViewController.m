//
//  FirstViewController.m
//  wertyui
//
//  Created by Kevin Mok on 2016-10-11.
//  Copyright © 2016 Kevin Mok. All rights reserved.
//

#import "FirstViewController.h"
#import "JFBCrypt.h"
#import "AFNetworking.h"
#import "UserLoginViewController.h"
NSDictionary *dic;
//NSString *id_unique = @"Kevin_Test";
//NSString *pw_unique = nil;
//NSString *entries = nil;

//APIKey -> BwvONax567WvFHAlBXqQFiG0fDpJJJVF
//Google API -> AIzaSyAgespCTcX31EN7jSgDXxXNweirIGGQBbQ
//Google place API -> AIzaSyACCe6jNp40TvvDLuXKWF2Qw2ssqRBBjx0

//static NSString * const BaseURLString = @"https://api.mlab.com/api/1/databases/jukejuke/collections/usersinfo?apiKey=BwvONax567WvFHAlBXqQFiG0fDpJJJVF";




static NSString * const PicURLString = @"https://api.mlab.com/api/1/databases/jukejuke/collections/pictures?q={5810f78ebd966f3409203ccb}&apiKey=BwvONax567WvFHAlBXqQFiG0fDpJJJVF";



@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)getpicture{
    
    NSMutableString *Modified_url = [NSMutableString stringWithCapacity: 150];
    [Modified_url appendString: @"https://api.mlab.com/api/1/databases/jukejuke/collections/pictures?sk="];
    [Modified_url appendFormat: @"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"index"]];
    [Modified_url appendString: @"&l=1&apiKey=BwvONax567WvFHAlBXqQFiG0fDpJJJVF"];
    NSLog(@"%@", Modified_url);
    
    NSURL *URL = [NSURL URLWithString:Modified_url];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:URL.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSMutableDictionary *response = [[[responseObject valueForKey:@"Identification"] objectAtIndex:0]mutableCopy];
        NSString *pic_string = [response valueForKey:@"picture"];
        [[NSUserDefaults standardUserDefaults] setObject:pic_string forKey:@"Profile_pic"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}



/*-(NSString *)getFormDataStringWithDictParams:(NSDictionary *)aDict
{
    NSMutableString *aMutStr = [[NSMutableString alloc]initWithString:@""];
    for (NSString *aKey in aDict.allKeys) {
        [aMutStr appendFormat:@"%@=%@&",aKey,aDict[aKey]];
    }
    NSString *aStrParam;
    if (aMutStr.length>2) {
        aStrParam = [aMutStr substringWithRange:NSMakeRange(0, aMutStr.length-1)];
        
    }
    else
        aStrParam = @"";
    
    return aStrParam;
}
*/




- (IBAction)Hashpw:(id)sender{
 
/*    NSString *salt = @"$2a$10$3hxMOsDqLUoZKqI39D41b.";//[JFBCrypt generateSaltWithNumberOfRounds: 10];
    NSString *password = @"bob";
    NSString *computedHash = [JFBCrypt hashPassword:password withSalt:salt];
    NSLog(@"%@", password);
    NSLog(@"%@", salt);
    NSLog(@"%@", computedHash);
    pw_unique = computedHash;*/
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:@{@"": @""} forName:[NSBundle mainBundle].bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@""];
    
    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] persistentDomainForName:[NSBundle mainBundle].bundleIdentifier]);
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

-(IBAction)Reset:(id)sender{
    [self getpicture];
}

- (IBAction)POSTJSON:(id)sender{

NSString *request = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@",_PostalcodeText.text];

    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:request  parameters:nil error:nil];
    
    req.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            NSDictionary *result = [[responseObject valueForKey:@"results"]objectAtIndex:0];
            NSArray *location_info = [result valueForKey:@"geometry"];
            NSArray *lat_lng = [location_info valueForKey:@"location"];
            NSString *lataddr = [lat_lng valueForKey:@"lat"];
            NSString *longaddr = [lat_lng valueForKey:@"lng"];
            
            NSLog(@"The resof latitude=%@", lataddr);
            NSLog(@"The resof longitude=%@", longaddr);
        } else {
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];





}
- (IBAction)CALLJSON:(id)sender{
}
    // 1
/*    NSString *string = BaseURLString;
        

        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:string  parameters:nil error:nil];
        
        req.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
        [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            
            if (!error) {
                NSLog(@"Reply JSON: %@", responseObject);
                entries = [NSString stringWithFormat: @"%ld",(long)[responseObject count]];
                NSLog(@"%@", [responseObject valueForKey:@"Identification"]);
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    //blah blah
                    NSLog(@"It is a kind of class!");
                }
            } else {
                NSLog(@"Error: %@, %@, %@", error, response, responseObject);
            }
        }] resume];
        
        
        
        
        
        
        */
        
        
        
        
        
        //NSData *jsondata = [NSJSONSerialization JSONObjectWithData:responseObject
                                                            // options:kNilOptions
                                                            //   error:&error];
        
        //NSLog(@"%@",json);
        
        
        //NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject
        //                                                     options:kNilOptions
         //                                                      error:&error];
     //   NSLog(@"%@", [json allKeys]);
        /*NSArray *db_collection_ID = [json allKeys];
        NSInteger last_array_entries = [db_collection_ID count];
       
        
        NSString *last_entries = [db_collection_ID objectAtIndex:last_array_entries];
        
        NSLog(@"%@", last_entries);*/
        
        


        
        
        
/*        NSString *targetKey = nil;
        NSArray *allKeys = [dic allKeys];
        for (int i = 0; i < [allKeys count]; ++i) {
            NSString *key = [allKeys objectAtIndex:i];
            NSString *obj = [dic objectForKey:key];
            if ([obj isEqualToString:searchedString]) { // searchedString is what you're looking for
                targetKey = key;
                break;
            }
        }

  */
   //     NSLog(@"Test String %@", [info objectAtIndex:1]);
       // NSLog(@"%@",[json objectForKey:@"ID"] );
        //NSLog(@"Dictionary: %@", dic);
       /*NSArray *password = [dic objectForKey:@"password"];
        NSString *str1 = [password objectAtIndex:1];
        NSLog(@"Test String: %@", str1);
        int count=0;*/
    
        
    
    
    
    
    
     
   /*  for (NSDictionary *dict in [dic objectForKey:@"users"]) {
     // Some code to start the download.
     
     // NSLog(@"%d", count);
     
     if(count==1){
     NSString *pw = [dict valueForKey:@"password"];
     NSLog(@"%@", pw);
     }
     count++;
     }
     */
    
    
    // 5
    




@end
