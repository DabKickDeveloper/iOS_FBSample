//
//  ViewController.m
//  SDKSample
//
//  Created by Developer-3 on 4/26/16.
//  Copyright © 2016 Developer-3. All rights reserved.
//

#import "ViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "SelectVideoViewController.h"
#import "UserInfo.h"
#import "UserIdentifier.h"



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
    
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    
    loginButton.readPermissions =
    @[@"public_profile", @"email", @"user_friends"];
    
    loginButton.center = self.view.center;
    
    loginButton.delegate = self;
    
    [self.view addSubview:loginButton];
    
    
}


-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    
    NSLog(@"fb login");
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 
                 NSString *fbID = [result objectForKey:@"id"];
                 NSLog(@"get fb id:%@",fbID);
                
                 NSString *fbName = [result objectForKey:@"name"];
                 NSLog(@"get fb name:%@",fbName);
                 
                 //get my profile pic
                 [self getProfilePic:fbID withCallback:^(bool success, id imageURL) {
                     
                     UserIdentifier *user = [[UserIdentifier alloc]init];
                     user.uniqueID = fbID;
                     user.userName = fbName;
                     user.userProfilePic = imageURL;
                     
                     if(success)
                     {
                         //get facebook friend list
                         [self getFriendList:fbID withCallBack:^(bool success, NSArray *friendList) {
                             
                             NSMutableArray *list = [[NSMutableArray alloc]init];
                             for (NSDictionary *obj in friendList) {
                                 UserInfo *userInfo = [[UserInfo alloc]init];
                                 userInfo.name = [obj objectForKey:@"name"];
                                 userInfo.uniqueID = [obj objectForKey:@"id"];
                                 
                                 //get friend's profile pic
                                 [self getProfilePic:userInfo.uniqueID withCallback:^(bool success, NSString *imageURL) {
                                    if(success)
                                    {
                                        userInfo.imageURL = imageURL;
                                    }
                                 }];
                                 
                                 [list addObject:userInfo];
                             }
                             
                             NSLog(@"friend list : %@",list);
                             
                             SelectVideoViewController *controller = [[SelectVideoViewController alloc]init];
                             controller.myName = fbName;
                             controller.myProfileImage = imageURL;
                             controller.friendList = list;
                             [self presentViewController:controller animated:true completion:nil];
                         }];
                         
                         
                     }
                 }];
                 
                 
             }
         }];
    }
    
    
    
    
}

-(void)getProfilePic:(NSString *)fbID withCallback:(void(^)(bool success,NSString* imageURL))callback
{
    NSString *url = [NSString stringWithFormat:@"/%@",fbID];
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:url
                                  parameters:@{@"fields": @"picture"}
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        
        NSLog(@"get get profile pic result %@", result);
        
        if(!error)
        {
            NSString *imageURL = [[[result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
            
            NSLog(@"get profile imageURL %@", imageURL);
            
            if (callback) {
                callback(true,imageURL);
            }
        }
        else{
            if(callback)
                callback(false,nil);
        }
        
        
    }];
    
    
}

-(void)getFriendList:(NSString*) fbID withCallBack:(void(^)(bool success, NSArray* friendList))callback
{
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"/me/friends"
                                  parameters:@{@"fields": @""}
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        // Handle the result
        
        //NSLog(@"get friend list %@", result);
        
        NSArray *list = [result objectForKey:@"data"];
        
        if (callback) {
            if (!error) {
                callback(true,list);
            }
            else
                callback(false,nil);
        }
    }];
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    NSLog(@"fb logout");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
