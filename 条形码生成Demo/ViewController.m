//
//  ViewController.m
//  条形码生成Demo
//
//  Created by 喻永权 on 17/2/21.
//  Copyright © 2017年 喻永权. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *qrCodeImageView;

@property (nonatomic, strong) UIButton *pressBtn;


@property (nonatomic, strong) UIImageView *codeImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.qrCodeImageView];
    [self.view addSubview:self.pressBtn];
    [self.view addSubview:self.codeImageView];
    [self.qrCodeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.mas_equalTo(100);
        make.size.mas_equalTo(CGSizeMake(200, 80));
    }];
    [self.pressBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.qrCodeImageView.mas_bottom).offset(50);
        make.width.centerX.equalTo(self.qrCodeImageView);
        make.height.mas_equalTo(50);
    }];
    [self.codeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pressBtn.mas_bottom).offset(30);
        make.centerX.equalTo(self.pressBtn);
        make.width.height.equalTo(self.pressBtn.mas_width);
    }];
    
}

- (UIImageView *)qrCodeImageView{
    if(_qrCodeImageView == nil){
        _qrCodeImageView = [UIImageView new];
        _qrCodeImageView.layer.borderWidth = 0.5f;
        _qrCodeImageView.layer.borderColor = [UIColor grayColor].CGColor;
    }
    return _qrCodeImageView;
}

- (UIImageView *)codeImageView{
    if(_codeImageView == nil){
        _codeImageView = [UIImageView new];
        _codeImageView.layer.borderColor = [UIColor grayColor].CGColor;
        _codeImageView.layer.borderWidth = 0.5f;
    }
    return _codeImageView;
}

- (UIButton *)pressBtn{
    if(_pressBtn == nil){
        _pressBtn = [UIButton new];
        [_pressBtn setTitle:@"生成条形码" forState:UIControlStateNormal];
        _pressBtn.backgroundColor = [UIColor redColor];
        [_pressBtn addTarget:self action:@selector(generateBarCode:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pressBtn;
}


#pragma mark ======= 生成二维码 ===========
/**
 *  生成二维码
 */
- (void)generateQRCode:(UIButton *)sender {
    CIImage *ciImage = [self generateQRCodeImage:@"bvfhgdfgbvdsfvdxfgbv35656"];
    _codeImageView.image = [self resizeCodeImage:ciImage withSize:CGSizeMake(200, 200)];
}
/**
 *  二维码图片
 *
 *
 *  @return CIImage 对象
 */
- (CIImage *)generateQRCodeImage:(NSString *)source
{
    NSData *data = [source dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:data forKey:@"inputMessage"];
//    [filter setValue:@"Q" forKey:@"inputCorrectionLevel"];
    
    return filter.outputImage;
}



#pragma mark ======= 生成条形码 ===========

/**
 *  生成条形码
 */
- (void)generateBarCode:(UIButton *)sender {
    CIImage *ciImage = [self generateBarCodeImage:@"4454557874545"];
    UIImage *image = [self resizeCodeImage:ciImage withSize:self.qrCodeImageView.frame.size];
    self.qrCodeImageView.image = image;
    
    [self generateQRCode:sender];
}
/**
 *  生成条形码
 *
 *
 *  @return 生成条形码的CIImage对象
 */
- (CIImage *) generateBarCodeImage:(NSString *)source
{
    // iOS 8.0以上的系统才支持条形码的生成，iOS8.0以下使用第三方控件生成
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 注意生成条形码的编码方式
//        NSData *data = [source dataUsingEncoding: NSASCIIStringEncoding];
        NSData *data = [source dataUsingEncoding:NSUTF8StringEncoding];
        CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
        [filter setValue:data forKey:@"inputMessage"];
        // 设置生成的条形码的上，下，左，右的margins的值
        [filter setValue:[NSNumber numberWithInteger:0] forKey:@"inputQuietSpace"];
        return filter.outputImage;
    }else{
        return nil;
    }
}

/**
 *  调整生成的图片的大小
 *
 *  @param image CIImage对象
 *  @param size  需要的UIImage的大小
 *
 *  @return size大小的UIImage对象
 */
- (UIImage *) resizeCodeImage:(CIImage *)image withSize:(CGSize)size
{
    if (image) {
        CGRect extent = CGRectIntegral(image.extent);
        CGFloat scaleWidth = size.width/CGRectGetWidth(extent);
        CGFloat scaleHeight = size.height/CGRectGetHeight(extent);
        size_t width = CGRectGetWidth(extent) * scaleWidth;
        size_t height = CGRectGetHeight(extent) * scaleHeight;
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
        CGContextRef contentRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef imageRef = [context createCGImage:image fromRect:extent];
        CGContextSetInterpolationQuality(contentRef, kCGInterpolationNone);
        CGContextScaleCTM(contentRef, scaleWidth, scaleHeight);
        CGContextDrawImage(contentRef, extent, imageRef);
        CGImageRef imageRefResized = CGBitmapContextCreateImage(contentRef);
        CGContextRelease(contentRef);
        CGImageRelease(imageRef);
        return [UIImage imageWithCGImage:imageRefResized];
    }else{
        return nil;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
