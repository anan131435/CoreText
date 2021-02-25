//
//  CoreTextImageData.h
//  CoreTextCore
//
//  Created by 韩志峰 on 2021/1/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface CoreTextImageData : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int position;
// coreText coordinate
@property (nonatomic, assign) CGRect imagePosition;
@end

NS_ASSUME_NONNULL_END
