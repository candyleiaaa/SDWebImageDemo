//
//  PPTVImageView
//  PPTViPad
//
//  Created by Qian GuoQiang on 11-3-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PPTVImageView.h"
#import "UIImageView+WebCache.h"

@interface PPTVImageView ()

@property (nonatomic, assign) BOOL isMove;
@property (nonatomic, strong) NSURL *requestURL;

@end
@implementation PPTVImageView


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.exclusiveTouch = YES;
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        [self addSubview:self.imageView];
    }
    return self;
}

//从IB唤醒时候，应该生成imageView
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (!self.imageView) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.cornerRadius = 4.f;
        self.imageView.layer.masksToBounds = YES;
        self.exclusiveTouch = YES;
        
        [self addSubview:self.imageView];
    }
}

- (instancetype)init {
    return [self initWithURL:nil];
}

- (id)initWithURL:(NSURL *)url
{
    return [self initWithURL:url
            defaultImageName:nil
                   imageSize:CGSizeZero];
}

- (id)initWithURL:(NSURL *)url withDefaultImageName:(NSString *)name
{
    return [self initWithURL:url
            defaultImageName:name
                   imageSize:CGSizeZero];
}

- (id)initWithURL:(NSURL *)url imageSize:(CGSize)size
{
    return [self initWithURL:url
            defaultImageName:nil
                   imageSize:size];
}

- (id)initWithURL:(NSURL *)url defaultImageName:(NSString *)name imageSize:(CGSize)size
{
    self.exclusiveTouch = YES;
    
    CGRect nFrame = CGRectMake(0,
                               0,
                      size.width,
                     size.height);
    
    self = [super initWithFrame:nFrame];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.frame];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    
    [self addSubview:self.imageView];
    
    self.imageURL = url;
    
    [self setDefaultImageUrl:name];
    
    return self;
}

- (void)dealloc
{
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    
    _defaultImageUrl = nil;
}

#pragma mark - Property Setter

- (UIImageView *)defaultImage
{
    if (!_defaultImage) {
        _defaultImage = [[UIImageView alloc] initWithFrame:self.bounds];
        _defaultImage.contentMode = UIViewContentModeCenter;
        _defaultImage.clipsToBounds = YES;
        
        [self addSubview:_defaultImage];
        [self sendSubviewToBack:_defaultImage];
    }
    return _defaultImage;
}

- (void)setDefaultImageUrl:(NSString *)Url
{
    if ([Url length] == 0 || [_defaultImageUrl isEqualToString:Url]) {
        return;
    }
    _defaultImageUrl = Url;
    self.defaultImage.image = [UIImage imageNamed:Url];
}

- (void)setImageURL:(NSURL *)url
{
    self.defaultImage.hidden = NO;
    
    if (url == nil || url.absoluteString.length == 0) {
        _imageURL = nil;
        self.requestURL = nil;
        self.imageView.image = nil;
        [self removeAnimatedImageView];
        return;
    }
    
    NSString *urlString = url.absoluteString;
    _imageURL = [NSURL URLWithString:urlString];
    
    if ([self domainFilterWithURL:_imageURL]) {
        self.requestURL = [_imageURL URLByAppendingPathExtension:@"webp"];
    } else {
        self.requestURL = _imageURL;
    }
    
    if ([self isGIFURL:self.requestURL]) {
        if (!self.animatedImageView) {
            self.animatedImageView = [[FLAnimatedImageView alloc] initWithFrame:self.bounds];
        }
        
        __weak typeof(self) weakSelf = self;
        [self.animatedImageView sd_setImageWithURL:self.requestURL placeholderImage:nil options:SDWebImageQueryDataWhenInMemory completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (![strongSelf.requestURL isEqual:imageURL]) {
                return;
            }
            
            if (error) {
                [strongSelf noticeDelegateWhenfinishRequsetImageURL:imageURL state:NO localImage:NO];
//                DDLogError(@"PPTVImageView set animatedImage:%@ error:%@", imageURL, error);
                return;
            }
            
            if (!strongSelf.animatedImageView.superview) {
                [strongSelf addSubview:strongSelf.animatedImageView];
            }
            strongSelf.imageView.image = nil;
            
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
                                     if ([strongSelf.requestURL isEqual:imageURL]) {
                                         strongSelf.defaultImage.hidden = YES;
                                     }
                                 }];
            } else {
                strongSelf.defaultImage.hidden = YES;
            }
            
            [strongSelf noticeDelegateWhenfinishRequsetImageURL:imageURL state:YES localImage:NO];
        }];
    } else {
        UIImage *localImage = [UIImage imageWithContentsOfFile:[self.requestURL absoluteString]];
        if (localImage) {
            self.imageView.image = localImage;
            if (self.animatedImageView) {
                [self.animatedImageView removeFromSuperview];
                self.animatedImageView = nil;
            }
            [self noticeDelegateWhenfinishRequsetImageURL:nil state:YES localImage:YES];
        } else {
            __weak typeof(self) weakSelf = self;
            [self.imageView sd_setImageWithURL:self.requestURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (![strongSelf.requestURL isEqual:imageURL]) {
                    return;
                }
                if (error) {
                    [strongSelf noticeDelegateWhenfinishRequsetImageURL:imageURL state:NO localImage:NO];
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
                    strongSelf.imageView.alpha = 0.f;
                    
                    [UIView animateWithDuration:1.f
                                          delay:0.f
                                        options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         strongSelf.imageView.alpha = 1.f;
                                     }
                                     completion:^(BOOL finished) {
                                         if ([strongSelf.requestURL isEqual:imageURL]) {
                                             strongSelf.defaultImage.hidden = YES;
                                         }
                                     }];
                } else {
                    strongSelf.defaultImage.hidden = YES;
                }
                
                [strongSelf noticeDelegateWhenfinishRequsetImageURL:imageURL state:YES localImage:NO];
            }];
        }
    }
}

- (void)noticeDelegateWhenfinishRequsetImageURL:(NSURL *)imageURL state:(BOOL)yesOrNo localImage:(BOOL)localImage
{
    //这里dispatchQueue是为了避免PPTVImageView在初始化的时候设置delegate之前就设置了URL且图片在内存中有缓存而立马返回导致不会调用delegate方法
    __weak typeof(self) weakSelf = self;
    id delegate = self.delegate;
    dispatch_async(dispatch_get_main_queue(), ^{
    __strong typeof(weakSelf) strongSelf = weakSelf;
    if (([imageURL isEqual:self.requestURL] || localImage) && [delegate respondsToSelector:@selector(finishRequestImageView:withState:)]) {
            [delegate finishRequestImageView:strongSelf withState:yesOrNo];
        }
    });
}

- (void)setImageView:(UIImage *)image withSize:(CGSize)_size
{
    self.imageView.image = image;
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

#pragma mark - Touch Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.isMove = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.isMove = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([[event allTouches] count] == 1 && self.isMove == NO) {
        if ([self.delegate respondsToSelector:@selector(singleClickImageView:)]) {
            [self.delegate singleClickImageView:self];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    self.animatedImageView.frame = self.bounds;
    self.defaultImage.frame = self.bounds;
}

#pragma mark - GIFImage

- (void)removeAnimatedImageView
{
    if (self.animatedImageView) {
        [self.animatedImageView removeFromSuperview];
        self.animatedImageView = nil;
    }
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
