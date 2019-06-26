//
//  UIImageView+PPTVWebImage
//  PPTVWebImage
//
//  Created by WangLei on 2019/6/25.
//  Copyright © 2019 wanglei. All rights reserved.
//

#import "UIImageView+PPTVWebImage.h"
#import "PPTVWebImagManager.h"
@implementation UIImageView (PPTVWebImage)

- (void)setImageUrl:(NSString *)urlStr placeholder:(NSString *)imageName {
    [[PPTVWebImagManager sharedWebImagManager]setImageUrl:urlStr placeholder:imageName imageView:self];
}

- (void)setImageUrl:(NSString *)urlStr placeholder:(NSString *)imageName success:(DownloadImageSuccessBlock)success failed:(DownloadImageFailedBlock)failed {
    [[PPTVWebImagManager sharedWebImagManager] setImageUrl:urlStr placeholder:imageName imageView:self success:^(UIImage * _Nonnull image) {
        self.image = image;
        if (success) {
            success(image);
        }
    } failed:^(NSError * _Nonnull error) {
        if (failed) {
            failed(error);
        }
    }];
}


@end
