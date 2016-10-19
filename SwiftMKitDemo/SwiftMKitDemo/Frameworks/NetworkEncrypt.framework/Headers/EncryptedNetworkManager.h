//
//  EncryptedNetworkManager.h
//  NetworkEncrypt
//
//  Created by yushouren on 16/8/30.
//  Copyright © 2016年 pintec. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  需要特殊处理的错误码
 */
extern NSInteger StatusCodeForceUpgradeApp;
extern NSInteger StatusCodeNetworkUnsafe;
extern NSInteger StatusCodeDisableEncrypt;

/**
 *  禁用加密的时间
 */
extern NSTimeInterval DisableEncryptTime;

typedef void(^HandlerRequestComplete)(NSData *responseData, NSHTTPURLResponse *response, NSError *error);

@protocol EncryptedNetworkManagerDelegate <NSObject>

@optional

- (void)networkEncryptReceiveDataLength:(NSInteger)dataLenght totalBytesExpectedToReceive:(NSInteger)length task:(NSURLSessionDataTask *)task;

- (void)networkEncryptDidReceiveData:(NSData *)data task:(NSURLSessionDataTask *)task;
- (void)networkEncryptDidSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend task:(NSURLSessionDataTask *)task;
- (void)networkEncryptDidCompleteWithError:(NSError *)error task:(NSURLSessionDataTask *)task;
- (void)networkEncryptDidReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler task:(NSURLSessionDataTask *)task;

@end

@interface EncryptedNetworkManager : NSObject

@property (nonatomic, weak) id<EncryptedNetworkManagerDelegate> delegate;

+ (instancetype)sharedEncryptedNetworkManager;

/**
 *  设置 appId，vId。IMPORTANT: 请在调用加密请求之前调用此方法。调用一次就行。
 */
- (void)setAppId:(NSString *)appId vId:(NSString *)vId;

- (NSString *)userId;

/**
 *  加密请求
 *
 *  @param request         待加密的请求
 *  @param completeHandler 加密请求完成的回调（应保证在主线程调用）
 *  @return 返回执行该请求的 task。（业务用这个绑定了转圈的菊花）
 */
- (void)handlerRequest:(NSURLRequest *)request task:(NSURLSessionDataTask *)task complete:(HandlerRequestComplete)completeHandler;

- (void)cancleReuqestWithTask:(NSURLSessionTask *)task;

/**
 *  返回和服务器时间校准后的时间
 *
 *  @param date 待校准的时间
 *
 *  @return 校准后的时间
 */
- (NSDate *)serverTimeWithTime:(NSDate *)date;

/************** 监控相关 **************/

/**
 *  返回当前的 request id.
 */
- (int)requestId;

/**
 * 当发送一个不加密的请求时，记录请求开始的时间
 */
- (void)setStartTime:(NSDate *)startTime forRequestId:(int)requestId;

/**
 * 当不加密的请求结束时，记录请求结束的时间
 */
- (void)setEndTime:(NSDate *)endTime forRequestId:(int)requestId;

/**
 * 如果请求出错，请调用此方法。
 */
- (void)setErrorMessage:(NSString *)errorMessage forRequestId:(int)requestId;

/**
 *  查看当前是否显示log(默认不显示log)
 */
+ (BOOL)showLog;

/**
 *  在 DEBUG 模式下设置是否显示log
 */
+ (void)setShowLog:(BOOL)showLog;

@end
