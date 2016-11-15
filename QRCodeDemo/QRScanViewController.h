//
//  QRScanViewController.h
//  QRCodeDemo
//
//  Created by djx on 2016/11/14.
//  Copyright © 2016年 tvt.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void (^myBlockType)(NSString *deliverStr);

@interface QRScanViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>

//回调block
@property (nonatomic,strong)myBlockType block;

@end
