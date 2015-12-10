//
//  Twitter.m
//  Peek_Challenge_Aditya
//
//  Created by Aditya Tanna on 12/8/15.
//  Copyright © 2015 Aditya Tanna. All rights reserved.
//

#import "Twitter.h"

@interface Twitter ()

@end

@implementation Twitter

+(void)getTWitterDataWithURL:(NSURL *)url withParamaters:(NSDictionary*) dict withHTTPMethod:(SLRequestMethod*) method:(void (^)(NSArray* array))complition{

    ACAccountStore *Store = [[ACAccountStore alloc]init];
    ACAccountType *AccountType = [Store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccount *Account = [[Store accountsWithAccountType:AccountType] lastObject];
    
    [Store requestAccessToAccountsWithType:AccountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            SLRequest *aRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:method URL:url parameters:nil];
            
            [aRequest setAccount:Account];
            
            [aRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                
                if ([urlResponse statusCode] == 429) {
                    NSLog(@"Rate limit reached");
                    return;
                }
                
                // Check if there was an error
                if (error) {
                    NSLog(@"Error: %@", error.localizedDescription);
                    
                    NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:@"No Such Twitter Account Found",@"message", nil]],@"errors", nil];
                    
                    complition((NSArray*)aDict);
                    
                    return;
                }
                id arrTwitterData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil];
                
                complition(arrTwitterData);
            }];
        }else{
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Unable to Access Twitter" message:@"No Logged In Twitter Account Found. Please Login to Twitter account in settings." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Settings",@"Ok", nil];
            
            alert.tag = 1010;
            
            [alert show];

        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
 
    if (alertView.tag == 1010) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}

@end
