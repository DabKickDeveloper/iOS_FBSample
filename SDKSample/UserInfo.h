//
//  UserInfo.h
//  SDKSample
//
//  Created by Developer-3 on 4/28/16.
//  Copyright © 2016 Developer-3. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject
{
    NSString *uniqueID;
    NSString *imageURL;
    NSString *name;
}

@property(nonatomic) NSString *uniqueID;
@property(nonatomic) NSString *imageURL;
@property(nonatomic) NSString *name;

@end
