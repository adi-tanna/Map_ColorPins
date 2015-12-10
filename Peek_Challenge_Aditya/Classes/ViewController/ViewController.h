//
//  ViewController.h
//  Peek_Challenge_Aditya
//
//  Created by Aditya Tanna on 12/6/15.
//  Copyright © 2015 Aditya Tanna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate>
{

}
@property(nonatomic,strong) NSMutableArray *mutArrUserData;
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;


- (IBAction)btnActnGo:(UIButton *)sender;

@end

