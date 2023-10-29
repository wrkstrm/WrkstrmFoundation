//
//  WSColorPalette.h
//
//  Created by Cristian A Monterroza on 9/20/12.
//  Copyright (c) 2012 wrkstrm. All rights reserved.
//

// Ensure compatability between, OSX and iOS without SpriteKit


@import Foundation;
#ifdef UIKit
@import UIKit;
#elif TARGET_OS_OSX
@import AppKit;
#endif
@import SpriteKit;

typedef NS_ENUM(NSUInteger, WSMAgendaType) {
    kWSMAgendaTypeUncategorized = 0,
    kWSMAgendaTypeRecuperate,
    kWSMAgendaTypeWork,
    kWSMAgendaTypeSocial,
    kWSMAgendaTypeExercise,
    kWSMAgendaTypeDeadTime,
};

typedef NS_ENUM(NSUInteger, WSMColorGradient) {
    kWSMGradientUncategorized = 0,
	kWSMGradientWhite,
	kWSMGradientGreen,
	kWSMGradientBlue,
	kWSMGradientRed,
	kWSMGradientBlack,
};

extern SKColor* SKColorMakeRGB(CGFloat red, CGFloat green, CGFloat blue);

@interface WSMColorPalette : NSObject

+ (SKColor *)colorForAgenda:(WSMAgendaType)agendaConstant forIndex:(NSInteger)index ofCount:(NSInteger)count reversed:(BOOL) reversed;

+ (SKColor *)colorGradient:(WSMColorGradient)colorGradient forIndex:(NSInteger)index ofCount:(NSInteger)count reversed:(BOOL)reversed;

@end
