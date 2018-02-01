//
//  OncePayManager.m
//  西北特产
//
//  Created by 曹绍奇 on 2018/1/29.
//  Copyright © 2018年 曹绍奇. All rights reserved.
//

#import "OncePayManager.h"
#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>
#import "UPPaymentControl.h"

//支付环境
#define kMode_Development @"01"

@interface OncePayManager ()<WXApiDelegate>
// 缓存appScheme
@property (nonatomic,strong)NSMutableDictionary *appSchemeDict;

@end

@implementation OncePayManager

+ (instancetype)shareManager{
    static OncePayManager *payManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        payManager = [[self alloc]init];
    });
    return payManager;
}

#pragma mark 支付
- (void)OncePayWithOrderParameter:(id)parameter callBack:(OncePayManagerBack)payBack{
    // 判断手机有没有微信
    if ([WXApi isWXAppInstalled]) {
        NSLog(@"安装了微信");
    }else{
        NSLog(@"还没有安装微信");
    }
    NSAssert(parameter, @"订单信息不能为空");
    // 发起支付
    self.payBack = payBack;
    if ([parameter isKindOfClass:[PayReq class]]) {
        //微信
        [WXApi sendReq:(PayReq *)parameter];
    }else if ([parameter isKindOfClass:[NSString class]]){
        //支付宝
        [[AlipaySDK defaultService] payOrder:parameter fromScheme:self.appSchemeDict[ZhiFuBaoTypeUrl] callback:^(NSDictionary* resultDic) {
            NSString * status=resultDic[@"resultStatus"];
            NSString * memo=resultDic[@"memo"];
            if ([status isEqualToString:@"6001"]) {
                //取消
            }else if ([status isEqualToString:@"9000"]){
                //成功
            }
            if (self.payBack) {
                self.payBack(memo);
            }
        }];
    }
}
//银联
- (void)OncePayWithunionpayParameter:(NSString *)parameter payvc:(UIViewController *)vc callBack:(OnceunionpayManagerBack)payBack{
    self.unpayBack = payBack;
    NSAssert(parameter, @"订单信息不能为空");
    if (parameter != nil && parameter.length > 0){
//        NSLog(@"tn=%@",parameter);
        [[UPPaymentControl defaultControl] startPay:parameter fromScheme:yinlianzhifu mode:kMode_Development viewController:vc];
        
    }
}

#pragma mark 微信回调的代理方法
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[PayResp class]]) {
        //微信
        PayResp *response = (PayResp *)resp;
        NSString * errStr;
        switch (response.errCode) {
            case WXSuccess:
                errStr=@"订单支付成功";
                break;
            case WXErrCodeCommon:
                errStr=@"支付错误";
                break;
            case WXErrCodeUserCancel:
                errStr=@"用户点击取消并返回";
                break;
            case WXErrCodeAuthDeny:
                errStr=@"授权失败";
                break;
            default:
                errStr=response.errStr;
                break;
        }
        if (self.payBack) {
            self.payBack(errStr);
        }
    }
}

#pragma mark 配置支付宝客户端返回url处理方法
-(BOOL)TheCallbackUrl:(NSURL *)url{
    NSAssert(url, @"url地址不能为空！");
    if ([url.host isEqualToString:@"safepay"]) {
        //支付宝
        if ([url.host isEqualToString:@"safepay"]) {
            //跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                NSString * status=resultDic[@"resultStatus"];
                NSString * memo=resultDic[@"memo"];
                if ([status isEqualToString:@"6001"]) {
                    //取消
                }else if ([status isEqualToString:@"9000"]){
                    //成功
                }
                if (self.payBack) {
                    self.payBack(memo);
                }
            }];
        }
        return YES;
    }else if ([url.host isEqualToString:@"pay"]) {
        // 处理微信的支付结果
        [WXApi handleOpenURL:url delegate:self];
        return YES;
    }else if ([url.host isEqualToString:@"uppayresult"]){
        //银联支付
        [[UPPaymentControl defaultControl] handlePaymentResult:url completeBlock:^(NSString *code, NSDictionary *data) {
            //结果code为成功时，先校验签名，校验成功后做后续处理
            NSString * memo;
            NSString * data_str;
            if([code isEqualToString:@"success"]) {
                //交易成功
                //判断签名数据是否存在
                if(data == nil){
                    //如果没有签名数据，建议商户app后台查询交易结果
                    NSAssert(data, @"没有签名数据,请到后台查询交易结果！");
                    return;
                }
                //数据从NSDictionary转换为NSString
                NSData *signData = [NSJSONSerialization dataWithJSONObject:data
                                                                   options:0
                                                                     error:nil];
                NSString *sign = [[NSString alloc] initWithData:signData encoding:NSUTF8StringEncoding];
                memo=@"交易成功";
                data_str=sign;
            }else if([code isEqualToString:@"fail"]) {
                //交易失败
                memo=@"交易失败";
                data_str=@"";
            }else if([code isEqualToString:@"cancel"]) {
                //交易取消
                memo=@"交易取消";
                data_str=@"";
            }
            if (self.unpayBack) {
                self.unpayBack(memo,data_str);
            }
        }];
        return YES;
    }
    return NO;
}

#pragma mark 注册信息
//此方法在(- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions)调用
-(void)registerApp{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *urlTypes = dict[@"CFBundleURLTypes"];
    NSAssert(urlTypes, @"请先在Info.plist 添加 URL Type");
    for (NSDictionary *urlTypeDict in urlTypes) {
        NSString *urlName = urlTypeDict[@"CFBundleURLName"];
        NSArray *urlSchemes = urlTypeDict[@"CFBundleURLSchemes"];
        NSString * urlyinl=urlTypeDict[@"CFBundleTypeRole"];
//        NSAssert(urlSchemes.count, [NSString stringWithFormat:@"请先在Info.plist 的 URL Type 添加 %@ 对应的 URL Scheme",urlNameurlName]);
        // 一般对应只有一个
        NSString *urlScheme = urlSchemes.lastObject;
        if ([urlName isEqualToString:WeiXinTypeUrl]) {
            [self.appSchemeDict setValue:urlScheme forKey:WeiXinTypeUrl];
            // 注册微信
            [WXApi registerApp:urlScheme];
        }else if ([urlName isEqualToString:ZhiFuBaoTypeUrl]){
            // 保存支付宝scheme，以便发起支付使用
            [self.appSchemeDict setValue:urlScheme forKey:ZhiFuBaoTypeUrl];
        }else{

        }
    }
}

#pragma mark -- Setter & Getter

- (NSMutableDictionary *)appSchemeDict{
    if (_appSchemeDict == nil) {
        _appSchemeDict = [NSMutableDictionary dictionary];
    }
    return _appSchemeDict;
}


@end
