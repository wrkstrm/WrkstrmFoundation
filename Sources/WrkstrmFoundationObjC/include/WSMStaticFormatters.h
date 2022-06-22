//
//  WSMStaticFormatters.h
//  Trader
//
//  Created by Cristian Monterroza on 5/17/16.
//  Copyright © 2016 wrkstrm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumberFormatter (WSMStaticFormatters)

+ (instancetype)WSMDecimalFormatter;

+ (instancetype)WSMDollarFormatter;

@end

@interface NSDateFormatter (WSMStaticFormatters)

+ (instancetype)WSMTimeSaleDateFormatter;

+ (instancetype)WSMTimeDisplayDateFormatter;

@end

@interface NSNumber (WSMStaticFormatters)

- (NSString *)wsm_decimalValue;

- (NSString *)wsm_dollarValue;

@end

@interface NSDate (WSMStaticFormatters)

- (NSString *)wsm_stringValue;

@end
