//
//  TweeterHomeVC.h
//  Peek_Challenge_Aditya
//
//  Created by Aditya Tanna on 12/7/15.
//  Copyright © 2015 Aditya Tanna. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TweeterHomeVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    int displayCnt;
}

@property (strong, nonatomic) IBOutlet UIImageView *imgUserAvatar;
@property (strong, nonatomic) IBOutlet UIImageView *imgBannerView;
@property (weak, nonatomic) IBOutlet UILabel *lblNoTweetFound;

@property (nonatomic,assign) BOOL isPullToRefresh;

@property (strong, nonatomic) NSMutableArray *mutArrUserData;
@property (strong, nonatomic) NSMutableArray *mutArrTweets;
@property (strong, nonatomic) NSMutableArray *mutArrDisplayTweets;

@property (strong, nonatomic) IBOutlet UITableView *tblTweets;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) IBOutlet UILabel *lblFollower;
@property (strong, nonatomic) IBOutlet UILabel *lblFollowerCount;
@property (strong, nonatomic) IBOutlet UILabel *lblFollowing;
@property (strong, nonatomic) IBOutlet UILabel *lblFollowingCount;
@property (strong, nonatomic) IBOutlet UILabel *lblTweets;
@property (strong, nonatomic) IBOutlet UILabel *lblTweetsCount;

@end
