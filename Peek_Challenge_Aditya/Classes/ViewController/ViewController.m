//
//  ViewController.m
//  Peek_Challenge_Aditya
//
//  Created by Aditya Tanna on 12/6/15.
//  Copyright © 2015 Aditya Tanna. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import "TweeterHomeVC.h"
#import "Twitter.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    self.mutArrUserData = nil;
    
    self.mutArrUserData = [[NSMutableArray alloc]init];
}


- (IBAction)btnActnGo:(UIButton *)sender {
    
    BOOL isConnected = [[AppDelegate sharedInstance] checkNetwork];
    
    if (isConnected) {
        [self showActivityIndicator];
        
        if (self.txtSearch.text.length > 0) {
            
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            
            NSString *aStrScreenName = [NSString stringWithFormat:@"@%@",self.txtSearch.text];
            
            NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=%@",aStrScreenName]];
            
            [Twitter getTWitterDataWithURL:requestURL withParamaters:[NSDictionary dictionaryWithObjectsAndKeys:aStrScreenName,@"screen_name", nil] withHTTPMethod:SLRequestMethodGET :^(NSArray *array) {
                
                if ([array isKindOfClass:[NSDictionary class]]){
                    
                    NSString *aStrError;
                    
                    UIAlertView *alert;
                    if([[[[(NSDictionary *)array objectForKey:@"errors"]objectAtIndex:0] objectForKey:@"code"] integerValue] == 215){
                        aStrError = @"No Twitter account Logged In. Please Goto Settings and Login.";
                        
                         alert = [[UIAlertView alloc]initWithTitle:@"Unable to Access Twitter" message:aStrError delegate:self cancelButtonTitle:nil otherButtonTitles:@"Settings",@"Ok", nil];
                    }else{
                        aStrError = [[[(NSDictionary *)array objectForKey:@"errors"]objectAtIndex:0] objectForKey:@"message"];
                         alert = [[UIAlertView alloc]initWithTitle:@"Unable to Access Twitter" message:aStrError delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                    }
                    alert.tag = 1010;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        
                        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                        [[self.view viewWithTag:1111] removeFromSuperview];
                        [alert show];
                    });
                }
                else{
                    self.mutArrUserData = [NSMutableArray arrayWithArray:array];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [[self.view viewWithTag:1111] removeFromSuperview];
                        
                        [self performSegueWithIdentifier:@"segueTwitterHomeVC" sender:self];
                    });
                }
            }];
        }
    }
}

-(void)showActivityIndicator{
    UILabel *lblMsg = [[UILabel alloc]initWithFrame:CGRectMake(50,30, 200, 50)];
   
    lblMsg.text = @"Loading...";
    lblMsg.textColor = [UIColor whiteColor];

    UIView *messageFrame = [[UIView alloc]initWithFrame:CGRectMake(self.view.center.x-90, self.view.center.y+35, 180, 70)];
    
    messageFrame.tag = 1111;
    
    messageFrame.layer.cornerRadius = 15;
    messageFrame.backgroundColor = [UIColor blackColor];
    //messageFrame.alpha = ;
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activityIndicator.frame = CGRectMake(63,0, 50, 50);

    [activityIndicator startAnimating];
    
    [messageFrame addSubview:activityIndicator];
    
    [messageFrame addSubview:lblMsg];
    
    [self.view addSubview:messageFrame];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 1010) {
        if (buttonIndex == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueTwitterHomeVC"]) {
        
        TweeterHomeVC *objTwitterHomeVC = segue.destinationViewController;
        
        [objTwitterHomeVC setMutArrUserData:self.mutArrUserData];
        
        self.navigationController.navigationBarHidden = NO;
        
    }
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.txtSearch resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end