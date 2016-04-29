//
//  SelectVideoViewController.h
//  SDKSample
//
//  Created by Developer-3 on 4/27/16.
//  Copyright © 2016 Developer-3. All rights reserved.
//

#import "ViewController.h"
#import "EasyTableView.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SelectVideoViewController : UIViewController <FBSDKLoginButtonDelegate,EasyTableViewDelegate>

@property(nonatomic) NSString *myName;
@property(nonatomic) NSString *myProfileImage;
@property(nonatomic) NSMutableArray *friendList;

@end
