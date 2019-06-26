//
//  ViewController.m
//  SDWebImageDemo
//
//  Created by 王蕾 on 2019/6/26.
//  Copyright © 2019 王蕾. All rights reserved.
//

#import "ViewController.h"
#import "PPTVImageView.h"
#define dd @"https://www.baidu.com/img/baidu_resultlogo@2.png"
#define sss @"https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3300305952,1328708913&fm=27&gp=0.jpg"
#define fff @"https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=2239880928,283080147&fm=26&gp=0.jpg"

#define gif @"https://img.soogif.com/AGU58KGsou98V4dZOtpWCS6IpaLXcduu.gif"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *a;
@property (weak, nonatomic) IBOutlet UIImageView *d;

@property (weak, nonatomic) IBOutlet UIImageView *b;
@property (weak, nonatomic) IBOutlet PPTVImageView *e;
@property (weak, nonatomic) IBOutlet UIImageView *c;
@end
//https://img.soogif.com/AGU58KGsou98V4dZOtpWCS6IpaLXcduu.gif
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PPTVImageView *as = [[PPTVImageView alloc] initWithURL:[NSURL URLWithString:dd] defaultImageName:@"" imageSize:CGSizeMake(160, 160)];
    as.imageURL = [NSURL URLWithString:gif];
    [self.e addSubview:as];
}


@end
