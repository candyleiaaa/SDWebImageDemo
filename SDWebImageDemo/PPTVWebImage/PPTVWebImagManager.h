//
//  PPTVWebImagManager.h
//  PPTVWebImage
//
//  Created by WangLei on 2019/6/26.
//  Copyright © 2019 wanglei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 *  监听下载成功的Block
 *
 *  @param image 返回下载成功的图片
 */
typedef void(^DownLoadImageManagerSuccessBlock)(UIImage *image);
/**
 *  监听下载失败的Block
 *
 *  @param error 返回错误信息
 */
typedef void(^DownLoadImageFailedManagerBlock)(NSError *error);
@interface PPTVWebImagManager : NSObject

+ (PPTVWebImagManager *)sharedWebImagManager;

- (void)setImageUrl:(NSString *)urlStr placeholder:(NSString *)imageName imageView:(UIImageView *)imageView;

- (void)setImageUrl:(NSString *)urlStr placeholder:(NSString *)imageName imageView:(UIImageView *)imageView success:(DownLoadImageManagerSuccessBlock)success failed:(DownLoadImageFailedManagerBlock)failed;
/**
 *  清理图片缓存
 */
+ (void)clearCache;

/**
 *  计算当前缓存大小
 */
+ (NSString *)cacheSize;
@end

NS_ASSUME_NONNULL_END
