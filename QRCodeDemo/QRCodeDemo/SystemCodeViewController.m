//
//  ViewController.m
//  QRCodeDemo
//
//  Created by wangxiaobo on 16/4/29.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "SystemCodeViewController.h"
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
@interface SystemCodeViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic,strong) AVCaptureDevice *device;
@property (nonatomic,strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic,strong) AVCaptureMetadataOutput *deviceOutput;
@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic,strong) CAShapeLayer *mainLayer;
@property (nonatomic,assign) CGRect scanRect;
@property (nonatomic,strong) UIImageView *lineView;
@end

@implementation SystemCodeViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setupCaptureSession];

	_scanRect = CGRectMake(10, 60, 200, 200);
	self.deviceOutput.rectOfInterest = CGRectMake(60/kScreenHeight, 10/kScreenWidth, 200/kScreenHeight, 200/kScreenWidth);
	[self setupLayer];

	UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
	startButton.frame = CGRectMake(100, 60, 100, 20);
	[startButton setTitle:@"Start" forState:UIControlStateNormal];
	[self.view addSubview:startButton];
	[startButton addTarget:self action:@selector(startScan) forControlEvents:UIControlEventTouchUpInside];

//	NSString *content1 = [self detectQRCodeWithImage:[UIImage imageNamed:@"code.png"]];
//	NSString *content2 = [self detectQRCodeWithImage:[UIImage imageNamed:@"code2.png"]];
//	NSString *content3 = [self detectQRCodeWithImage:[UIImage imageNamed:@"code3.png"]];
//	NSString *content4 = [self detectQRCodeWithImage:[UIImage imageNamed:@"weiboCode2.png"]];
//	NSLog(@"%@,%@,%@,%@",content1,content2,content3,content4);
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self startScan];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self stopScan];
}

- (void)startScan
{
	[self.session startRunning];
	self.lineView.hidden = NO;
	[UIView animateKeyframesWithDuration:6 delay:0 options:UIViewKeyframeAnimationOptionRepeat animations:^{
		CGRect lineViewFrame = _lineView.frame;
		lineViewFrame.origin.y = 198;
		_lineView.frame = lineViewFrame;
	} completion:^(BOOL finished) {

	}];
}

- (void)stopScan
{
	[self.session stopRunning];
	self.lineView.hidden = YES;
	CGRect lineViewFrame = _lineView.frame;
	lineViewFrame.origin.y = 0;
	_lineView.frame = lineViewFrame;
}

- (UIImage *)setupQRCodeWithContent:(NSString *)content
{
	CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
	[filter setValue:[content dataUsingEncoding:NSUTF8StringEncoding] forKey:@"inputMessage"];

	CIImage *transformImage = [filter.outputImage imageByApplyingTransform:CGAffineTransformMakeScale(10, 10)];
	return [UIImage imageWithCIImage:transformImage];
}

- (NSString *)detectQRCodeWithImage:(UIImage *)image
{
	CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
											  context:[CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)}]
											  options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
	CIQRCodeFeature *feature = (CIQRCodeFeature *)[detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]].firstObject;
	return feature.messageString;
}

- (void)setupCaptureSession
{
	self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if(_device) { self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil]; }
	self.deviceOutput = [[AVCaptureMetadataOutput alloc] init];
	[self.deviceOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

	self.session = [[AVCaptureSession alloc] init];
	[self.session setSessionPreset:AVCaptureSessionPresetHigh];
	if(_deviceInput) { [self.session addInput:self.deviceInput]; }
	if(_deviceOutput) { [self.session addOutput:self.deviceOutput]; }
	if([[_deviceOutput availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeQRCode]){
		self.deviceOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
	}

	self.preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
	self.preview.frame = [UIScreen mainScreen].bounds;
	self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[self.view.layer addSublayer:_preview];
}

- (void)setupLayer
{
	UIBezierPath *mainPath = [UIBezierPath bezierPathWithRect:[UIScreen mainScreen].bounds];
	[mainPath appendPath:[UIBezierPath bezierPathWithRect:_scanRect]];

	_mainLayer = [CAShapeLayer layer];
	_mainLayer.path = mainPath.CGPath;
	_mainLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.75].CGColor;
	[_mainLayer setFillRule:kCAFillRuleEvenOdd];
	[self.view.layer addSublayer:_mainLayer];

	UIView *scanView = [[UIView alloc] initWithFrame:_scanRect];
	scanView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
	scanView.layer.borderWidth = 1.0f;
	scanView.layer.borderColor = [UIColor orangeColor].CGColor;
	[self.view addSubview:scanView];

	_lineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _scanRect.size.width, 1)];
	_lineView.backgroundColor = [UIColor orangeColor];
	[scanView addSubview:_lineView];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
	if(metadataObjects.count > 0){
		AVMetadataMachineReadableCodeObject *metadata = metadataObjects.firstObject;
		NSLog(@"%@",metadata.stringValue);
		[self stopScan];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
