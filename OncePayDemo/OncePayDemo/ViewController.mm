//
//  ViewController.m
//  OncePayDemo
//
//  Created by 曹绍奇 on 2018/1/30.
//  Copyright © 2018年 曹绍奇. All rights reserved.
//

#import "ViewController.h"
#import "OncePayManager.h"
#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>
#import "UPPaymentControl.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(100, 100, 100, 50);
    button.tag=100;
    [button setTitle:@"支付宝" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(pay:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * button1=[UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame=CGRectMake(100, 200, 100, 50);
    button1.tag=101;
    [button1 setTitle:@"微信" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:button1];
    [button1 addTarget:self action:@selector(pay:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * button2=[UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame=CGRectMake(100, 300, 100, 50);
    button2.tag=102;
    [button2 setTitle:@"银联" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:button2];
    [button2 addTarget:self action:@selector(pay:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)pay:(UIButton *)pay{
    switch (pay.tag) {
        case 100:
        {
            //支付宝
            NSString *orderMessage = @"";
            [[OncePayManager shareManager] OncePayWithOrderParameter:orderMessage callBack:^(NSString *errStr) {
                NSLog(@"errStr = %@",errStr);
            }];
        }
            break;
        case 101:
        {
            //微信
            PayReq* req             = [[PayReq alloc] init];
            req.partnerId = @"11";
            req.prepayId= @"22";
            req.package = @"Sign=WXPay";
            req.nonceStr= @"33";
            req.timeStamp= @"44".intValue;
            req.sign= @"55";
            [[OncePayManager shareManager] OncePayWithOrderParameter:req callBack:^(NSString *errStr) {
                NSLog(@"errStr = %@",errStr);
            }];
        }
            break;
        case 102:
        {
            //银联
            [[OncePayManager shareManager] OncePayWithunionpayParameter:@"sss" payvc:self callBack:^(NSString *errStr, NSString *data) {

            }];
        }
            break;
            
        default:
            break;
    }
}
//银联支付
-(BOOL) verify:(NSString *) resultStr {
    //验签证书同后台验签证书
    //此处的verify，商户需送去商户后台做验签
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
