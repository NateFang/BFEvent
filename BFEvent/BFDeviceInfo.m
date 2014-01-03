//
// Created by undancer on 14-1-3.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "BFDeviceInfo.h"
#import "BFCommon.h"
#import "BFEvent_OpenUDID.h"


#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#include <sys/sysctl.h>

@implementation BFDeviceInfo {

}

+ (NSString *)udid {
    return [BFEvent_OpenUDID value];
}

+ (NSString *)device {

    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

+ (NSString *)osVersion {
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)carrier {
    if (NSClassFromString(@"CTTelephonyNetworkInfo")) {
        CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = [info subscriberCellularProvider];
        return [carrier carrierName];
    }

    return nil;
}

+ (NSString *)resolution {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat scale = [[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.f;
    CGSize res = CGSizeMake(bounds.size.width * scale, bounds.size.height * scale);
    NSString *result = [NSString stringWithFormat:@"%g×%g", res.width, res.height];

    return result;
}

+ (NSString *)locale {
    return [[NSLocale currentLocale] localeIdentifier];
}

+ (NSString *)appVersion {
    NSString *result = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if ([result length] == 0)
        result = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *) kCFBundleVersionKey];

    return result;
}

+ (NSString *)metrics {
    NSMutableDictionary *metricsDictionary = [NSMutableDictionary dictionary];
    [metricsDictionary setObject:[BFDeviceInfo device] forKey:@"_device"];
    [metricsDictionary setObject:@"iOS" forKey:@"_os"];
    [metricsDictionary setObject:[BFDeviceInfo osVersion] forKey:@"_os_version"];

    NSString *carrier = [BFDeviceInfo carrier];
    if (carrier) {
        [metricsDictionary setObject:carrier forKey:@"_carrier"];
    }
    [metricsDictionary setObject:[BFDeviceInfo resolution] forKey:@"_resolution"];
    [metricsDictionary setObject:[BFDeviceInfo locale] forKey:@"_locale"];
    [metricsDictionary setObject:[BFDeviceInfo appVersion] forKey:@"_app_version"];

    return BFURLEscapedString(BFJSONFromObject(metricsDictionary));
}

@end