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
#import "WXApiManager.h"
#import "WXApi.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,WXApiManagerDelegate,WXApiDelegate>
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI{
    
    self.dataSource=@[@"支付宝支付",@"支付宝授权",@"微信支付",@"微信授权",@"银联支付"];
    
    self.tableview.frame=self.view.frame;
    [self.view addSubview:self.tableview];
}

#pragma mark --------------- UITableViewDataSource-----------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    cell.backgroundColor=[UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font=[UIFont systemFontOfSize:14];
    
    cell.textLabel.text=_dataSource[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    switch (indexPath.row) {
        case 0:
        {
            [self Alipay];
        }
            break;
        case 1:
        {
            [self authpay];
        }
            break;
        case 2:
        {
            [self weixinpay];
        }
            break;
        case 3:
        {
            [self authweixin];
        }
            break;
        case 4:
        {
            [self yinlianpay];
        }
            break;
            
        default:
            break;
    }
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 40;
}


- (UITableView *)tableview {
    if(!_tableview) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableview.delegate=self;
        _tableview.dataSource=self;
        _tableview.showsVerticalScrollIndicator = NO;
        _tableview.backgroundColor=[UIColor whiteColor];
        [_tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellID"];
    }
    return _tableview;
}


//支付宝支付
- (void)Alipay{
    NSString *orderMessage = @"";
    [[OncePayManager shareManager] OncePayWithOrderParameter:orderMessage callBack:^(NSString *errStr) {
        NSLog(@"errStr = %@",errStr);
    }];
}

//支付宝授权
- (void)authpay{
    NSString *authMessage = @"com.alipay.account.auth&app_id=2017110809796267&app_name=mc&auth_type=AUTHACCOUNT&biz_type=openservice&method=alipay.open.auth.sdk.code.get&pid=2088821619346017&product_id=APP_FAST_LOGIN&scope=kuaijie&sign_type=RSA2&target_id=50ca761597324b8088ebedf90de11dc7&sign=HyxRzPwdbr m1q1IYiM75z1ewZRkX7aBtEygEXYZoMSuiMWzd4vIbJVPSW8pvpX1/EAX77xpkkNkJjfEw/bwe72swUTxrBT04Hw5IaodBYRLUCQw/lzXSnlWXeWVbGj34P3CTFpqef82Tx1n6hnWcc43wrxDIlF72Ug vA8rHm YO1FtWa9Ci997bqr/m4XMZ8UcfYO/YBtlI4KgeOaEJhapW8g40RV4W6mY6FFGhJsOmbnIfFfNedolB8CNXEQ4rT3xM7FLix2ho2LMQruN/nSTZh3o7hpOjr90ZOZ4Rt51JFFIsgnUxP1bdp c8s0ni/4xzw2e0C70a528OEk3kw==";
//    [[AlipaySDK defaultService] auth_V2WithInfo:authMessage
//                                     fromScheme:@"OncePayDemo"
//                                       callback:^(NSDictionary *resultDic) {
//                                           NSLog(@"result = %@",resultDic);
//                                           // 解析 auth code
//                                           NSString *result = resultDic[@"result"];
//                                           NSString *authCode = nil;
//                                           if (result.length>0) {
//                                               NSArray *resultArr = [result componentsSeparatedByString:@"&"];
//                                               for (NSString *subResult in resultArr) {
//                                                   if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
//                                                       authCode = [subResult substringFromIndex:10];
//                                                       break;
//                                                   }
//                                               }
//                                           }
//                                           NSLog(@"授权结果 authCode = %@", authCode?:@"");
//                                       }];
    [[OncePayManager shareManager]OncePayWithAuthParameter:authMessage callBack:^(NSString *errStr) {
        
    }];
}


//微信支付
- (void)weixinpay{
    
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

//微信授权

- (void)authweixin{
    SendAuthReq *sendAuthReq = [[SendAuthReq alloc] init];
    sendAuthReq.scope = @"snsapi_userinfo";
    sendAuthReq.state = @"wx_auth";
//    [WXApi sendReq:sendAuthReq];
    [[OncePayManager shareManager]OncePayWithAuthParameter:sendAuthReq callBack:^(id errStr) {
        
        NSString *code = errStr[@"code"];
        [self getWeiXinOpenId:code];
    }];
}

//银联支付
- (void)yinlianpay{
    //银联
    [[OncePayManager shareManager] OncePayWithunionpayParameter:@"sss" payvc:self callBack:^(NSString *errStr, NSString *data) {
        
    }];
}








//- (void)managerDidRecvAuthResponse:(SendAuthResp *)response {
//    NSString *strTitle = [NSString stringWithFormat:@"Auth结果"];
//    NSString *strMsg = [NSString stringWithFormat:@"code:%@,state:%@,errcode:%d", response.code, response.state, response.errCode];
//    NSLog(@"1111111");
////    [UIAlertView showWithTitle:strTitle message:strMsg sure:nil];
//}
//- (void) onResp:(BaseResp*)resp{
//    NSLog(@"resp.errCode = %d",resp.errCode);
//    NSLog(@"resp.errCode = %@",resp.errStr);
//    NSLog(@"resp.errCode = %d",resp.type);
//    SendAuthResp *aresp = (SendAuthResp *)resp;
//    if (aresp.errCode== 0) {
////        _wxCode = aresp.code;NSDictionary *dic = @{@"code":CHECK_STRING(_wxCode)};
////        [RequestUtil getWXAuthWithParams:dic success:^(NSDictionary *responseData) {if ([responseData isKindOfClass:[NSDictionary class]]) {}} failure:^(NSString *errorInfo) {}];
//        NSString *code = aresp.code;
//        [self getWeiXinOpenId:code];
//
//    }
//
//
//}
//
//
//- (void)onReq:(BaseReq *)req {
//
//}


//银联支付
-(BOOL) verify:(NSString *) resultStr {
    //验签证书同后台验签证书
    //此处的verify，商户需送去商户后台做验签
    return NO;
}


//
//通过code获取access_token，openid，unionid
- (void)getWeiXinOpenId:(NSString *)code{
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",@"",@"",code];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data){
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSString *openID = dic[@"openid"];
                NSString *unionid = dic[@"unionid"];
                
                [self getWeChatUserInfoWithToken:dic[@"access_token"] andOpenID:dic[@"openid"]];
            }
        });
    });
    
}

// 获取微信用户信息
- (void)getWeChatUserInfoWithToken:(NSString *)token andOpenID:(NSString *)openid {
    //
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",token,openid];
    //
   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data){
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                
            }
        });
    });
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
