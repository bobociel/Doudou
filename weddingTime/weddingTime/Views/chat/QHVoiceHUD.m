//
//  POVoiceHUD.m
//  lovewith
//
//  Created by momo on 15/4/8.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.

#import "QHVoiceHUD.h"
#import "LWUtil.h"
#import "WTAlertView.h"

@implementation QHVoiceHUD


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.contentMode     = UIViewContentModeRedraw;
        self.opaque          = NO;
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0.0f;
        
        timeBtn = [[UIButton alloc] init];
        [timeBtn setTitle:@"0 S" forState:UIControlStateNormal];
        timeBtn.titleLabel.font=[WeddingTimeAppInfoManager fontWithSize:14];
        timeBtn.backgroundColor=[UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:0.72];
        timeBtn.layer.cornerRadius=10;
        timeBtn.layer.masksToBounds=YES;
        //
        //        statusLable               = [[UILabel alloc] initWithFrame:timeBtn.frame];
        //        statusLable.bottom        = timeBtn.top+15;
        //        statusLable.font          = defaultFont14;
        //        statusLable.textColor     = [UIColor whiteColor];
        //        statusLable.text          = @"向上滑动取消发送";
        //        statusLable.textAlignment = NSTextAlignmentCenter;
        //        [self addSubview:statusLable];
        [self addSubview:timeBtn];
        [self resetTimeBtn];
        for(int i=0; i<SOUND_METER_COUNT; i++) {
            soundMeters[i] = -45;
        }
    }
    
    return self;
}

-(void)resetTimeBtn
{
    [timeBtn sizeToFit];
    float width=timeBtn.frame.size.width;
    width+=31;
    int x  = (self.frame.size.width - width) / 2;
    timeBtn.frame=CGRectMake(x,self.frame.size.height/2.f-100+3+HUD_SIZE/2, width, 20);
}

- (id)initWithParentView:(UIView *)view {
    return [self initWithFrame:view.bounds];
}

- (void)startForFilePath:(NSString *)filePath {
    
    recordTime = 0;
    self.alpha = 1.0f;
    [self setNeedsDisplay];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        return;
    }
    
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        return;
    }
    
    
    //.caf格式 貌似更大...kAudioFormatAppleIMA4
    //todo 采样率调整 压缩音频
    recordSetting = @{AVFormatIDKey : @(kAudioFormatLinearPCM), AVEncoderBitRateKey:@(16),AVEncoderAudioQualityKey : @(AVAudioQualityMedium), AVSampleRateKey : @(8000.0), AVNumberOfChannelsKey : @(1)};
    
    recorderFilePath = filePath;
    
    NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
    
    err = nil;
    
    NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
    if(audioData) {
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:[url path] error:&err];
    }
    
    err = nil;
    recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
    if(!recorder){
        return;
    }
    
    [recorder setDelegate:self];
    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
    
    BOOL audioHWAvailable = audioSession.inputAvailable;
    if (!audioHWAvailable) {
        return;
    }
    [recorder recordForDuration:(NSTimeInterval) maxAudioTime+1];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:WAVE_UPDATE_FREQUENCY target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
}

- (void)updateMeters {
    [recorder updateMeters];
    int time=(int)recordTime;
    int minites=time/60;
    
    int seconds=time%60;
    NSString *timeString=[NSString stringWithFormat:@"%d\"",seconds];
    if (minites>0) {
        timeString=[NSString stringWithFormat:@"%d'%@",minites,timeString];
    }
    [timeBtn setTitle:timeString forState:UIControlStateNormal];
    [self resetTimeBtn];
    if (recordTime>=maxAudioTime) {
        [timeBtn setTitle:@"松手发送语言" forState:UIControlStateNormal];
        [recorder stop];
        [timer invalidate];
    }
    
    recordTime += WAVE_UPDATE_FREQUENCY;
    [self addSoundMeterItem:[recorder averagePowerForChannel:0]];
    
}

- (void)cancelRecording {
    if ([self.delegate respondsToSelector:@selector(voiceRecordCancelledByUser:)]) {
        [self.delegate voiceRecordCancelledByUser:self];
    }
    [self removeFromSuperview];
    [timer invalidate];
    [recorder stop];
}

- (void)commitRecording {
    [recorder stop];
    [timer invalidate];
    
    if ([self.delegate respondsToSelector:@selector(POVoiceHUD:voiceRecorded:length:)]) {
        [self.delegate POVoiceHUD:self voiceRecorded:recorderFilePath length:recordTime];
    }
    [self removeFromSuperview];
}

- (void)cancelled:(id)sender {
    [self removeFromSuperview];
    
    [timer invalidate];
    [self cancelRecording];
}

- (void)setAsNomore {
    isRelaceToCance  = NO;
    // statusLable.text = @"向上滑动取消发送";
}

- (void)setAsRelaceToCance {
    isRelaceToCance  = YES;
    // statusLable.text = @"释放手指取消发送";
}

#pragma mark - 根据接收到的分贝更新音频曲线

- (void)shiftSoundMeterLeft {
    for(int i=0; i<SOUND_METER_COUNT - 1; i++) {
        soundMeters[i] = soundMeters[i+1];
    }
}

- (void)addSoundMeterItem:(int)lastValue {
    [self shiftSoundMeterLeft];
    [self shiftSoundMeterLeft];
    soundMeters[SOUND_METER_COUNT - 1] = lastValue;
    soundMeters[SOUND_METER_COUNT - 2] = lastValue;
    MSLog(@"%i",lastValue);
    [self setNeedsDisplay];
}

-(float)returnRadioWithMeter:(int)meter
{
    //距离0到无穷远 像素0到63
    float g=15000.0f;
    if(meter==0)
        return 63;
    return 1.0*g/meter/meter;
}

-(float)returnMeterWithRadio:(int)Radio
{
    //距离0到无穷远 像素0到63
    float g=15000.0f;
    if (Radio==0) {
        return INT32_MAX;
    }
    return sqrt(1.0*g/Radio);
}

#define PI 3.14159265358979323846
#pragma mark - 重绘
- (void)drawRect:(CGRect)rect {
    // CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    float strokeAlpha[4]={1,0.3,0.15,0.0};
    float fillAlpha[4]={0.72,0.2,0.05,0.02};
    float radiusMAX[4]={50,65,85,113};
    float radiusMIN[4]={0,50,65,85};
    int level=1;
    int meter=abs(soundMeters[SOUND_METER_COUNT - 1]);
    
    for (int i=1; i<4; i++) {
        if (meter<[self returnMeterWithRadio:radiusMAX[i]-50]) {
            level++;
        }
    }
    
    NSLog(@"level %d  meter %d",level,meter);
    
    for (int i=0; i<level&&i<4; i++) {
        UIColor *strokeColor ;//边的颜色
        UIColor *fillColor ;//渲染色，保留
        if (isRelaceToCance) {
            strokeColor=[UIColor colorWithRed:255/255.0 green:50/255.0 blue:50/255.0 alpha:strokeAlpha[i]];
            fillColor = [UIColor colorWithRed:219/255.0 green:11/255.0 blue:11/255.0 alpha:fillAlpha[i]];
        }
        else
        {
            strokeColor =  [UIColor colorWithRed:52/255.0 green:149/255.0 blue:225/255.0 alpha:strokeAlpha[i]];
            fillColor = [UIColor colorWithRed:19/255.0 green:153/255.0 blue:225/255.0 alpha:fillAlpha[i]];
        }
        
        CGRect rectangle = CGRectMake(self.center.x - radiusMAX[i],self.frame.size.height/2.f-radiusMAX[i]-100, radiusMAX[i]*2, radiusMAX[i]*2);
        
        CGPoint center= CGPointMake(rectangle.origin.x+rectangle.size.width/2, rectangle.origin.y+rectangle.size.height/2);
        
        if (i==0) {
            // 填充最里边的
            CGContextSetFillColorWithColor(context, fillColor.CGColor);//填充颜色
            CGContextSetLineWidth(context, 2.0);//线的宽度
            CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);//画笔线的颜色
            CGContextAddEllipseInRect(context, rectangle); //椭圆
            //kCGPathFill填充非零绕数规则,kCGPathEOFill表示用奇偶规则,kCGPathStroke路径,kCGPathFillStroke路径填充,kCGPathEOFillStroke表示描线，不是填充
            CGContextDrawPath(context, kCGPathFillStroke); //绘制路径加填充
            
            UIImage *image;
            if (isRelaceToCance) {
                image = [UIImage imageNamed:@"icon_remove"];
            }
            else
            {
                image = [UIImage imageNamed:@"icon_sound"];
            }
            
            
            //            CGRect rect = CGRectMake(center.x - image.size.width/2,center.y-image.size.height/2, image.size.width, image.size.height);
            
            // [image drawInRect:rect];//在坐标中画出图片
            [image drawAtPoint:CGPointMake(center.x - image.size.width/2,center.y-image.size.height/2)];//保持图片大小在point点开始画图片，可以把注释去掉看看
            // CGContextDrawImage(context,rect, image.CGImage);//使用这个使图片上下颠倒了，参考http://blog.csdn.net/koupoo/article/details/8670024
        }
        else
        {
            CGContextSetStrokeColorWithColor(context, fillColor.CGColor);//画笔线的颜色
            CGContextSetLineWidth(context,radiusMAX[i]-radiusMIN[i]);//线的宽度
            //void CGContextAddArc(CGContextRef c,CGFloat x, CGFloat y,CGFloat radius,CGFloat startAngle,CGFloat endAngle, int clockwise)1弧度＝180°/π （≈57.3°） 度＝弧度×180°/π 360°＝360×π/180 ＝2π 弧度
            // x,y为圆点坐标，radius半径，startAngle为开始的弧度，endAngle为 结束的弧度，clockwise 0为顺时针，1为逆时针。
            CGContextAddArc(context,center.x,center.y,  (radiusMAX[i]+radiusMIN[i])/2, 0, 2*PI, 0); //添加一个圆
            
            CGContextDrawPath(context, kCGPathStroke); //绘制路径
            
            CGContextSetLineWidth(context, 1.0);
            CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
            CGContextAddArc(context,center.x, center.y, radiusMAX[i], 0, 2*PI, 0); //添加一个圆
            
            CGContextDrawPath(context, kCGPathStroke); //绘制路径
        }
    }
    
    if (level<4) {
        int outlevel=level;
        UIColor *strokeColor ;//边的颜色
        UIColor *fillColor ;//渲染色，保留
        if (isRelaceToCance) {
            strokeColor=[UIColor colorWithRed:255/255.0 green:50/255.0 blue:50/255.0 alpha:strokeAlpha[outlevel]];
            fillColor = [UIColor colorWithRed:219/255.0 green:11/255.0 blue:11/255.0 alpha:fillAlpha[outlevel]];
        }
        else
        {
            strokeColor =  [UIColor colorWithRed:52/255.0 green:149/255.0 blue:225/255.0 alpha:strokeAlpha[outlevel]];
            fillColor = [UIColor colorWithRed:19/255.0 green:153/255.0 blue:225/255.0 alpha:fillAlpha[outlevel]];
        }
        
        float radiusMinout=radiusMIN[outlevel];
        
        float radiusMAXout=[self returnRadioWithMeter:meter]+50;
        CGRect rectangle = CGRectMake(self.center.x - radiusMAXout,self.frame.size.height/2.f-radiusMAXout-100, radiusMAXout*2, radiusMAXout*2);
        
        CGPoint center= CGPointMake(rectangle.origin.x+rectangle.size.width/2, rectangle.origin.y+rectangle.size.height/2);
        
        CGContextSetStrokeColorWithColor(context, fillColor.CGColor);//画笔线的颜色
        CGContextSetLineWidth(context,radiusMAXout-radiusMinout);//线的宽度
        //void CGContextAddArc(CGContextRef c,CGFloat x, CGFloat y,CGFloat radius,CGFloat startAngle,CGFloat endAngle, int clockwise)1弧度＝180°/π （≈57.3°） 度＝弧度×180°/π 360°＝360×π/180 ＝2π 弧度
        // x,y为圆点坐标，radius半径，startAngle为开始的弧度，endAngle为 结束的弧度，clockwise 0为顺时针，1为逆时针。
        CGContextAddArc(context,center.x,center.y,  (radiusMAXout+radiusMinout)/2, 0, 2*PI, 0); //添加一个圆
        
        CGContextDrawPath(context, kCGPathStroke); //绘制路径
        
        CGContextSetLineWidth(context, 1.0);
        CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
        CGContextAddArc(context,center.x, center.y, radiusMAXout, 0, 2*PI, 0); //添加一个圆
    }
    
    
    CGContextSaveGState(context);
    CGContextRestoreGState(context);
    
    //
    //    UIColor *gradientColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    //    UIColor *color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    //
    //    NSArray *gradientColors = [NSArray arrayWithObjects:
    //                               (id)fillColor.CGColor,
    //                               (id)gradientColor.CGColor, nil];
    //    CGFloat gradientLocations[] = {0, 1};
    //
    //    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    //
    //    UIBezierPath *border = [UIBezierPath bezierPathWithRoundedRect:hudRect cornerRadius:10.0];
    //
    //    CGContextSaveGState(context);
    //
    //    [border addClip];
    //    CGContextDrawRadialGradient(context, gradient,
    //                                CGPointMake(hudRect.origin.x+HUD_SIZE/2, 120), 10,
    //                                CGPointMake(hudRect.origin.x+HUD_SIZE/2, 195), hudRect.origin.y,
    //                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    //
    //    CGContextRestoreGState(context);
    //
    //    [strokeColor setStroke];
    //    border.lineWidth = 3.0;
    //    [border stroke];
    //    [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8] set];
    //    CGContextSetLineWidth(context, 3.0);
    //    CGContextSetLineJoin(context, kCGLineJoinRound);
    //
    //    int baseLine = hudRect.origin.y+50;
    //    int multiplier = 1;
    //    int maxLengthOfWave = 50;
    //    int maxValueOfMeter = 30;
    //    for(CGFloat x = SOUND_METER_COUNT - 1; x >= 0; x--) {
    //        multiplier = ((int)x % 2) == 0 ? 1 : -1;
    //
    //        CGFloat y = baseLine + ((maxValueOfMeter * (maxLengthOfWave - abs(soundMeters[(int)x]))) / maxLengthOfWave) * multiplier;
    //
    //        if(x == SOUND_METER_COUNT - 1) {
    //            CGContextMoveToPoint(context, x * (HUD_SIZE / SOUND_METER_COUNT) + hudRect.origin.x + 10, y);
    //            CGContextAddLineToPoint(context, x * (HUD_SIZE / SOUND_METER_COUNT) + hudRect.origin.x + 7, y);
    //        }
    //        else {
    //            CGContextAddLineToPoint(context, x * (HUD_SIZE / SOUND_METER_COUNT) + hudRect.origin.x + 10, y);
    //            CGContextAddLineToPoint(context, x * (HUD_SIZE / SOUND_METER_COUNT) + hudRect.origin.x + 7, y);
    //        }
    //    }
    //
    //    CGContextStrokePath(context);
    //
    //    [color setFill];
    //
    //    [[UIColor colorWithWhite:0.8 alpha:1.0] setFill];
}

@end
