//
//  AppDelegate.m
//  wertyui
//
//  Created by Kevin Mok on 2016-10-11.
//  Copyright © 2016 Kevin Mok. All rights reserved.
//

#import "AppDelegate.h"
#import "JFBCrypt.h"
#import "AFNetworking.h"
#import "UserLoginViewController.h"

static NSString * const BaseURLString = @"https://api.mlab.com/api/1/databases/jukejuke/collections/usersinfo?apiKey=BwvONax567WvFHAlBXqQFiG0fDpJJJVF";
static NSString * const YELP_id = @"Bcmn1igLofnhQDUtzIez0w";
static NSString * const YELP_secret = @"F2qabOJRFG1CP5Zyni6RMgqOt3FIwLXWddBaeVycZQvdPmmPHQzTgyhFXh3006Ys";

@interface AppDelegate ()
//@property (strong, nonatomic) YLPClient *client;
@end

@implementation AppDelegate

/*+ (YLPClient *)sharedClient {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return appDelegate.client;
}*/

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //authenticatedUser: check from NSUserDefaults User credential if its present then set your navigation flow accordingly
    
   /* [YLPClient authorizeWithAppId:YELP_id secret:YELP_secret completionHandler:^(YLPClient *client, NSError *error) {
        self.client = client;
        if (!client) {
            NSLog(@"Authentication failed: %@", error);
        }else{
            NSLog(@"Authentication SUCCESS!");
            [self.client searchWithLocation:@"San Francisco, CA" completionHandler:^
             (YLPSearch *search, NSError *error) {
                 // Perform any tasks you need to here
                 NSLog(@"Client: %@", client);
                 NSLog(@"Error: %@", error);
             }];
        }
    }];

    */
    
    
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    //local_NSuser = nil;
    //NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    //[[NSUserDefaults standardUserDefaults] setPersistentDomain:@{@"": @""} forName:[NSBundle mainBundle].bundleIdentifier];
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@""];
    
    //NSLog(@"%@", [[NSUserDefaults standardUserDefaults] persistentDomainForName:[NSBundle mainBundle].bundleIdentifier]);
    //[standardUserDefaults synchronize];
    
    
    if (!([standardUserDefaults objectForKey:@"User_id"] == nil || [standardUserDefaults objectForKey:@"local_hash_pw"] == nil)) {
        
        
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
                NSInteger array_count = (unsigned) [info_array count];
                
                for (NSInteger k = 0; k < array_count; k++) {
                    if ([[users_array objectAtIndex:k] isEqualToString:[standardUserDefaults objectForKey:@"User_id"]]) {
                        if ([[pw_array objectAtIndex:k] isEqualToString:[standardUserDefaults objectForKey:@"local_hash_pw"]]) {
                            NSLog(@"Credential Matched!");
                                self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];                        }
                    }
                    
                }
                
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    //blah blah
                    NSLog(@"It is a kind of class!");
                }
            } else {
                NSLog(@"Error: %@, %@, %@", error, response, responseObject);
            }
        }] resume];

    }
    
    else{
        UIViewController* rootController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LoginView"];

        self.window.rootViewController = rootController;
    }

    
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
