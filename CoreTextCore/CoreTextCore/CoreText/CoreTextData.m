//
//  CoreTextData.m
//  CoreTextCore
//
//  Created by 韩志峰 on 2021/1/20.
//

#import "CoreTextData.h"
#import "CoreTextImageData.h"

@implementation CoreTextData
- (void)dealloc{
    if (_ctframe != nil) {
        CFRelease(_ctframe);
        _ctframe = nil;
    }
}
- (void)setCtframe:(CTFrameRef)ctframe{
    if (_ctframe != ctframe) {
        if (_ctframe) {
            CFRelease(_ctframe);
        }
        CFRetain(ctframe);
        _ctframe = ctframe;
    }
}
- (void)setImageArray:(NSArray *)imageArray{
    _imageArray = imageArray;
    [self fillImagePosition];
}
// 找到每张图片位置
- (void)fillImagePosition{
    if(self.imageArray.count == 0 ){
        return;
    }
    NSArray *lines = (NSArray *)CTFrameGetLines(self.ctframe);
    int lineCount = [lines count];
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(self.ctframe, CFRangeMake(0, 0), lineOrigins);
    
    int imageIndex = 0;
    
    CoreTextImageData *imageData = self.imageArray[0];
    
    for (int i = 0; i < lineCount; i ++) {
        if (imageData == nil) {
            break;;
        }
        CTLineRef line = (__bridge  CTLineRef)lines[i];
        NSArray *runObjArray = (NSArray *)CTLineGetGlyphRuns(line);
        for (id runObj in runObjArray) {
            CTRunRef run = (__bridge  CTRunRef)runObj;
            NSDictionary *runAttribtes = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge  CTRunDelegateRef)[runAttribtes valueForKey:(id)kCTRunDelegateAttributeName];
            if (delegate == nil) {
                continue;
            }
            NSDictionary *metaDic = CTRunDelegateGetRefCon(delegate);
            if (![metaDic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            CGRect runBounds;
            CGFloat ascent;
            CGFloat descent;
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            runBounds.size.height = ascent + descent;
            
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            runBounds.origin.x = lineOrigins[i].x + xOffset;
            runBounds.origin.y = lineOrigins[i].y;
            runBounds.origin.y -= descent;
            
            CGPathRef pathRef = CTFrameGetPath(self.ctframe);
            CGRect colRect = CGPathGetBoundingBox(pathRef);
            CGRect delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
            imageData.imagePosition = delegateBounds;
            imageIndex ++;
            if (imageIndex == self.imageArray.count) {
                imageData = nil;
                break;
            }else{
                imageData = self.imageArray[imageIndex];
            }
        }
    }
}
@end
