//
//  WSMStaticFormatters.m
//  Trader
//
//  Created by Cristian Monterroza on 5/17/16.
//  Copyright © 2016 wrkstrm. All rights reserved.
//

#import "WSMStaticFormatters.h"

NSString * const WSMISO8601FormatString = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ";

NSString * const WSMTimeSaleFormatString = @"yyyy-MM-dd'T'HH:mm:ss";

NSString * const WSMTimeDisplayFormatString = @"MM/dd/yy - hh:mm aa";

NSString * const WSMClockAgosticLocale = @"en_US_POSIX";

@implementation NSNumberFormatter (WSMStaticFormatters)

+ (instancetype)WSMDecimalFormatter {
  static dispatch_once_t onceToken;
  static NSNumberFormatter *_WSMDecimalFormatter;
  dispatch_once(&onceToken, ^{
    _WSMDecimalFormatter = [[NSNumberFormatter alloc] init];
    _WSMDecimalFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    _WSMDecimalFormatter.minimumFractionDigits = 2;
    _WSMDecimalFormatter.maximumFractionDigits = 3;
  });
  return _WSMDecimalFormatter;
}

+ (instancetype)WSMDollarFormatter {
  static dispatch_once_t onceToken;
  static NSNumberFormatter *_WSMDollarFormatter;
  dispatch_once(&onceToken, ^{
    _WSMDollarFormatter = [[NSNumberFormatter alloc] init];
    _WSMDollarFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    _WSMDollarFormatter.maximumFractionDigits = 3;
  });
  return _WSMDollarFormatter;
}

@end

@implementation NSDateFormatter (WSMStaticFormatters)

+ (instancetype)WSMTimeSaleDateFormatter {
  static dispatch_once_t onceToken;
  static NSDateFormatter *_WSMTimeSaleDateFormatter;
  dispatch_once(&onceToken, ^{
    _WSMTimeSaleDateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:WSMClockAgosticLocale];
    _WSMTimeSaleDateFormatter.locale = enUSPOSIXLocale;
    _WSMTimeSaleDateFormatter.dateFormat = WSMTimeSaleFormatString;
  });
  return _WSMTimeSaleDateFormatter;
}

+ (instancetype)WSMTimeDisplayDateFormatter {
  static dispatch_once_t onceToken;
  static NSDateFormatter *_WSMTimeDisplayDateFormatter;
  dispatch_once(&onceToken, ^{
    _WSMTimeDisplayDateFormatter = [[NSDateFormatter alloc] init];
    _WSMTimeDisplayDateFormatter.dateFormat = WSMTimeDisplayFormatString;
  });
  return _WSMTimeDisplayDateFormatter;
}

@end

@implementation NSNumber (WSMStaticFormatters)

- (NSString *)wsm_decimalValue {
  return [NSNumberFormatter.WSMDecimalFormatter stringFromNumber:self];
}

- (NSString *)wsm_dollarValue {
  return [NSNumberFormatter.WSMDollarFormatter stringFromNumber:self];
}

@end

@implementation NSDate (WSMStaticFormatters)

- (NSString *)wsm_stringValue {
  return [NSDateFormatter.WSMTimeDisplayDateFormatter stringFromDate:self];
}

@end
