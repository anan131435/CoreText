//
//  CTFrameParser.m
//  CoreTextCore
//
//  Created by 韩志峰 on 2021/1/20.
//

#import "CTFrameParser.h"
#import "CoreTextImageData.h"
#import <UIKit/UIKit.h>
#import "CoreTextLinkData.h"
@implementation CTFrameParser


static CGFloat ascentCallback(void *ref){
    return  [(NSNumber *)[(__bridge  NSDictionary*)ref objectForKey:@"height"] floatValue];
}
static CGFloat descentCallback(void *ref){
    return 0;
}

static CGFloat widthCallback(void* ref){
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"width"] floatValue];
}

/*
 获得字体 字形 属性字典
 */
+ (NSMutableDictionary *)attributeWithConfig:(CTFrameParserConfig *)config{
    CGFloat fontSize = config.fontSize;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
    CGFloat lineSpacing = config.lineSpace;
    const CFIndex kNumberOfSettings = 3;
    CTParagraphStyleSetting theSettings[3] = {
        {kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpacing},
        {
            kCTParagraphStyleSpecifierMaximumLineSpacing,sizeof(CGFloat),&lineSpacing
        },
        {
            kCTParagraphStyleSpecifierMinimumLineSpacing,sizeof(CGFloat),&lineSpacing
        }
    };
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    UIColor *textColor = config.textColor;
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[(id) kCTForegroundColorAttributeName] = (id)textColor.CGColor;
    dict[(id) kCTFontAttributeName] = (__bridge id)fontRef;
    dict[(id) kCTParagraphStyleAttributeName] = (__bridge  id)theParagraphRef;
    CFRelease(theParagraphRef);
    CFRelease(fontRef);
    return  dict;
}
+ (CoreTextData *)parseContent:(NSString *)content config:(CTFrameParserConfig *)config{
    NSDictionary *attributes = [self attributeWithConfig:config];
    NSAttributedString *contentStr = [[NSAttributedString alloc] initWithString:content attributes:attributes];
    //创建CTFrameSetter实例
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)contentStr);
    //获得要绘制的区域
    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil);
    CGFloat textheight = coreTextSize.height;
    //生成CTFramRef 实例
    CTFrameRef frame = [self createFrameWithFrameSetter:framesetter config:config height:textheight];
    CoreTextData *data = [CoreTextData new];
    data.ctframe = frame;
    data.height = textheight;
    CFRelease(frame);
    CFRelease(framesetter);
    return  data;
}
//通过CTFramesetter 生成CTFrame
+ (CTFrameRef)createFrameWithFrameSetter:(CTFramesetterRef)framesetter config:(CTFrameParserConfig *)config height:(CGFloat)height{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, config.width, height));
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    return  frame;
}
+ (CoreTextData *)parseAttributeContent:(NSAttributedString *)content config:(CTFrameParserConfig *)config{
    //创建CTFrameSetter实例
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)content);
    //获得要绘制的区域
    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil);
    CGFloat textheight = coreTextSize.height;
    //生成CTFramRef 实例
    CTFrameRef frame = [self createFrameWithFrameSetter:framesetter config:config height:textheight];
    CoreTextData *data = [CoreTextData new];
    data.ctframe = frame;
    data.height = textheight;
    data.content = content;
    CFRelease(frame);
    CFRelease(framesetter);
    return  data;
}
+ (CoreTextData *)paraseTemplateFile:(NSString *)path config:(CTFrameParserConfig *)config{
    NSMutableArray *imageArray = [NSMutableArray new];
    NSMutableArray *linkArray = [NSMutableArray new];
    NSAttributedString *attrStr = [self loadTemplateFile:path config:config imageArray:imageArray linkArray:linkArray];
    CoreTextData *data = [self parseAttributeContent:attrStr config:config];
    data.imageArray = imageArray;
    data.linkArray = linkArray;
    return  data;
}
+ (NSAttributedString *)loadTemplateFile:(NSString *)path config:(CTFrameParserConfig *)config imageArray:(NSMutableArray *)imageArray linkArray:(NSMutableArray *)linkArray{
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSMutableAttributedString * result = [NSMutableAttributedString new];
    if (data) {
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if ([array isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in array) {
                NSString *type = dict[@"type"];
                if ([type isEqualToString:@"txt"]) {
                    NSAttributedString *temp = [self parseAttributedContentFromDictonry:dict config:config];
                    [result appendAttributedString:temp];
                }else if ([type isEqualToString:@"img"]){
                    CoreTextImageData *imageData = [CoreTextImageData new];
                    imageData.name = dict[@"name"];
                    imageData.position = [result length];
                    [imageArray addObject:imageData];
                    //创建占位符
                    NSAttributedString *as = [self parseImageDataFromNSDictionary:dict config:config];
                    [result appendAttributedString:as];
                }else if([type isEqualToString:@"link"]){
                    NSUInteger startPos = result.length;
                    NSAttributedString *as = [self parseAttributedContentFromDictonry:dict config:config];
                    [result appendAttributedString:as];
                    NSUInteger length = result.length - startPos;
                    NSRange linkRange = NSMakeRange(startPos, length);
                    CoreTextLinkData *linkData = [[CoreTextLinkData alloc] init];
                    linkData.title = dict[@"content"];
                    linkData.url = dict[@"url"];
                    linkData.range = linkRange;
                    [linkArray addObject:linkData];
                }
            }
        }
    }
    return  result;
}
+ (NSAttributedString *)parseAttributedContentFromDictonry:(NSDictionary *)dict config:(CTFrameParserConfig *)config{
    NSMutableDictionary *attributes = [self attributeWithConfig:config];
    UIColor *color = [self colorFromTemplate:dict[@"color"]];
    if (color) {
        attributes[(id) kCTForegroundColorAttributeName] = (id)color.CGColor;
    }
    CGFloat fontSize = [dict[@"size"] floatValue];
    if (fontSize > 0) {
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
        attributes[(id)kCTFontAttributeName] = (__bridge id)fontRef;
        CFRelease(fontRef);
    }
    NSString *content = dict[@"content"];
    return  [[NSAttributedString alloc] initWithString:content attributes:attributes];
    
}
+ (UIColor *)colorFromTemplate:(NSString *)name{
    if ([name isEqualToString:@"blue"]) {
            return [UIColor blueColor];
        } else if ([name isEqualToString:@"red"]) {
            return [UIColor redColor];
        } else if ([name isEqualToString:@"black"]) {
            return [UIColor blackColor];
        } else {
            return nil;
        }
}
+ (NSAttributedString *)parseImageDataFromNSDictionary:(NSDictionary *)dict config:(CTFrameParserConfig *)config{
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge  void *)(dict));
    NSString *content = @" ";
    NSDictionary *attributes = [self attributeWithConfig:config];
    NSMutableAttributedString * space = [[NSMutableAttributedString alloc] initWithString:content attributes:attributes];
    CFAttributedStringSetAttribute((CFAttributedStringRef) space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    return  space;
    
}

@end
