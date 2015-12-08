//
//  ViewController.m
//  Peek_Challenge_Aditya
//
//  Created by Aditya Tanna on 12/6/15.
//  Copyright © 2015 Aditya Tanna. All rights reserved.
//

#import "ViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import "TweeterHomeVC.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mutArrUserData = [[NSMutableArray alloc]init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}


- (IBAction)btnActnGo:(UIButton *)sender {
    
    if (self.txtSearch.text.length > 0) {
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
            if (granted) {
                
                NSArray *accounts = [accountStore accountsWithAccountType:accountType];
                
                // Check if the users has setup at least one Twitter account
                
                if (accounts.count > 0)
                {
                    ACAccount *twitterAccount = [accounts objectAtIndex:0];
                    
                    // Creating a request to get the info about a user on Twitter
                    
                    SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"] parameters:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"@%@",self.txtSearch.text] forKey:@"screen_name"]];
                    
                    [twitterInfoRequest setAccount:twitterAccount];
                    
                    // Making the request
                    [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        // Check if we reached the reate limit
                        if ([urlResponse statusCode] == 429) {
                            NSLog(@"Rate limit reached");
                            return;
                        }
                        
                        // Check if there was an error
                        if (error) {
                            NSLog(@"Error: %@", error.localizedDescription);
                            return;
                        }
                        
                        // Check if there is some response data
                        
                        if (responseData) {
                            
                            NSError *error = nil;
                            self.mutArrUserData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                            
                            if ([(NSDictionary *)self.mutArrUserData objectForKey:@"errors"]){
                                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error!!" message:[[[(NSDictionary *)self.mutArrUserData objectForKey:@"errors"]objectAtIndex:0] objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
                                
                                UIAlertAction *okAction = [UIAlertAction
                                                           actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                           style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action)
                                                           {
                                                               [self.navigationController popToRootViewControllerAnimated:YES];                                                           }];
                                [alert addAction:okAction];
                                
                                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                
                                [self presentViewController:alert animated:YES completion:^{
                                    
                                }];
                                
                            }else{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self performSegueWithIdentifier:@"segueTwitterHomeVC" sender:self];
                                });
                                
                            }
                        }
                    }];
                }else{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unable to Access Twitter" message:@"No Logged In Twitter Account Found. Please Login to Twitter account in settings." preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *settings = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(@"Settings", @"Settings action")
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                   
                                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                               }];
                    
                    UIAlertAction *cancle = [UIAlertAction
                                             actionWithTitle:NSLocalizedString(@"Cancle", @"OK action")
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action)
                                             {
                                                 
                                             }];
                    
                    [alert addAction:settings];
                    [alert addAction:cancle];
                    
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                    
                    [self presentViewController:alert animated:YES completion:^{
                        
                    }];
                }
                
            }
        }];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Input Required" message:@"Please enter user name" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"OK action");
                                   }];
        
        [alert addAction:okAction];
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        [self presentViewController:alert animated:YES completion:^{
            
        }];
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