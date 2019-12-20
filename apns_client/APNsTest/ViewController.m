//
//  ViewController.m
//  APNsTest
//
//  Created by 新银河 on 2019/10/24.
//  Copyright © 2019 MJDev. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UILabel *descripLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 130, self.view.frame.size.width-60, 150)];
    descripLabel.text = @"MagotanPush \n是一款简易的推送产品\n你需要在服务端和客户端集成后\n即可开始享用";
    descripLabel.font = [UIFont fontWithName:@"Helvetica" size:20];
    descripLabel.numberOfLines = 0;
    descripLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:descripLabel];
    
    UILabel *userInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 300, self.view.frame.size.width-60, 150)];
    userInfoLabel.textColor = [UIColor lightGrayColor];
    userInfoLabel.text = @"Geeks_Chen\n18519191125@163.com";
    userInfoLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    userInfoLabel.numberOfLines = 0;
    userInfoLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:userInfoLabel];
    
    
    UILabel *deviceTokenLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 450, self.view.frame.size.width-60, 150)];
    deviceTokenLabel.textColor = [UIColor grayColor];
    deviceTokenLabel.text = [NSString stringWithFormat:@"deviceToken:%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"DEVICETOKEN"]];
    deviceTokenLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
    deviceTokenLabel.numberOfLines = 0;
    deviceTokenLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:deviceTokenLabel];
    
}


@end
