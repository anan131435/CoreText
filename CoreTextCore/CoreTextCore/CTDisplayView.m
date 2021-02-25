//
//  CTDisplayView.m
//  CoreTextCore
//
//  Created by 韩志峰 on 2021/1/20.
//

#import "CTDisplayView.h"
#import <CoreText/CoreText.h>
#import "CoreTextData.h"
#import "CoreTextImageData.h"
#import "CoreUntil.h"
@implementation CTDisplayView



- (void)drawRect:(CGRect)rect {
   
//    [self simpleDemo];
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
   // CGContextTranslateCTM
    if (self.data) {
        CTFrameDraw(self.data.ctframe, context);
        for (CoreTextImageData * imageData in self.data.imageArray) {
            UIImage * image = [UIImage imageNamed: imageData.name];
            CGContextDrawImage(context, imageData.imagePosition, image.CGImage);
        }
        
//        for (CoreTextImageData in self.data.im) {
//
//        }
    }
    
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupEvents];
    }
    return  self;
}
- (void)setupEvents{
    UIGestureRecognizer *tapGrsture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTaped:)];
    [self addGestureRecognizer:tapGrsture];
    self.userInteractionEnabled = YES;
}
- (void)userTaped:(UITapGestureRecognizer *)gesture{
    CGPoint point = [gesture locationInView:self];
    for (CoreTextImageData *imageData in self.data.imageArray) {
        //coreImageData中的坐标系 跟UIKit坐标系翻转
        CGRect imageRect = imageData.imagePosition;
        CGPoint imagePosition = imageRect.origin;
        imagePosition.y = self.bounds.size.height - imageRect.origin.y - imageRect.size.height;
        CGRect rect = CGRectMake(imagePosition.x, imagePosition.y, imageRect.size.width, imageRect.size.height);
        if (CGRectContainsPoint(rect, point)) {
            NSLog(@"picture was clicked");
            break;
        }
        
    }
    CoreTextLinkData *linkData = [CoreUntil touchLinkInView:self atPoint:point data:self.data];
    if (linkData) {
        NSLog(@"%@",linkData.url);
    }
    
}
- (void)simpleDemo{
    //得到画布的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //2
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    //翻转坐标系，底层绘制引擎左下角是（0，0） UIkit右上角是原始坐标系
    CGContextScaleCTM(context, 1.0, -1.0);
    //3创建绘制区域，coreText支持各种文字排版区域，这里将整个UIView作为排版区域。
    CGMutablePathRef path = CGPathCreateMutable();
//    CGPathAddRect(path, NULL, self.bounds);
    CGPathAddEllipseInRect(path, NULL, self.bounds);
//    CGPathAddRoundedRect(path, NULL, self.bounds, 100, 100);
    //4
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"Hello World! "
                                      " 创建绘制的区域，CoreText 本身支持各种文字排版的区域，"
                                      " 我们这里简单地将 UIView 的整个界面作为排版的区域。"
                                      " 为了加深理解，建议读者将该步骤的代码替换成如下代码，"
                                      " 测试设置不同的绘制区域带来的界面变化。"];
    //attributeString 生成frameSetter
    CTFramesetterRef frameSetter =
    CTFramesetterCreateWithAttributedString((CFAttributedStringRef) attrString);
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    CTFrameDraw(frame, context);
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(frameSetter);
}


@end
