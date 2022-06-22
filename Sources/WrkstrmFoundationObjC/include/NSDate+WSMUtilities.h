//
//  NSDate+WSMUtilities.h
//  wrkstrm_mac
//
//  Created by Cristian Monterroza on 1/18/14.
//
//

#import "Foundation/Foundation.h"

@interface NSDate (WSMUtilities)

+ (NSDate *)now:(NSCalendarUnit)components;

+ (NSDate *)tomorrow:(NSCalendarUnit)components;

+ (NSTimeInterval)timeIntervalUntilNextMidNight;

+ (NSTimeInterval)timeIntervalUntilNextHour;

+ (NSTimeInterval)timeIntervalUntilNextSecond;

@end
