//
//  CUFontFormatter.m
//  Khronos
//
//  Created by Gautam Dey on 7/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CUFontFormatter.h"


@implementation CUFontFormatter

- (NSString *)stringForObjectValue:(id)obj
{
    // Not a font
    if(![obj isKindOfClass:[NSFont class]])
    {
        return nil;
    }
    return [NSString stringWithFormat:@"%@ %.0fpt",[obj fontName],[obj pointSize]];
}

@end
