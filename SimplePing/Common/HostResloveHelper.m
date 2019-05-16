//
//  HostResloveHelper.m
//  SimplePing
//
//  Created by miaoyou.gmy on 2019/5/16.
//

/**
 Resolving Hostnames with CFHost
 To resolve a host with CFHost:
 
 1. Create a CFHostRef object by calling CFHostCreateWithName.
 
 2. Call CFHostSetClient and provide the context object of your choice and a callback function that will be called when resolution completes.
 
 3. Call CFHostScheduleWithRunLoop to schedule the resolver on your run loop.
 
 4. Call CFHostStartInfoResolution to tell the resolver to start resolving, passing kCFHostAddresses as the second parameter to indicate that you want it to return IP addresses.
 
 5. Wait for the resolver to call your callback. Within your callback, obtain the results by calling CFHostGetAddressing. This function returns an array of CFDataRef objects, each of which contains a POSIX sockaddr structure.
 
 6. The process for reverse name resolution (translating an IP address into a hostname) is similar, except that you call CFHostCreateWithAddress to create the object, pass kCFHostNames to CFHostStartInfoResolution, and call CFHostGetNames to retrieve the results.
 

 
 */
#import "HostResloveHelper.h"
#include <sys/socket.h>
#include <netdb.h>

@implementation HostResloveHelper

+ (NSString *)displayIPAddressBySockAdr:(NSData *)address{
    int         err;
    NSString *  result;
    char        hostStr[NI_MAXHOST];
    
    result = nil;
    
    if (address != nil) {
        err = getnameinfo(address.bytes,
                          (socklen_t) address.length,
                          hostStr,
                          sizeof(hostStr),
                          NULL,
                          0,
                          NI_NUMERICHOST);
        if (err == 0) {
            result = @(hostStr);
        }
    }
    
    if (result == nil) {
        result = @"?";
    }
    
    return result;
}

+ (NSString *)resloveHostByDomain:(NSString *)domain useIPv6:(BOOL)ipv6{
    CFHostRef hostRef = (CFHostRef) CFAutorelease( CFHostCreateWithName(NULL, (__bridge CFStringRef) domain));
    
    CFHostScheduleWithRunLoop(hostRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    Boolean success = CFHostStartInfoResolution(hostRef, kCFHostAddresses, NULL);
    if(success){
        NSArray *adds = (__bridge NSArray *)CFHostGetAddressing(hostRef, &success);
        __block NSData *addressData = nil;
        if(adds && success){
            for(NSData *data in adds){
                const struct sockaddr *addPtr;
                addPtr = (const struct sockaddr *)data.bytes;
                if(addPtr->sa_family == AF_INET6 && ipv6){
                    addressData = data;
                    break;
                } else if(addPtr->sa_family == AF_INET){
                    addressData = data;
                    break;
                }
            }
        }
        
        if(addressData){
            return [HostResloveHelper displayIPAddressBySockAdr:addressData];
        }
    }
    
    return @"?";
}

@end
