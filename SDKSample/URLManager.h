//
//  URLManager.h
//  SDKSample
//
//  Created by Developer-3 on 5/13/16.
//  Copyright © 2016 Developer-3. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLManager : NSObject
{
    NSString *dabfriend_sendPush;
    NSString *sampleAppRegisterUser;
}

+ (id)sharedManager;
-(NSString*)makeURL:(NSString*)baseURL append:(NSString*)scriptPath;

@property (nonatomic) NSString *dabfriend_sendPush;
@property (nonatomic) NSString *sampleAppRegisterUser;

@end
