//
//  TweeterHomeVC.m
//  Peek_Challenge_Aditya
//
//  Created by Aditya Tanna on 12/7/15.
//  Copyright © 2015 Aditya Tanna. All rights reserved.
//

#import "TweeterHomeVC.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import "Twitter.h"
@interface TweeterHomeVC ()
{
}
@end

@implementation TweeterHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.mutArrTweets = [[NSMutableArray alloc]init];
    self.mutArrDisplayTweets = [[NSMutableArray alloc]init];
    [self.tblTweets addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTweetTable) forControlEvents:UIControlEventValueChanged];
   
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tblTweets setHidden:NO];
    [self.lblNoTweetFound setHighlighted:YES];
    [self LoadUI];
}

#pragma mark - Getting Tweets for specific username
-(void)getTweets{
    
    [self.mutArrTweets removeAllObjects];
    [self.mutArrDisplayTweets removeAllObjects];
    displayCnt = 10;
    for (NSDictionary *aDict in self.mutArrUserData) {
        
        [self.mutArrTweets addObject:[NSDictionary dictionaryWithObjectsAndKeys:[aDict objectForKey:@"text"],@"tweet",[aDict objectForKey:@"id"],@"id", nil]];
    }
    if (displayCnt >self.mutArrTweets.count) {
        displayCnt = (int) self.mutArrTweets.count;
    }
    for (int i = (int)self.mutArrDisplayTweets.count; i < displayCnt; i++) {
            [self.mutArrDisplayTweets addObject:[self.mutArrTweets objectAtIndex:i]];
    }
    [self displayTweets];
}

-(void)displayTweets{
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    if (self.mutArrDisplayTweets.count>0) {
    
        [self.tblTweets reloadData];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tblTweets setHidden:YES];
            [self.lblNoTweetFound setHidden:NO];
            if (self.mutArrUserData.count > 0) {
                  [self.lblNoTweetFound setText:[NSString stringWithFormat:@"No Tweets found for username %@",[[[self.mutArrUserData objectAtIndex:0] objectForKey:@"user"] objectForKey:@"screen_name"]]];
            }
          
        });
    }
    
    if (self.isPullToRefresh) {
        [self.refreshControl endRefreshing];
    }
}


-(void)reTweet:(NSString*) tweetId{
   
    [Twitter getTWitterDataWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/retweet/%lld.json",[tweetId longLongValue]]] withParamaters:nil withHTTPMethod:SLRequestMethodPOST :^(NSArray *array) {
    
        if ([array isKindOfClass:[NSDictionary class]] && [(NSDictionary *)array objectForKey:@"errors"]) {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:[[[(NSDictionary *)array objectForKey:@"errors"]objectAtIndex:0] objectForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                [alert show];
            });
        }else{
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Successfully Re-Tweet." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                [alert show];
            });
        }
    }];
}
#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 2020) {
        if (buttonIndex == 0) {
            NSIndexPath *indexPath = [self.tblTweets indexPathForSelectedRow];
            
           [self reTweet:[NSString stringWithFormat:@"%@",[[self.mutArrTweets objectAtIndex:indexPath.row] objectForKey:@"id"]]];
        }
    }
}
#pragma mark - PullToRefresh
-(void)refreshTweetTable{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    self.isPullToRefresh = YES;
    [self getTweets];
}

#pragma mark -Loading UI
-(void)LoadUI{
    NSString *name = [[[self.mutArrUserData firstObject] objectForKey:@"user"] objectForKey:@"name" ];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = [NSString stringWithFormat:@"%@'s Twitter",name];
    });
    
    long followers = [[[[self.mutArrUserData firstObject] objectForKey:@"user"] objectForKey:@"followers_count"] longValue];
    
    long following = [[[[self.mutArrUserData firstObject] objectForKey:@"user"] objectForKey:@"friends_count"] longValue];
    
    long tweets = [[[[self.mutArrUserData firstObject] objectForKey:@"user"]objectForKey:@"statuses_count"] longValue];
    
    NSString *profileImageStringURL = [[[self.mutArrUserData firstObject] objectForKey:@"user"]objectForKey:@"profile_image_url_https"];
    
    NSString *bannerImageStringURL =[[[self.mutArrUserData firstObject] objectForKey:@"user"] objectForKey:@"profile_banner_url"];
    
    // Update the interface with the loaded data
    self.lblTweetsCount.text = [NSString stringWithFormat:@"%ld", tweets];
    self.lblFollowingCount.text= [NSString stringWithFormat:@"%ld", following];
    self.lblFollowerCount.text = [NSString stringWithFormat:@"%ld", followers];
    
    // Get the profile image in the original resolution
    profileImageStringURL = [profileImageStringURL stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
    
    [self performSelectorInBackground:@selector(getProfileImageForURLString:) withObject:profileImageStringURL];
    
    if (bannerImageStringURL) {
        NSString *bannerURLString = [NSString stringWithFormat:@"%@/mobile_retina", bannerImageStringURL];
       [self performSelectorInBackground:@selector(getBannerImageForURLString:) withObject:bannerURLString];
        
    } else {
        self.imgBannerView.backgroundColor = [UIColor whiteColor];
    }
    [self getTweets];
}

- (void) getProfileImageForURLString:(NSString *)urlString;
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imgUserAvatar.image = [UIImage imageWithData:data];
    });
    
}

- (void) getBannerImageForURLString:(NSString *)urlString;
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imgBannerView.image = [UIImage imageWithData:data];
    });
}

#pragma mark - Table view Data source & Delegate mathods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.mutArrDisplayTweets.count == self.mutArrTweets.count){
        return self.mutArrDisplayTweets.count;
    }
    return self.mutArrDisplayTweets.count + 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (indexPath.row == self.mutArrDisplayTweets.count) {
        
        cell.textLabel.text = @"Loading more items...";
        cell.textLabel.textColor = [UIColor blueColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        
    } else {
        if (indexPath.row % 2 == 0) {
            [cell setBackgroundColor:[UIColor whiteColor]];
        }
        else {
            [cell setBackgroundColor:[UIColor lightGrayColor]];
        }
        
        cell.textLabel.numberOfLines = 0;
        CGSize maximumLabelSize = CGSizeMake(296, 9999);
        
        CGSize expectedLabelSize = [[[self.mutArrTweets objectAtIndex:indexPath.row] objectForKey:@"tweettweet"] sizeWithFont:cell.textLabel.font constrainedToSize:maximumLabelSize lineBreakMode:cell.textLabel.lineBreakMode];
        CGRect newFrame = cell.textLabel.frame;
        
        newFrame.size.height = expectedLabelSize.height;
        cell.textLabel.frame = newFrame;
        cell.textLabel.textColor = [UIColor colorWithRed:96.0/255.0 green:96.0/255.0 blue:96.0/255.0 alpha:1.0];
        cell.textLabel.text = [[self.mutArrTweets objectAtIndex:indexPath.row] objectForKey:@"tweet"];
    }
     return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.mutArrDisplayTweets.count-1) {
        [self performSelector:@selector(loadTweetsForTable) withObject:nil afterDelay:1.0];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Re-Tweet" message:@"Are you sure,You want to Re-Tweet this Tweet ?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes",@"No", nil];
    
    alert.tag = 2020;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [alert show];
    });
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str = [[self.mutArrTweets objectAtIndex:indexPath.row] objectForKey:@"tweet"];
    CGSize size = [str sizeWithFont:[UIFont fontWithName:@"Helvetica" size:17] constrainedToSize:CGSizeMake(280, 999) lineBreakMode:NSLineBreakByWordWrapping];
    return size.height + 10;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.mutArrTweets removeObjectAtIndex:indexPath.row];
        [self.tblTweets reloadData];
    }
}

- (void)loadTweetsForTable{
    displayCnt = displayCnt+10;
    if (displayCnt > self.mutArrTweets.count) {
        displayCnt = (int)self.mutArrTweets.count;
    }
    for (int i = (int)self.mutArrDisplayTweets.count; i < displayCnt; i++) {
        [self.mutArrDisplayTweets addObject:[self.mutArrTweets objectAtIndex:i]];
    }
    
    [self.tblTweets reloadData];
}
@end