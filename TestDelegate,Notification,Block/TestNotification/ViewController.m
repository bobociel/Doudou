//
//  ViewController.m
//  TestNotification
//
//  Created by wangxiaobo on 16/1/11.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

#import "ViewController.h"
#import "SecondViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "LBPickerView.h"
NSString * const kCharacteristicID = @"5CBC1EFC-9896-4A97-AF83-A6B57E37CF24";
NSString * const kServiceID = @"926CB57C-62DF-44B9-97AF-97F372BF847E";
@interface ViewController () <SecondViewControllerDelegate,CBPeripheralManagerDelegate>
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBMutableService *service;
@property (nonatomic, strong) CBMutableCharacteristic *characteristic;
@end

static int count1 = 0;
static int count2 = 0;
static int count3 = 0;
@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];



//	LBPickerView *pickerView = [[LBPickerView alloc] initPickerViewWithInfo:@[@"1",@"ldasd",@"sanasn",@"dasdadasdasd"] andSelectedRows:@[@0,@3]];
//	[pickerView showOrHide];

	LBPickerView *pikcerView = [[LBPickerView alloc] initDatePickerWithDate:[NSDate date] andDateMode:UIDatePickerModeDate];
	[pikcerView showOrHide];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInfo:) name:BBUserInfoUpdateNotification object:nil];
}

#pragma mark - Test Bluetooth
- (void)setupService
{
	CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceID];
	CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicID];

	self.service = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
	self.characteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID
															 properties:CBCharacteristicPropertyNotify value:nil
															permissions:CBAttributePermissionsReadable];

	[self.service setCharacteristics:@[self.characteristic]];
	[self.peripheralManager addService:self.service];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
	if(!error){
		[self.peripheralManager startAdvertising:@{CBAdvertisementDataLocalNameKey:@"ICService",CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:kServiceID]]}];
	}
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
	if(peripheral.state == CBPeripheralStateConnected){
		[self setupService];
	}
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{

}


#pragma mark - Test Delegate & Notification & Block
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if([segue.identifier isEqualToString:@"goSecond"])
	{
		SecondViewController *VC = (SecondViewController *)segue.destinationViewController;
		[VC setDelegate:self];
		[VC setBlock:^{
			count3 ++;
			if(count3 == 10000000){
				NSLog(@"block end:%@",[NSDate date]);
			}
		}];

	}
}

- (void)updateInfo:(NSNotification *)noti
{
	if(noti){
		count1 ++;
	}

	if(count1 == 10000000){
		NSLog(@"noti end:%@",[NSDate date]);
	}
}

- (void)secondViewControllerGetInfo:(NSString *)info
{
	if(info){
		count2 ++ ;
	}
	if(count2 == 10000000){
		NSLog(@"delegate end:%@",[NSDate date]);
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
