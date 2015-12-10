//
//  Twitter.h
//  Peek_Challenge_Aditya
//
//  Created by Aditya Tanna on 12/8/15.
//  Copyright © 2015 Aditya Tanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>

@interface Twitter : NSObject <UIAlertViewDelegate>

+(void)getTWitterDataWithURL:(NSURL *)url withParamaters:(NSDictionary*) dict withHTTPMethod:(SLRequestMethod*) method:(void (^)(NSArray* array))complition;

@end
