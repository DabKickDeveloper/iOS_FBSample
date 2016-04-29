//
//  UserIdentifier.h
//  SDKSample
//
//  Created by Developer-3 on 4/28/16.
//  Copyright © 2016 Developer-3. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserIdentifier : NSObject
{
    NSString *userProfilePic;
    NSString *userName;
    NSString *uniqueID;
    NSString *email;
    NSString *phoneNumber;
   

}

@property(nonatomic) NSString *userProfilePic;
@property(nonatomic) NSString *userName;
@property(nonatomic) NSString *uniqueID;
@property(nonatomic) NSString *email;
@property(nonatomic) NSString *phoneNumber;


@end

