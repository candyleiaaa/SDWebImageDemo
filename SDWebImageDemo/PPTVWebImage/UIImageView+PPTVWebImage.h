//
//  UIImageView+PPTVWebImage
//  PPTVWebImage
//
//  Created by WangLei on 2019/6/25.
//  Copyright © 2019 wanglei. All rights reserved.
//



#import <UIKit/UIKit.h>

//@class PPTVWebImagManager;
/**
 *  监听下载成功的Block
 *
 *  @param image 返回下载成功的图片
 */
typedef void(^DownloadImageSuccessBlock)(UIImage *image);
/**
 *  监听下载失败的Block
 *
 *  @param error 返回错误信息
 */
typedef void(^DownloadImageFailedBlock)(NSError *error);
/**
 *  监听下载进度的Block
 *
 *  @param progress 返回下载进度
 */
//typedef void(^DownImageProgressBlock)(CGFloat progress);

@interface UIImageView (PPTVWebImage)

/**
 *  异步加载图片
 *
 *  @param urlStr    图片地址
 *  @param imageName 占位图片名字
 */
- (void)setImageUrl:(NSString *)urlStr placeholder:(NSString *)imageName;

/**
 *  异步加载图片，监听下载进度、成功、失败
 *
 *  @param urlStr    图片地址
 *  @param imageName 占位图片名字
 *  @param success   下载成功
 *  @param failed    下载失败
 */
- (void)setImageUrl:(NSString *)urlStr placeholder:(NSString *)imageName success:(DownloadImageSuccessBlock)success failed:(DownloadImageFailedBlock)failed;
@end
