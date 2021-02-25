//
//  CoreUntil.m
//  CoreTextCore
//
//  Created by 韩志峰 on 2021/1/27.
//

#import "CoreUntil.h"

@implementation CoreUntil
// 检测点击位置是否在连接上
+ (CoreTextLinkData *)touchLinkInView:(UIView *)view atPoint:(CGPoint)point data:(CoreTextData *)data{
    CFIndex idx = [self touchContentOffsetView:view atPoint:point data:data];
    if (idx == -1) {
        return  nil;
    }
    CoreTextLinkData *foundLink = [self linkAtIndex:idx linkArray:data.linkArray];
    return  foundLink;
}
// 将点击的位置换成字符串的偏移量，如果没有找到，则返回-1
+ (CFIndex)touchContentOffsetView:(UIView *)view atPoint:(CGPoint)point data:(CoreTextData *)data{
    CTFrameRef textFrame = data.ctframe;
    CFArrayRef lines = CTFrameGetLines(textFrame);
    if (!lines) {
        return  -1;
    }
    CFIndex count = CFArrayGetCount(lines);
    //获得每一行的origin坐标
    CGPoint origins[count];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    // 翻转坐标系
    CGAffineTransform transform  = CGAffineTransformMakeTranslation(0, view.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    
    CFIndex idx = -1;
    for (int i = 0; i < count; i ++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        //
        CGRect flippedRect = [self getLineBounds:line point:linePoint];
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);
        if (CGRectContainsPoint(rect, point)) {
            CGPoint relativePoint = CGPointMake(point.x - CGRectGetMinX(rect), point.y - CGRectGetMinY(rect));
            idx = CTLineGetStringIndexForPosition(line, relativePoint);
        }
    }
    return  idx;
}
+ (CGRect)getLineBounds:(CTLineRef)line point:(CGPoint)point{
    CGFloat ascent = 0.f;
    CGFloat dscent = 0.f;
    CGFloat leading = 0.f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &dscent, &leading);
    CGFloat height = ascent + dscent;
    return  CGRectMake(point.x, point.y - dscent, width, height);
    
}
+ (CoreTextLinkData *)linkAtIndex:(CFIndex)i linkArray:(NSArray *)linkArray{
    CoreTextLinkData *link = nil;
    for (CoreTextLinkData *data in linkArray) {
        if (NSLocationInRange(i, data.range)) {
            link = data;
            break;
        }
    }
    return  link;
}
@end
