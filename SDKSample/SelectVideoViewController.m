//
//  SelectVideoViewController.m
//  SDKSample
//
//  Created by Developer-3 on 4/27/16.
//  Copyright © 2016 Developer-3. All rights reserved.
//

#import "SelectVideoViewController.h"
#import "ViewController.h"
#import "VideoDetail.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AFNetworking/AFURLRequestSerialization.h>
#import <AFNetworking/AFHTTPSessionManager.h>

#define IMAGE_VIEW_TAG	100
#define LABEL_TAG		101

@implementation SelectVideoViewController
{
    EasyTableView *horizontalView;
    NSMutableArray *youtubeVideos;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
    
    
    [self createThisView];
}

- (void)createThisView{
    UILabel *step1 = [[UILabel alloc]init];
    step1.text = @"Step 1. Partner app is connected to DabKick";
    step1.textColor = [UIColor blackColor];
    step1.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    
    [step1 setFrame:CGRectMake(15, 30, self.view.frame.size.width, 50)];
    [step1 adjustsFontSizeToFitWidth];
    step1.numberOfLines = 0;
    [self.view addSubview:step1];
    
    UIImageView *profilePic = [[UIImageView alloc]init];
    [profilePic setFrame:CGRectMake(15, 90, 80, 80)];
    profilePic.backgroundColor = [UIColor blackColor];
    profilePic.layer.cornerRadius = profilePic.frame.size.width / 2;
    profilePic.clipsToBounds = YES;
    [self.view addSubview:profilePic];
    
    NSURL *url = [[NSURL alloc]initWithString:_myProfileImage];
    
    [profilePic sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
    UILabel *myName = [[UILabel alloc]init];
    myName.text = _myName;
    myName.textColor = [UIColor blackColor];
    myName.font = [UIFont fontWithName:@"Helvetica" size:20.0];
    [myName setFrame:CGRectMake(105, 100, self.view.frame.size.width, 50)];
    [self.view addSubview:myName];
    
    UILabel *step2 = [[UILabel alloc]init];
    step2.text = @"Step 2. Tap a video to preview it";
    step2.textColor = [UIColor blackColor];
    step2.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    
    [step2 setFrame:CGRectMake(15, 200, self.view.frame.size.width, 50)];
    [step2 adjustsFontSizeToFitWidth];
    step2.numberOfLines = 0;
    [self.view addSubview:step2];
    
    //setup horizontal table view
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    CGRect frameRect	= CGRectMake(0, 260, screenSize.width, 110);
    EasyTableView *view	= [[EasyTableView alloc] initWithFrame:frameRect ofWidth:120];
    horizontalView = view;
    
    horizontalView.delegate	= self;
    horizontalView.tableView.backgroundColor = [UIColor clearColor];
    horizontalView.tableView.allowsSelection = YES;
    horizontalView.tableView.separatorColor	= [UIColor darkGrayColor];
    horizontalView.autoresizingMask	= UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:horizontalView];
    
    //load video from youtube
    youtubeVideos = [[NSMutableArray alloc]init];
    
    NSString *youtubeURL = @"https://www.googleapis.com/youtube/v3/search";
    NSDictionary *param = @{@"part": @"snippet", @"type": @"video", @"maxResults": @"25", @"q":@"funnyordie",@"key":@"AIzaSyCEc7GPSj9CRZJkj1r7hQpnCCMVOhhHnYY"};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:youtubeURL parameters:param progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        [youtubeVideos removeAllObjects];
        NSArray *videos = [responseObject objectForKey:@"items"];
        for (NSDictionary *obj in videos) {
            VideoDetail *videoDetail = [[VideoDetail alloc]init];
            videoDetail.videoID = [[obj objectForKey:@"id"] objectForKey:@"videoId"];
            videoDetail.title = [[obj objectForKey:@"snippet"] objectForKey:@"title"];
            videoDetail.imageURL = [[[[obj objectForKey:@"snippet"] objectForKey:@"thumbnails"] objectForKey:@"default"] objectForKey:@"url"];
            
            [youtubeVideos addObject:videoDetail];
        }
        [horizontalView reload];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    //facebook logout button
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.readPermissions =
    @[@"public_profile", @"email", @"user_friends"];
    
    [loginButton setFrame:CGRectMake((self.view.frame.size.width-120)/2, self.view.frame.size.height-50, 120, 30)];
    
    loginButton.delegate = self;
    
    [self.view addSubview:loginButton];
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    NSLog(@"fb logout");
    ViewController *vc = [[ViewController alloc]init];
    [self presentViewController:vc animated:false completion:nil];
    
}


-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    
    NSLog(@"fb login");
    
}

- (NSInteger)easyTableView:(EasyTableView *)easyTableView numberOfRowsInSection:(NSInteger)section
{
    return [youtubeVideos count];
}

- (UITableViewCell *)easyTableView:(EasyTableView *)easyTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"horizontalCell";
    UITableViewCell *cell = [easyTableView.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UILabel *label;
    UIImageView *imageView;
    
    if (cell == nil) {
        // Create a new table view cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor whiteColor];
        
        UIImageView *imageView = [[UIImageView alloc]init];
        [imageView setTag:IMAGE_VIEW_TAG];
        [imageView setFrame:CGRectMake(10, 0, 100, 70)];
        [cell.contentView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc]init];
        [label setTag:LABEL_TAG];
        [label setFrame:CGRectMake(10, 75, 100, 40)];
        label.numberOfLines = 2;
        label.font = [UIFont fontWithName:@"Helvetica" size:12.0];
        
        [cell.contentView addSubview:label];
    }
    
    imageView = [cell.contentView viewWithTag:IMAGE_VIEW_TAG];
    label = [cell.contentView viewWithTag:LABEL_TAG];
    
    VideoDetail *detail = [youtubeVideos objectAtIndex:indexPath.row];
    [imageView sd_setImageWithURL:[[NSURL alloc] initWithString:detail.imageURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
    
    label.text = detail.title;
    
    return cell;
}


@end


