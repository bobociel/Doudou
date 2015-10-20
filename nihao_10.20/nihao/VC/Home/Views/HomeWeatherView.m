//
//  HomeWeatherView.m
//  nihao
//
//  Created by HelloWorld on 7/23/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "HomeWeatherView.h"

@interface HomeWeatherView ()

@property (weak, nonatomic) IBOutlet UIImageView *weatherStatusImageView;
@property (weak, nonatomic) IBOutlet UILabel *weatherTemperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherPM2Dot5ValueLabel;

@end

@implementation HomeWeatherView

#pragma mark - View Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		self = (HomeWeatherView *)[[NSBundle mainBundle] loadNibNamed:@"HomeWeatherView" owner:self options:nil][0];
		self.frame = frame;
	}
	
	return self;
}

#pragma mark - Public

- (void)configuerWeatherViewWithWeatherInfo:(NSDictionary *)weatherInfo {
	NSString *imageName = weatherInfo[@"weather_image_name"];
	self.weatherStatusImageView.image = [UIImage imageNamed:imageName];
	self.weatherTemperatureLabel.text = [NSString stringWithFormat:@"%ld°", [weatherInfo[@"temperature"] integerValue]];
	self.weatherPM2Dot5ValueLabel.text = [NSString stringWithFormat:@"%ld", [weatherInfo[@"aqiDetail"][@"pm2_5"] integerValue]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
