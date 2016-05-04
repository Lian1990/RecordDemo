//
//  ViewController.m
//  RecordDemo
//
//  Created by LIAN on 16/5/4.
//  Copyright © 2016年 com.Alice. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong,nonatomic) UIButton *playBtn;
@property (strong,nonatomic) UIButton *recordBtn;
@property (strong,nonatomic) UIButton *stopBtn;
@property (strong,nonatomic) NSTimer  *myTimer;
@property (strong,nonatomic) AVAudioRecorder *audioRecorder;
@property (strong,nonatomic) AVAudioPlayer   *audioPlayer;

@end

@implementation ViewController

#define TIME_LIMIT  10
#define DOCFILE  @"test3.caf"

@synthesize playBtn = _playBtn;
@synthesize recordBtn = _recordBtn;
@synthesize myTimer = _myTimer;
@synthesize audioRecorder = _audioRecorder;
@synthesize audioPlayer = _audioPlayer;

@synthesize stopBtn = _stopBtn;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self buildStage];
    [self setAudioSession];
}
-(void)buildStage
{
    _playBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _playBtn.frame = CGRectMake(20, 100, 200, 50);
    [_playBtn setTitle:@"PLAY" forState:UIControlStateNormal];
    [_playBtn setBackgroundColor:[UIColor greenColor]];
    [_playBtn addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside] ;
    [self.view addSubview:_playBtn];
    
    _recordBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _recordBtn.frame = CGRectMake(20, 160, 200, 50);
    [_recordBtn setTitle:@"RECORD" forState:UIControlStateNormal];
    [_recordBtn setBackgroundColor:[UIColor greenColor]];
    [_recordBtn addTarget:self action:@selector(recordClickStart:) forControlEvents:UIControlEventTouchDown];
        [_recordBtn addTarget:self action:@selector(recordClickStop:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_recordBtn];
    
    _stopBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _stopBtn.frame = CGRectMake(20, 220, 200, 50);
    [_stopBtn setTitle:@"Stop" forState:UIControlStateNormal];
    [_stopBtn setBackgroundColor:[UIColor greenColor]];
    [_stopBtn addTarget:self action:@selector(recordClickStop:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_stopBtn];
    
}
-(void)playClick:(id)sender
{
    NSLog(@"play");
    NSString *docPaths = [[self documentPath]stringByAppendingPathComponent:DOCFILE];
    NSURL *audioURL = [NSURL fileURLWithPath:docPaths];
    NSError *err;
    _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:audioURL error:&err];
    _audioPlayer.delegate = self;
    if (err) {
        NSLog(@"error is %@",err);
    }
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
    
    NSLog(@"路径是 %@",docPaths);
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"play finish !!!");
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error
{
    NSLog(@"fail error is %@",error);
}
-(void)recordClickStart:(id)sender
{
    NSLog(@"start record");
    if (!_myTimer) {
        _myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeCount) userInfo:nil repeats:YES];
        
    }
    else
    {
        [_myTimer fire];
    }
    [self statrRecord];
}
-(void)timeCount
{
    static int count = 0 ;
    count++;
    if (count >= TIME_LIMIT) {
        [self recordClickStop:_recordBtn];
        count = 0;
        [self stopRecord];
    }
    NSLog(@"start record count is  %d",count);
}
-(void)recordClickStop:(id)sender
{
    NSLog(@"stop record");
    if ([_myTimer isValid]) {
        [_myTimer invalidate];
        _myTimer = nil;
    }
    [self stopRecord];
}

-(void)setAudioSession{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}
#pragma mark ====  录音

-(NSString *)documentPath
{
    NSArray *ary = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [ary objectAtIndex:0];
    return path;
}
/*
 1.AVNumberOfChannelsKey 通道数 通常为双声道 值2
 2.AVSampleRateKey 采样率 单位HZ 通常设置成44100 也就是44.1k
 3.AVLinearPCMBitDepthKey 比特率 8 16 24 32
 4.AVEncoderAudioQualityKey 声音质量
 ① AVAudioQualityMin  = 0, 最小的质量
 ② AVAudioQualityLow  = 0x20, 比较低的质量
 ③ AVAudioQualityMedium = 0x40, 中间的质量
 ④ AVAudioQualityHigh  = 0x60,高的质量
 ⑤ AVAudioQualityMax  = 0x7F 最好的质量
 5.AVEncoderBitRateKey 音频编码的比特率 单位Kbps 传输的速率 一般设置128000 也就是128kbps
 
 */
-(void)statrRecord
{
    //设置录音格式
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                              [NSNumber numberWithFloat:44100],AVSampleRateKey,
                              [NSNumber numberWithInt:2],AVNumberOfChannelsKey,
                              [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                              [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey,
                              [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                              [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
//                              @128000,AVEncoderBitRateKey,
                              nil];
    
    NSString *docPath = [[self documentPath]stringByAppendingPathComponent:DOCFILE];
    
    NSLog(@"路径是 %@",docPath);
    
    NSURL *recorderURL = [NSURL fileURLWithPath:docPath];
    NSError *recorderr = nil;
    if (!_audioRecorder) {
        _audioRecorder = [[AVAudioRecorder alloc]initWithURL:recorderURL settings:settings error:&recorderr];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES; //是否启用录音测量，如果启用录音测量可以获得录音分贝等数据信息
        [_audioRecorder record];
    }
    else
    {
        [_audioRecorder record];
    }
    
    
    if (recorderr) {
        NSLog(@"创建录音机对象时发生错误，错误信息：%@",recorderr.localizedDescription);
        return;
    }
}

//录音成功
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"录音成功");
}
//录音失败
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"录音失败");
}
-(void)stopRecord
{
    [self.audioRecorder stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
