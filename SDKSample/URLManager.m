//
//  URLManager.m
//  SDKSample
//
//  Created by Developer-3 on 5/13/16.
//  Copyright © 2016 Developer-3. All rights reserved.
//

#import "URLManager.h"

@implementation URLManager
{
    NSString *serverURL;
    NSString *scriptURL;

}

@synthesize dabfriend_sendPush;
@synthesize sampleAppRegisterUser;

+ (id)sharedManager {
    static URLManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (URLManager*) init{
    
    //Base url
    serverURL = @"http://stagingquery.dabkick.com";
    scriptURL = [self makeURL:serverURL append:@"iOS/SDK/sampleApp"];
    
    //script url
    dabfriend_sendPush = [self makeURL:scriptURL append:@"dabfriend_sendPush.php"];
    sampleAppRegisterUser = [self makeURL:scriptURL append:@"sampleAppRegisterUser.php"];
    
    return self;
}

-(NSString*)makeURL:(NSString*)baseURL append:(NSString*)scriptPath
{
    return [NSString stringWithFormat:@"%@/%@",baseURL,scriptPath];
}



@end
