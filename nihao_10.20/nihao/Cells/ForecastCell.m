//
//  ForecastCell.m
//  nihao
//
//  Created by HelloWorld on 7/29/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "ForecastCell.h"
//#import "BaseFunction.h"

@interface ForecastCell ()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherLabel;
@property (weak, nonatomic) IBOutlet UIImageView *weatherImageView;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *windDirectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *windSpeedLabel;

@end

@implementation ForecastCell

- (void)configureCellWithForecastInfo:(NSDictionary *)forecastInfo forRowAtIndexPath:(NSIndexPath *)indexPath weatherPhenomenonDictionary:(NSDictionary *)weatherPhenomenon {
//	self.dateLabel.text = [NSString stringWithFormat:@"%ld", [forecastInfo[@"weekday"] integerValue]];
	self.weatherLabel.text = weatherPhenomenon[forecastInfo[@"day_weather"]][@"en_name"];
	NSString *weatherImageName = weatherPhenomenon[forecastInfo[@"day_weather"]][@"weather_forecast_image_name"];
	self.weatherImageView.image = [UIImage imageNamed:weatherImageName];
	self.temperatureLabel.text = [NSString stringWithFormat:@"%ld", [forecastInfo[@"day_air_temperature"] integerValue]];
//	self.windDirectionLabel.text = [BaseFunction getWindDirectionEnglishNameByChineseName:forecastInfo[@"day_wind_direction"]];
	self.windDirectionLabel.text = forecastInfo[@"day_wind_direction"];
//	self.windSpeedLabel.text = [BaseFunction getWindPowerLevelByOriginalWindPower:forecastInfo[@"day_wind_power"]];
	self.windSpeedLabel.text = forecastInfo[@"day_wind_power"];
	
	if (indexPath.row == 0) {
		self.dateLabel.text = @"Tomorrow";
	} else {
//		self.dateLabel.text = [BaseFunction getWeekdayNameByIndex:[forecastInfo[@"weekday"] integerValue]];
		self.dateLabel.text = forecastInfo[@"weekday"];
	}
	
	[self showCellSubViews:YES];
}

- (void)showCellSubViews:(BOOL)show {
	self.dateLabel.hidden = !show;
	self.weatherLabel.hidden = !show;
	self.weatherImageView.hidden = !show;
	self.temperatureLabel.hidden = !show;
	self.windDirectionLabel.hidden = !show;
	self.windSpeedLabel.hidden = !show;
}

- (void)awakeFromNib {
    // Initialization code
}

@end
