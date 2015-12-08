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
@interface TweeterHomeVC ()
{
    ACAccountStore *Store;
    ACAccountType *AccountType;
    ACAccount *Account;
}
@end

@implementation TweeterHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tblTweets addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTweetTable) forControlEvents:UIControlEventValueChanged];
    
    Store = [[ACAccountStore alloc]init];
    AccountType = [Store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    Account = [[Store accountsWithAccountType:AccountType] lastObject];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.mutArrTweets = nil;
    self.mutArrTweets = [[NSMutableArray alloc]init];
    
    [self.tblTweets setHidden:NO];
    [self.lblNoTweetFound setHighlighted:YES];
    
    [self LoadUI];
}

#pragma mark - Getting Tweets for specific username
-(void)getTweets{
    [self.mutArrTweets removeAllObjects];
    
    [Store requestAccessToAccountsWithType:AccountType options:nil completion:^(BOOL granted, NSError *error) {
        
    NSString *aStrScreenName = [NSString stringWithFormat:@"%@",[(NSDictionary *)self.mutArrUserData objectForKey:@"screen_name"]];
        
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=%@",aStrScreenName]];
        
    SLRequest *aRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:requestURL parameters:nil];
        
    [aRequest setAccount:Account];
        
    [aRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            
        if (error) {
            NSLog(@"Error: %@",error.description);
        }
        else{

            NSArray *array = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil];
                
            for (NSDictionary *aDict in array) {
                [self.mutArrTweets addObject:[NSDictionary dictionaryWithObjectsAndKeys:[aDict objectForKey:@"text"],@"tweet",[aDict objectForKey:@"id"],@"id", nil]];
            }
            [self displayTweets];
        }
    }];
    }];
}
-(void)displayTweets{
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    if ([self.mutArrTweets count]>0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tblTweets reloadData];
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tblTweets setHidden:YES];
            [self.lblNoTweetFound setHidden:NO];
            [self.lblNoTweetFound setText:[NSString stringWithFormat:@"No Tweets found for username %@",[(NSDictionary *)self.mutArrUserData objectForKey:@"screen_name"]]];
        });
    }
    
    if (self.isPullToRefresh) {
        [self.refreshControl endRefreshing];
    }
}

-(void)reTweet:(NSString*) tweetId{
   
    [Store requestAccessToAccountsWithType:AccountType options:nil completion:^(BOOL granted, NSError *error) {
        
        SLRequest *aRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/retweet/%@.json",tweetId]] parameters:nil];
        [aRequest setAccount:Account];
        
        [aRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            
            if (error) {
                NSLog(@"Error: %@",error.description);
            }
            else{
                 NSArray *array = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil];
                
                if ([(NSDictionary *)self.mutArrUserData objectForKey:@"errors"]){
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[[[(NSDictionary *)array objectForKey:@"errors"]objectAtIndex:0] objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okAction = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action){
                                                  
                                               }];
                    [alert addAction:okAction];
                    
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                    
                    [self presentViewController:alert animated:YES completion:^{
                        
                    }];
                    
                }else{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@" Successfully Re-Tweet." preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okAction = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                   
                                               }];
                    [alert addAction:okAction];
                    
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                    
                    [self presentViewController:alert animated:YES completion:^{
                        
                    }];
                
                }
            }
        }];
    }];
}
#pragma mark - PullToRefresh
-(void)refreshTweetTable{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    self.isPullToRefresh = YES;
    [self getTweets];
}

#pragma mark -Loading UI
-(void)LoadUI{
    NSString *name = [(NSDictionary *)self.mutArrUserData objectForKey:@"name"];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = [NSString stringWithFormat:@"%@'s Twitter",name];
    });
    
    long followers = [[(NSDictionary *)self.mutArrUserData objectForKey:@"followers_count"] longValue];
    
    long following = [[(NSDictionary *)self.mutArrUserData objectForKey:@"friends_count"] longValue];
    
    long tweets = [[(NSDictionary *)self.mutArrUserData objectForKey:@"statuses_count"] longValue];
    
    NSString *profileImageStringURL = [(NSDictionary *)self.mutArrUserData objectForKey:@"profile_image_url_https"];
    
    NSString *bannerImageStringURL =[(NSDictionary *)self.mutArrUserData objectForKey:@"profile_banner_url"];
    
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
    return [self.mutArrTweets count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
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
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Re-Tweet"
                                                                   message:@"Are you sure,You want to Re-Tweet this Tweet ?"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"Yes"
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                             
                                                              [self reTweet:[NSString stringWithFormat:@"%@",[[self.mutArrTweets objectAtIndex:indexPath.row] objectForKey:@"id"]]];
                                                          }];
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"No"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               NSLog(@"You pressed button No");
                                                           }];
    
    [alert addAction:firstAction];
    [alert addAction:secondAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str = [[self.mutArrTweets objectAtIndex:indexPath.row] objectForKey:@"tweet"];
    CGSize size = [str sizeWithFont:[UIFont fontWithName:@"Helvetica" size:17] constrainedToSize:CGSizeMake(280, 999) lineBreakMode:NSLineBreakByWordWrapping];
    NSLog(@"%f",size.height);
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
@end