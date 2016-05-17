//
//  VideoPlayerController.m
//  SDKSample
//
//  Created by Developer-3 on 5/11/16.
//  Copyright © 2016 Developer-3. All rights reserved.
//

#import "VideoPlayerController.h"
#import <AFNetworking/AFURLRequestSerialization.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import <MediaPlayer/MediaPlayer.h>
#import <DabkickSDK/DabkickSDK.h>
#import "URLManager.h"


@interface VideoPlayerController ()
{
    UIActivityIndicatorView *indicator;
    MPMoviePlayerController *theMoviPlayer;
    
}

@end

@implementation VideoPlayerController

static NSInteger watchWithFriend = 100;

- (void)viewDidLoad {
    // Do any additional setup after loading the view.

    [self createThisView];
    
    [indicator startAnimating];
    
    NSString *url = [NSString stringWithFormat:@"http://decrypt.dabkick.com/getDecryptedStreamURL_v65.php?vid=%@",[self currentVideo].videoID];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSLog(@"response: %@", responseObject);
        
        NSArray *array = (NSArray*)responseObject;
        NSDictionary *dic = [array objectAtIndex:0];
        NSString *streamURL = [dic objectForKey:@"streamURL"];
        NSLog(@"get video stream url: %@", streamURL);
        
        if (!streamURL) {
            [self dismissViewControllerAnimated:NO completion:nil];
            return;
        }
        
        _currentVideo.streamURL = streamURL;
        
        //show watch with friend button
        UIButton *watchWithFriendBtn = [self.view viewWithTag:watchWithFriend];
        watchWithFriendBtn.hidden = false;
        
        [theMoviPlayer setContentURL:[NSURL URLWithString:streamURL]];
        [theMoviPlayer play];
        
        
        [indicator stopAnimating];
        
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    
}

- (void)createThisView{
    
    self.view.backgroundColor = [UIColor blackColor];
    
    theMoviPlayer = [[MPMoviePlayerController alloc] init];
    theMoviPlayer.controlStyle = MPMovieControlStyleFullscreen;
    theMoviPlayer.view.transform = CGAffineTransformConcat(theMoviPlayer.view.transform, CGAffineTransformMakeRotation(M_PI_2));
    [theMoviPlayer.view setFrame:self.view.frame];
    [self.view addSubview:theMoviPlayer.view];
    
    //detect player done button is click
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doneButtonClick:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    //add the progress spinner
    indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(0.0, 0.0, 80.0, 80.0);
    indicator.center = self.view.center;
    indicator.color = [UIColor whiteColor];
    [self.view addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    
    //make the watch with friend button
    UIButton *watchTogether = [[UIButton alloc]initWithFrame:CGRectMake(5, 20, 70, 50)];
    watchTogether.layer.cornerRadius = 5;
    watchTogether.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:10.0];;
    [watchTogether setTitle:@"watch with\nfriends" forState:UIControlStateNormal];
    watchTogether.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    watchTogether.titleLabel.textAlignment = NSTextAlignmentCenter;
    watchTogether.titleLabel.textColor = [UIColor whiteColor];
    watchTogether.layer.borderColor = [[UIColor whiteColor] CGColor];
    watchTogether.layer.borderWidth = 1;
    watchTogether.backgroundColor = Rgb2UIColor(226, 4, 28);;
    watchTogether.transform = CGAffineTransformConcat(watchTogether.transform, CGAffineTransformMakeRotation(M_PI_2));
    watchTogether.tag = watchWithFriend;
    watchTogether.hidden = true;
    [watchTogether addTarget:self action:@selector(watchTogetherOnClick:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:watchTogether];
    
}

-(void)watchTogetherOnClick:(UIButton *)sender
{
    NSLog(@"on click watch with friend");
    NSMutableArray *videoList = [[NSMutableArray alloc]init];
    NSMutableArray *friendList = _friendList;
    
    VideoMessage *videoMessage = [[VideoMessage alloc]init];
    videoMessage.videoTitle = _currentVideo.title;
    videoMessage.videoDesc = _currentVideo.description;
    videoMessage.videoPlayURL = _currentVideo.streamURL;
    videoMessage.videoImageURL = _currentVideo.imageURL;
    videoMessage.videoID = _currentVideo.videoID;
    videoMessage.videoType = DABKICK_VIDEO_YOUTUBE;
    
    [videoList addObject:videoMessage];

    [DabKick watchWithFriends:self withVideoList:videoList withFriendList:friendList sucess:^(ChooseFriendRespond *respond) {
        NSLog(@"watch with friend callback success userName:%@ userID:%@ sessionID:%@",respond.userInfo.userName, respond.userInfo.uniqueID,respond.sessionID);
        
        NSDictionary *param = @{@"userID": respond.userInfo.uniqueID, @"sessionID": respond.sessionID};
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        [manager GET:[[URLManager sharedManager] dabfriend_sendPush]  parameters:param progress:nil success:^(NSURLSessionTask *task, id responseObject) {

            NSLog(@"notification send out");
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
    } failure:^(ChooseFriendRespond *respond, NSError *error) {
        NSLog(@"userName: %@ Error: %@",respond.userInfo.userName, error);
    }];
    
}

-(void)doneButtonClick:(NSNotification*)aNotification{
    
    NSNumber *reason = [aNotification.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    if ([reason intValue] == MPMovieFinishReasonUserExited) {
        // Your done button action here
        NSLog(@"player done button click");
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
