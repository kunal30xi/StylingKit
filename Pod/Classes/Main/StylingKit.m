/****************************************************************************
 *
 * Copyright 2015-present StylingKit Development Team. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 ****************************************************************************/

//
// Created by Anton Matosov
//

#import "StylingKit.h"
#import "PixateFreestyle.h"
#import "PXStylesheet-Private.h"
#import "STKTheme.h"
#import "STKThemesRegistry.h"

#if STK_CLOUD
#   import "STKCloud.h"
#import "PXLoggingUtils.h"
#import "STK_UIAlertControllerView.h"

#endif

@interface StylingKit ()

@property(strong, nonatomic) NSMutableDictionary* themes;

@end

@implementation StylingKit

STK_DEFINE_CLASS_LOG_LEVEL;


+ (instancetype)sharedKit
{
    static id instance;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^
    {
        instance = [[self alloc] initPrivate];
    });

    return instance;
}

- (STKCloud*)cloud
{
#if STK_CLOUD
    return [STKCloud defaultCloud];
#else
    return nil;
#endif
}

- (NSMutableDictionary*)themes
{
    if (!_themes)
    {
        _themes = [NSMutableDictionary new];
    }
    return _themes;
}


- (instancetype)initPrivate
{
    self = [super init];
    if (self)
    {
    }

    return self;
}

- (void)startStyling
{
    @autoreleasepool
    {
        [STKThemesRegistry loadThemes];

        for (STKTheme* theme in self.themes.allValues)
        {
            if ([theme activate])
            {
                _currentTheme = theme;
                break;
            }
        }

        //
        // Check 'do not subclass' list
        //
//        if(mode != PXStylingNone
//            && ([UIView pxHasAncestor:[UIDatePicker class] forView:self]
//            ||  [UIView pxHasAncestor:[STK_UIAlertControllerView targetSuperclass]
//                              forView:self]
//            || [NSStringFromClass([self class]) isEqualToString:@"CAMFlipButton"])
//            )
//        {
//            //NSLog(@"Found child of UIDatePicker %@", [[self class] description]);
//            mode = PXStylingNone;
//        }

        [UIView appearanceWhenContainedIn:[UIDatePicker class], [STK_UIAlertControllerView targetSuperclass], nil].styleMode = PXStylingNone;
        Class<UIAppearance> cla = NSClassFromString([NSString stringWithFormat:@"%@%@%@", @"CAM", @"Flip", @"Button" ]);
        ((UIView*)[cla appearance]).styleMode = PXStylingNone;

        // Set default styling mode of any UIView to 'normal' (i.e. stylable)
//        [UIView appearance].styleMode = PXStylingNormal;
    }
}

- (STKTheme*)registerThemeNamed:(NSString*)themeName
                       inBundle:(NSBundle*)bundle
{
    if (self.themes[themeName])
    {
        DDLogWarn(@"Theme with name %@ already registered. %@", themeName, self.themes[themeName]);
    }
    STKTheme* theme = [STKTheme themeWithName:themeName
                                       bundle:bundle];
    self.themes[themeName] = theme;

    return theme;
}

@end
