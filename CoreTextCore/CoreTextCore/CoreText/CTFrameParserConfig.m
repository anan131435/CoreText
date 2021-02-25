//
//  CTFrameParserConfig.m
//  CoreTextCore
//
//  Created by 韩志峰 on 2021/1/20.
//

#import "CTFrameParserConfig.h"

@implementation CTFrameParserConfig
- (instancetype)init{
    self = [super init];
    if (self) {
        _width = 200.f;
        _fontSize = 16.f;
        _lineSpace = 8.0f;
        _textColor = UIColor.grayColor;
    }
    return  self;
}
@end
