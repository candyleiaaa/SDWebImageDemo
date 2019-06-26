//
//  PPTVWebImagManager.m
//  PPTVWebImage
//
//  Created by WangLei on 2019/6/26.
//  Copyright © 2019 wanglei. All rights reserved.
//

#import "PPTVWebImagManager.h"
#import "UIImageView+WebCache.h"
#import "FLAnimatedImageView.h"

@interface PPTVWebImagManager ()
//是否淡入显示，默认为NO
@property (nonatomic, assign) BOOL shouldFadeIn;
@property (nonatomic, strong) FLAnimatedImageView *animatedImageView;
@end

@implementation PPTVWebImagManager

+ (PPTVWebImagManager *)sharedWebImagManager
{
    static PPTVWebImagManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PPTVWebImagManager alloc] init];
    });
    return instance;
}

- (void)setImageUrl:(NSString *)urlStr placeholder:(NSString *)imageName imageView:(UIImageView *)imageView {
    [self setImageUrl:urlStr placeholder:imageName imageView:imageView success:nil failed:nil];
}

- (void)setImageUrl:(NSString *)urlStr placeholder:(NSString *)imageName imageView:(UIImageView *)imageView success:(DownLoadImageManagerSuccessBlock)success failed:(DownLoadImageFailedManagerBlock)failed {
    imageView.image = [UIImage imageNamed:imageName];
    NSURL *url = [NSURL URLWithString:urlStr];
    if (url == nil || url.absoluteString.length == 0 || !imageView) {
        return;
    }
    NSString *urlString = url.absoluteString;
    NSURL *aUrl  = [NSURL URLWithString:urlString];

    NSURL *pointUrl = nil;
    if ([self domainFilterWithURL:aUrl]) {
        pointUrl = [aUrl URLByAppendingPathExtension:@"webp"];
    } else {
        pointUrl = aUrl;
    }
    
    if ([self isGIFURL:pointUrl]) {
        if (!self.animatedImageView) {
            self.animatedImageView = [[FLAnimatedImageView alloc] initWithFrame:imageView.bounds];
        }
        
        __weak typeof(self) weakSelf = self;
        [self.animatedImageView sd_setImageWithURL:pointUrl placeholderImage:nil options:SDWebImageQueryDataWhenInMemory completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (![pointUrl isEqual:imageURL]) {
                return;
            }
            
            if (error) {
//                [strongSelf noticeDelegateWhenfinishRequsetImageURL:imageURL state:NO localImage:NO];
                if (failed) {
                    failed(error);
                }
                //                DDLogError(@"PPTVImageView set animatedImage:%@ error:%@", imageURL, error);
                return;
            }
            
            if (!strongSelf.animatedImageView.superview) {
                [imageView addSubview:strongSelf.animatedImageView];
            }
//            strongSelf.imageView.image = nil;
            
            /**
             淡入显示
             */
            if (strongSelf.shouldFadeIn && cacheType == SDImageCacheTypeNone) {
                strongSelf.animatedImageView.alpha = 0.f;
                
                [UIView animateWithDuration:1.f
                                      delay:0.f
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     strongSelf.animatedImageView.alpha = 1.f;
                                 }
                                 completion:^(BOOL finished) {
                                     if ([pointUrl isEqual:imageURL]) {
//                                         strongSelf.defaultImage.hidden = YES;
                                         imageView.image = nil;
                                     }
                                 }];
            } else {
//                strongSelf.defaultImage.hidden = YES;
                imageView.image = nil;
            }
            if (success) {
                success(image);
            }
//            [strongSelf noticeDelegateWhenfinishRequsetImageURL:imageURL state:YES localImage:NO];
        }];
    } else {
        UIImage *localImage = [UIImage imageWithContentsOfFile:[pointUrl absoluteString]];
        if (localImage) {
            imageView.image = localImage;
            if (self.animatedImageView) {
                [self.animatedImageView removeFromSuperview];
                self.animatedImageView = nil;
            }
//            [self noticeDelegateWhenfinishRequsetImageURL:nil state:YES localImage:YES];
            if (success) {
                success(localImage);
            }
        } else {
            __weak typeof(self) weakSelf = self;
            [imageView sd_setImageWithURL:pointUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (![pointUrl isEqual:imageURL]) {
                    return;
                }
                if (error) {
                    if (failed) {
                        failed(error);
                    }
//                    [strongSelf noticeDelegateWhenfinishRequsetImageURL:imageURL state:NO localImage:NO];
                    //                    DDLogError(@"PPTVImageView set image:%@ error:%@", imageURL, error);
                    return;
                }
                
                if (strongSelf.animatedImageView) {
                    [strongSelf.animatedImageView removeFromSuperview];
                    strongSelf.animatedImageView = nil;
                }
                
                /**
                 淡入显示
                 */
                if (strongSelf.shouldFadeIn && cacheType == SDImageCacheTypeNone) {
                    imageView.alpha = 0.f;
                    
                    [UIView animateWithDuration:1.f
                                          delay:0.f
                                        options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         imageView.alpha = 1.f;
                                     }
                                     completion:^(BOOL finished) {
                                         if ([pointUrl isEqual:imageURL]) {
//                                             strongSelf.defaultImage.hidden = YES;
                                         }
                                     }];
                } else {
//                    strongSelf.defaultImage.hidden = YES;
                }
                
//                [strongSelf noticeDelegateWhenfinishRequsetImageURL:imageURL state:YES localImage:NO];
            }];
        }
    }
}

+ (void)clearCache {
    //异步清除所有磁盘缓存映像。非阻塞方法-立即返回
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
    }];
    //清除所有缓存镜像
    [[SDImageCache sharedImageCache] clearMemory];
    
    //异步将所有过期的缓存映像从磁盘中删除。非阻塞方法-立即返回
    [[SDImageCache sharedImageCache] deleteOldFilesWithCompletionBlock:^{
    }];
}

+ (NSString *)cacheSize {
    
    CGFloat size = [[SDImageCache sharedImageCache] getSize];
    NSLog(@"%f",size);
    NSString *message = [NSString stringWithFormat:@"%.2fB。", size];
    NSLog(@"%@",message);
    if (size > (1024 * 1024))
    {
        size = size / (1024 * 1024);
        message = [NSString stringWithFormat:@"%.2fM。", size];
    }
    else if (size > 1024)
    {
        size = size / 1024;
        message = [NSString stringWithFormat:@"%.2fKB。", size];
    }
    return message;
}

#pragma mark - domain filter
- (BOOL)domainFilterWithURL:(NSURL *)url
{
    NSString *extension = [url.pathExtension lowercaseString];
    if ((![extension isEqualToString:@"jpg"] && ![extension isEqualToString:@"jpeg"]) || !url.host) {
        return NO;
    }
    
    static NSRegularExpression *regexExpression = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSString *str = @"^((img([1-3]|[5-9]|1[0-9]|2[0-8]|3[0-9]|4[0-5])|m\\.imgx|v\\.img|webpic)\\.pplive\\.cn|(img(1|[5-9]|1[0-9]|2[0-8])|res[1-4]?|sr[1-9]|img\\.bkm)\\.pplive\\.com|(m\\.imgx|focus)\\.pptv\\.com)$";
        regexExpression = [[NSRegularExpression alloc] initWithPattern:str
                                                               options:NSRegularExpressionCaseInsensitive
                                                                 error:nil];
    });
    
    NSTextCheckingResult *result = [regexExpression firstMatchInString:url.host
                                                               options:0
                                                                 range:NSMakeRange(0, [url.host length])];
    if (result) {
        if ([NSStringFromRange(result.range) isEqualToString:NSStringFromRange(NSMakeRange(NSNotFound, 0))]) {
            return NO;
        } else {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isGIFURL:(NSURL *)url
{
    NSString *pathExtension = [url.pathExtension lowercaseString];
    if (!pathExtension) {
        pathExtension = [[[[[url absoluteString] componentsSeparatedByString:@"?"] firstObject] pathExtension] lowercaseString];
    }
    
    return [pathExtension isEqualToString:@"gif"];
}

@end
