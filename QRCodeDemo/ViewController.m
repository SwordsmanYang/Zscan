//
//  ViewController.m
//  QRCodeDemo
//
//  Created by djx on 2016/11/14.
//  Copyright © 2016年 tvt.com. All rights reserved.
//

#import "ViewController.h"
#import "QRScanViewController.h"

@interface ViewController ()<UIImagePickerControllerDelegate,UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *resultLab;
@property (weak, nonatomic) IBOutlet UITextField *qrTF;
@property (weak, nonatomic) IBOutlet UIImageView *qrImage;

//显示选择的颜色
@property (weak, nonatomic) IBOutlet UILabel *lowLab;
@property (weak, nonatomic) IBOutlet UILabel *hightLab;

//颜色的rgb tf
@property (weak, nonatomic) IBOutlet UITextField *LRTF;
@property (weak, nonatomic) IBOutlet UITextField *LGTF;
@property (weak, nonatomic) IBOutlet UITextField *LBTF;

@property (weak, nonatomic) IBOutlet UITextField *HRTF;
@property (weak, nonatomic) IBOutlet UITextField *HGTF;
@property (weak, nonatomic) IBOutlet UITextField *HBTF;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _lowLab.backgroundColor = [UIColor colorWithRed:[_LRTF.text integerValue]/255.0 green:[_LGTF.text integerValue]/255.0 blue:[_LBTF.text integerValue]/255.0 alpha:1.0];
    _hightLab.backgroundColor = [UIColor colorWithRed:[_HRTF.text integerValue]/255.0 green:[_HGTF.text integerValue]/255.0 blue:[_HBTF.text integerValue]/255.0 alpha:1.0];
}

- (IBAction)qrScan:(UIButton *)sender
{
    QRScanViewController *vc = [[QRScanViewController alloc]init];
    vc.block = ^(NSString *resultStr){
        _resultLab.text = resultStr;
    };
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)album:(UIButton *)sender {
    [self takePhotoFromAlbum];
}

- (IBAction)transform:(UIButton *)sender {
    [self textTransformQRCode];
}
//相册
- (void)takePhotoFromAlbum
{
    UIImagePickerController *pickerV = [[UIImagePickerController alloc] init];
    
    pickerV.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerV.delegate = self;
    pickerV.allowsEditing = YES;
    [self presentViewController:pickerV animated:YES completion:nil];
}

#pragma mark  照片imagePicker delegate method

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    UIImage *srcImage = image;
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    CIImage *cImage = [CIImage imageWithCGImage:srcImage.CGImage];
    NSArray *features = [detector featuresInImage:cImage];
    CIQRCodeFeature *feature = [features firstObject];
    
    NSString *result = feature.messageString;
    _resultLab.text = result;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)textTransformQRCode
{
    NSString *text = _qrTF.text;
    NSData *stringData = [text dataUsingEncoding: NSUTF8StringEncoding];
    
    //生成
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    UIColor *onColor = [UIColor colorWithRed:[_LRTF.text integerValue]/255.0 green:[_LGTF.text integerValue]/255.0 blue:[_LBTF.text integerValue]/255.0 alpha:1.0];
    UIColor *offColor = [UIColor colorWithRed:[_HRTF.text integerValue]/255.0 green:[_HGTF.text integerValue]/255.0 blue:[_HBTF.text integerValue]/255.0 alpha:1.0];
    
    //上色
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                       keysAndValues:
                             @"inputImage",qrFilter.outputImage,
                             @"inputColor0",[CIColor colorWithCGColor:onColor.CGColor],
                             @"inputColor1",[CIColor colorWithCGColor:offColor.CGColor],
                             nil];
    
    CIImage *qrImage = colorFilter.outputImage;
    
    //绘制
    CGSize size = CGSizeMake(300, 300);
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    _qrImage.image = codeImage;
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    [_qrTF resignFirstResponder];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_qrTF resignFirstResponder];
    [_LRTF resignFirstResponder];
    [_LBTF resignFirstResponder];
    [_LGTF resignFirstResponder];
    [_HRTF resignFirstResponder];
    [_HBTF resignFirstResponder];
    [_HGTF resignFirstResponder];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _lowLab.backgroundColor = [UIColor colorWithRed:[_LRTF.text integerValue]/255.0 green:[_LGTF.text integerValue]/255.0 blue:[_LBTF.text integerValue]/255.0 alpha:1.0];
    _hightLab.backgroundColor = [UIColor colorWithRed:[_HRTF.text integerValue]/255.0 green:[_HGTF.text integerValue]/255.0 blue:[_HBTF.text integerValue]/255.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
