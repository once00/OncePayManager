//
//  OncePayManager.h
//  西北特产
//
//  Created by 曹绍奇 on 2018/1/29.
//  Copyright © 2018年 曹绍奇. All rights reserved.
//

/**
 *
 *  此处必须保证在Info.plist 中的 URL Types 的 Identifier 对应一致
 */
#define WeiXinTypeUrl @"weixin"
#define ZhiFuBaoTypeUrl @"zhifubao"
#define yinlianzhifu @"yinlian"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^OncePayManagerBack)(NSString *errStr);
typedef void(^OnceunionpayManagerBack)(NSString *errStr,NSString *data);
@interface OncePayManager : NSObject

@property (nonatomic,copy)OncePayManagerBack payBack;
@property (nonatomic,copy)OnceunionpayManagerBack unpayBack;

+ (instancetype)shareManager;


/**
 *
 *  发起支付(微信.支付宝)
 *
 *@param parameter 订单信息（后台生成给我们，需要签名，其中签名为了安全起见要放在后台做）
 schemeStr 调用支付的app注册在info.plist中的scheme
  支付结果回调Block，用于wap支付结果回调（非跳转钱包支付）
 * @param payBack     回调，有返回状态信息
 */
- (void)OncePayWithOrderParameter:(id)parameter callBack:(OncePayManagerBack)payBack;

/**
*
*  发起支付(银联)
*
*@param parameter 订单信息（后台生成给我们，需要签名，其中签名为了安全起见要放在后台做）
*@param vc 发起支付的vc
* @param payBack     回调，有返回状态信息
*/
- (void)OncePayWithunionpayParameter:(id)parameter payvc:(UIViewController *)vc callBack:(OnceunionpayManagerBack)payBack;

//配置支付宝客户端返回url处理方法
-(BOOL)TheCallbackUrl:(NSURL *)url;

//注册信息
//此方法在(- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions)调用
-(void)registerApp;

@end
