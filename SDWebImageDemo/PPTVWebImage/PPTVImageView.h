//
//  PPTVImageView
//  PPTViPad
//
//  Created by Qian GuoQiang on 11-3-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImageView.h"
@class PPTVImageView;

@protocol PPImageViewDelegate <NSObject>
@optional
- (void)singleClickImageView:(PPTVImageView *)imageView;
- (void)finishRequestImageView:(PPTVImageView *)imageView withState:(BOOL)yesOrNo;
@end


@interface PPTVImageView : UIView

- (id)initWithURL:(NSURL *)url;
- (id)initWithURL:(NSURL *)url withDefaultImageName:(NSString *)name;
- (id)initWithURL:(NSURL *)url imageSize:(CGSize)size;
- (id)initWithURL:(NSURL *)url defaultImageName:(NSString *)name imageSize:(CGSize)size;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) FLAnimatedImageView *animatedImageView;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, weak) id<PPImageViewDelegate> delegate;
@property (nonatomic, strong) NSString *defaultImageUrl;
@property (nonatomic, strong) UIImageView *defaultImage;

/**
 是否淡入显示，默认为为NO
 */
@property (nonatomic, assign) BOOL shouldFadeIn;

@end
