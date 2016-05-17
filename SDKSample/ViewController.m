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
#import "AFNetworking.h"
#import "SelectVideoViewController.h"
#import "URLManager.h"

#import <DabkickSDK/DabkickSDK.h>


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
    
    
    if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"facebook login in before");
        [self getFBInfoAndSetup];
    }
    else
        [self.view addSubview:loginButton];
    
    
}

-(void)getFBInfoAndSetup{
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             
             NSString *fbID = [result objectForKey:@"id"];
             NSLog(@"get fb id:%@",fbID);
             
             NSString *fbName = [result objectForKey:@"name"];
             NSLog(@"get fb name:%@",fbName);
             
             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
             NSString *token = [defaults objectForKey:@"token"];
             NSString *devID = [[NSUUID UUID] UUIDString];
             
             //register sample app user
             [self registerSampleApp:token withDeviceID:devID withName:fbName withPassword:fbID withUniqueID:fbID withCallBack:^(bool success, NSString *userID, NSString *userName) {
                 if(success)
                 {
                     //get my profile pic
                     [self getProfilePic:fbID withCallback:^(bool success, id imageURL) {
                         
                         UserInfo *user = [[UserInfo alloc]init];
                         user.uniqueID = fbID;
                         user.userName = fbName;
                         user.userProfilePic = imageURL;
                         
                         [DabKick Register:@"com.dabkick.partner.fb.production" withUserInfo:user];
                         
                         if(success)
                         {
                             //get facebook friend list
                             [self getFriendList:fbID withCallBack:^(bool success, NSArray *friendList) {
                                 
                                 NSMutableArray *list = [[NSMutableArray alloc]init];
                                 for (NSDictionary *obj in friendList) {
                                     UserInfo *userInfo = [[UserInfo alloc]init];
                                     userInfo.userName = [obj objectForKey:@"name"];
                                     userInfo.uniqueID = [obj objectForKey:@"id"];
                                     
                                     //get friend's profile pic
                                     [self getProfilePic:userInfo.uniqueID withCallback:^(bool success, NSString *imageURL) {
                                         if(success)
                                         {
                                             userInfo.userProfilePic = imageURL;
                                         }
                                     }];
                                     
                                     [list addObject:userInfo];
                                 }
                                 
                                 //NSLog(@"friend list : %@",list);
                                 
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
     }];
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    
    NSLog(@"fb login");
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [self getFBInfoAndSetup];
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
        
        //NSLog(@"get get profile pic result %@", result);
        
        if(!error)
        {
            NSString *imageURL = [[[result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
            
            //NSLog(@"get profile imageURL %@", imageURL);
            
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

-(void)registerSampleApp:(NSString*)token withDeviceID:(NSString*)deviceID withName:(NSString*)name withPassword:(NSString*)password withUniqueID:(NSString*)uniqueID withCallBack:(void(^)(bool success, NSString* userID, NSString *userName))callback
{
    NSDictionary *param = @{@"token": token, @"devid": deviceID, @"name":name, @"uniqueID":uniqueID, @"password":password};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:[[URLManager sharedManager] sampleAppRegisterUser] parameters:param progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSDictionary *dic = (NSDictionary*)responseObject;
        NSLog(@"register sample app user JSON: %@", dic);
        bool success = [responseObject objectForKey:@"result"];
        
        if (success) {
            
            NSString *userID = [responseObject objectForKey:@"userID"];
            NSString *userName = [responseObject objectForKey:@"name"];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:userID forKey:@"userID"];
            [defaults setObject:userName forKey:@"userName"];
            
            callback(true,userID,userName);
        }
        else{
            callback(false,nil,nil);
        }
        
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


@end
