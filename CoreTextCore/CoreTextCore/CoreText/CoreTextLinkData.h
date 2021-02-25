//
//  CoreTextLinkData.h
//  CoreTextCore
//
//  Created by 韩志峰 on 2021/1/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CoreTextLinkData : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) NSRange range;
@end

NS_ASSUME_NONNULL_END
