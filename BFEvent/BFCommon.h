//
// Created by undancer on 14-1-3.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>


#ifndef BOXFISH_DEBUG
#define BOXFISH_DEBUG 1
#endif

#if BOXFISH_DEBUG
#define BOXFISH_LOG(fmt, ...) NSLog(fmt, ##__VA_ARGS__)
#else
#define BOXFISH_LOG(...)
#endif

#define BOXFISH_VERSION "0.1"
#define BOXFISH_DEFAULT_UPDATE_INTERVAL 60.0
#define BOXFISH_EVENT_SEND_THRESHOLD 10


#pragma mark - Helper Functions

NSString *BFJSONFromObject(id object);

NSString *BFURLEscapedString(NSString *string);

NSString *BFURLUnescapedString(NSString *string);