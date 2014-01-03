//
// Created by undancer on 14-1-3.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "BFCommon.h"

NSString *BFJSONFromObject(id object) {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];

    if (error) {
        BOXFISH_LOG(@"%@", [error description]);
    }

    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSLog(@"json -> %@", json);
    return json;
}

NSString *BFURLEscapedString(NSString *string) {
    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef) string, NULL, @"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    return (__bridge NSString *) escaped;
}

NSString *BFURLUnescapedString(NSString *string) {
    NSMutableString *resultString = [NSMutableString stringWithString:string];
    [resultString replaceOccurrencesOfString:@"+" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [resultString length])];
    return [resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}