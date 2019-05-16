//
//  HostResloveHelper.h
//  SimplePing
//
//  Created by miaoyou.gmy on 2019/5/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HostResloveHelper : NSObject

+ (NSString *)displayIPAddressBySockAdr:(NSData *)address;

+ (NSString *)resloveHostByDomain:(NSString *)domain useIPv6:(BOOL)ipv6;

@end

NS_ASSUME_NONNULL_END
