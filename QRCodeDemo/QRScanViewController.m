//
//  QRScanViewController.m
//  QRCodeDemo
//
//  Created by djx on 2016/11/14.
//  Copyright © 2016年 tvt.com. All rights reserved.
//

#import "QRScanViewController.h"

#define SCREEN_WINTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HIGHT [UIScreen mainScreen].bounds.size.height
#define HIGHT [UIScreen mainScreen].bounds.size.height/1136

@interface QRScanViewController ()<UIAlertViewDelegate>

{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
}

@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;
@property (nonatomic, retain) UIImageView * line;

@end

@implementation QRScanViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupCamera];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat  imaX = (SCREEN_WINTH - 220)/2;
    CGFloat  imaY = 286*HIGHT;
    CGFloat  imaW = 220;
    CGFloat  imaH = 220;
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imaX, imaY, imaW, imaH)];
    imageView.image = [UIImage imageNamed:@"mine-bg-scanning"];
    imageView.center = CGPointMake(SCREEN_WINTH/2, imaY +imaH/2);
    [self.view addSubview:imageView];
    
    upOrdown = NO;
    num = 0;
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(imaX+7.5, imaY, 205, 2)];
    _line.image = [UIImage imageNamed:@"mine-bg-scanning-moive"];
    
    [self.view addSubview:_line];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation) userInfo:nil repeats:YES];
    
    UILabel *promptLab=[[UILabel alloc] initWithFrame:CGRectMake(imaX,CGRectGetMaxY(imageView.frame),imaW,25)];
    promptLab.text=@"将二维码放入框内,即可添加账户";
    [promptLab setTextColor:[UIColor whiteColor]];
    [promptLab setFont:[UIFont systemFontOfSize:14]];
    promptLab.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:promptLab];
}

- (void)setupCamera
{
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    NSString *mediaType = AVMediaTypeVideo;
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
    {
        NSLog(@"相机权限受限");
        
        self.view.backgroundColor =[UIColor blackColor];
        UIAlertView * la = [[UIAlertView alloc]initWithTitle:@"温馨提醒" message:@"此应用没有权限访问您的摄像头，您可以在“隐私设置”中启用访问。" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [la show];
        return;
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame =CGRectMake(20,110,280,280);
    _preview.frame =CGRectMake(0, 0, SCREEN_WINTH, SCREEN_HIGHT);
    
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    [_session startRunning];
}

-(void)animation
{
    CGFloat  imaX = (SCREEN_WINTH - 220)/2;
    CGFloat  imaY = 286*HIGHT;
    
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(imaX+7.5, imaY+2*num, 205, 2);
        if (2*num == 220) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(imaX+7.5, imaY+2*num, 205, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
}

#pragma mark - UIAlterDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    [_session stopRunning];
    [timer invalidate];
    
    NSString *stringValue;
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        
        NSLog(@"stringValue = %@",stringValue);
        
        if ([stringValue length]>0)
        {
            NSLog(@"二维码－－－－－%@",stringValue);
            _block(stringValue);
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (IBAction)backBtn:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
