//
//  VideoPlayerController.h
//  SDKSample
//
//  Created by Developer-3 on 5/11/16.
//  Copyright © 2016 Developer-3. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoDetail.h"

#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

@interface VideoPlayerController : UIViewController

@property(nonatomic) VideoDetail *currentVideo;
@property(nonatomic) NSMutableArray *friendList;

@end
