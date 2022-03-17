//
//  VoiceController.m
//

#import "VoiceController.h"

@interface VoiceController ()

@end

@implementation VoiceController

@synthesize callback;

@synthesize tickCount;
@synthesize isPausing;
@synthesize isPlaying;
@synthesize isRecording;

@synthesize buttonDone;
@synthesize buttonCancel;

@synthesize bottomVoice;
@synthesize bottomRecord;
@synthesize buttonRetake;
@synthesize buttonVoice;
@synthesize buttonRecord;

@synthesize tickLabel;
@synthesize chronometer;

@synthesize startDate;
@synthesize baseInterval;

@synthesize player, recorder, nameAs, saveURL;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor: [UIColor whiteColor]];

    CGRect boundsFrame = [self.view bounds];

    CGFloat imageWidth = 96.0;
    CGFloat imageHeight = 96.0;
    CGFloat buttonWidth = 120.0;
    CGFloat buttonHeight = 32.0;
    CGFloat timerHeight = TIMER_HEIGHT;

    CGRect ticksFrame = CGRectMake (0, 0, boundsFrame.size.width, timerHeight);
    tickLabel = [[UILabel alloc] initWithFrame : ticksFrame];
    [tickLabel setFont: [UIFont systemFontOfSize: 64.0]];
    tickLabel.textAlignment = NSTextAlignmentCenter;
    tickLabel.numberOfLines = 1;
    [tickLabel setText: @"00:00"];
    [tickLabel setTextColor: UIColorFromRGB (0x344c72)];

    [self.view addSubview: tickLabel];
    
    CGRect menuFrame = CGRectMake (0, boundsFrame.size.height - MENUBAR_HEIGHT, boundsFrame.size.width, MENUBAR_HEIGHT);
    
    // 보이스 메뉴바
    bottomVoice = [[UIView alloc] initWithFrame : menuFrame];
    [bottomVoice setBackgroundColor : [UIColor clearColor]];
    // [bottomVoice setBackgroundColor : [UIColor darkGrayColor]];
    [bottomVoice setCenter: CGPointMake (boundsFrame.size.width / 2.0, boundsFrame.size.height - menuFrame.size.height)];
    [self.view addSubview: bottomVoice];

    buttonRetake = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [buttonRetake setTitle: NSLocalizedString (@"action_retake", @"Retake") forState: UIControlStateNormal];
    [buttonRetake setFrame: CGRectMake (0, 0, buttonWidth, buttonHeight)];
    [buttonRetake setCenter: CGPointMake ((menuFrame.size.width / 3.0) * 0.5, menuFrame.size.height * 0.5)];
    [buttonRetake addTarget: self action: @selector (actionRetake) forControlEvents:  UIControlEventTouchUpInside];
    [bottomVoice addSubview: buttonRetake];

    buttonVoice = [UIButton buttonWithType: UIButtonTypeCustom];
    [buttonVoice setImage: [UIImage imageNamed: @"icon_200x200_voice_play.png"] forState: UIControlStateNormal];
    [buttonVoice setFrame: CGRectMake (0, 0, imageWidth, imageHeight)];
    [buttonVoice setCenter: CGPointMake (menuFrame.size.width * 0.5, menuFrame.size.height * 0.5)];
    [buttonVoice addTarget: self action: @selector (actionVoice) forControlEvents:  UIControlEventTouchUpInside];
    [bottomVoice addSubview: buttonVoice];

    buttonDone = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [buttonDone setTitle: NSLocalizedString (@"action_use_voice", @"Use Voice") forState: UIControlStateNormal];
    [buttonDone setFrame: CGRectMake (0, 0, buttonWidth, buttonHeight)];
    [buttonDone setCenter: CGPointMake ((menuFrame.size.width / 3.0) * 0.5 + (menuFrame.size.width / 3.0) * 2, menuFrame.size.height * 0.5)];
    [buttonDone addTarget: self action: @selector (actionDone) forControlEvents:  UIControlEventTouchUpInside];
    [bottomVoice addSubview: buttonDone];

    // 레코드 메뉴바
    bottomRecord = [[UIView alloc] initWithFrame : menuFrame];
    [bottomRecord setBackgroundColor : [UIColor clearColor]];
    // [bottomRecord setBackgroundColor : [UIColor lightGrayColor]];
    [bottomRecord setCenter: CGPointMake (boundsFrame.size.width / 2.0, boundsFrame.size.height - menuFrame.size.height)];
    // [bottomRecord setCenter: CGPointMake (boundsFrame.size.width / 2.0, boundsFrame.size.height - (menuFrame.size.height * 2))];
    [self.view addSubview: bottomRecord];

    buttonRecord = [UIButton buttonWithType: UIButtonTypeCustom];
    [buttonRecord setImage: [UIImage imageNamed: @"icon_200x200_record_start.png"] forState: UIControlStateNormal];
    [buttonRecord setFrame: CGRectMake (0, 0, imageWidth, imageWidth)];
    [buttonRecord setCenter: CGPointMake (menuFrame.size.width * 0.5, menuFrame.size.height * 0.5)];
    [buttonRecord addTarget: self action: @selector (actionVoiceRecord) forControlEvents:  UIControlEventTouchUpInside];
    [bottomRecord addSubview: buttonRecord];

    buttonCancel = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [buttonCancel setTitle: NSLocalizedString (@"action_cancel", @"Cancel") forState: UIControlStateNormal];
    [buttonCancel setFrame: CGRectMake (0, 0, buttonWidth, buttonHeight)];
    [buttonCancel setCenter: CGPointMake ((menuFrame.size.width / 3.0) * 0.5, menuFrame.size.height * 0.5)];
    [buttonCancel addTarget: self action: @selector (actionCancel) forControlEvents:  UIControlEventTouchUpInside];
    [bottomRecord addSubview: buttonCancel];

    // 최초엔 음성 녹음 대기중
    isPausing = NO;
    isPlaying = NO;
    isRecording = NO;
    baseInterval = 0;

    if (nil != chronometer) [chronometer invalidate]; chronometer = nil;

    [bottomVoice setHidden: YES];
    [bottomRecord setHidden: NO];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) actionDone
{
    [Allo i: @"actionDone @%@", [[self class] description]];

    @try
    {
        [self stopTimer];
        if (nil != player) [player stop];

        if (nil != self.callback)
        {
            long duration = tickCount / 10; if (1 > duration) duration = 1;

            // NSDictionary* info = [[NSDictionary alloc] init];
            NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys: [[saveURL path] lastPathComponent], @"name", [saveURL path], @"path", [NSString stringWithFormat: @"%ld", duration], @"duration", nil];

            /*
            NSString* filename  = [[saveURL description] lastPathComponent];
            NSData* data      = [NSData dataWithContentsOfFile: [saveURL path]];

            [Allo i: @"check data [%@][%@]", filename, [saveURL path]];
            [Allo i: @"check data [%@][%@]", nameAs, [saveURL description]];
            if (nil == data) [Allo i: @"check data path is nil"];
            if (nil != data) [Allo i: @"check data path [%lu]", [data length]];
            */

            [self.callback voiceControllerDidFinishWithInfo: info];
        }

    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) actionCancel
{
    [Allo i: @"actionCancel @%@", [[self class] description]];

    @try
    {
        [self stopRecord];
        [self stopTimer];

        if (nil != self.callback)
        {
            [self.callback voiceControllerDidCancel];
        }

    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) actionVoice
{
    [Allo i: @"actionVoice @%@", [[self class] description]];

    @try
    {
        if (isPlaying)
        {
            // 음성 플레이 상태에서 중단하기
            [self pauseVoice];
            [self pauseTimer];
        }
        else
        {
            // 대기중 상태에서 음성 플레이
            [self startVoice];
            [self startTimer];
        }
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) startVoice
{
    [Allo i: @"startVoice @%@", [[self class] description]];

    @try
    {
        if (!isPausing)
        {
            NSError *error;
            player = [[AVAudioPlayer alloc] initWithContentsOfURL: [self saveURL] error: &error];
            if (error) [Allo i: @"error %@", [error description]];
            player.delegate = self;
            // 볼륨을 크게 설정함
            player.volume = 1.0;
            {
                AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                [audioSession setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
                UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
                AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride),&audioRouteOverride);
            }
        }
        if (nil != player) [player play];
        [Allo i: @"startVoice #2 @%@", [[self class] description]];

        isPausing = NO;
        isPlaying = YES;

        [buttonVoice setImage: [UIImage imageNamed: @"icon_200x200_voice_stop.png"] forState: UIControlStateNormal];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) pauseVoice
{
    [Allo i: @"pauseVoice @%@", [[self class] description]];

    @try
    {
        isPlaying = NO;
        isPausing = YES;

        if (nil != player) [player stop];

        [buttonVoice setImage: [UIImage imageNamed: @"icon_200x200_voice_play.png"] forState: UIControlStateNormal];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) stopVoice
{
    [Allo i: @"stopVoice @%@", [[self class] description]];

    @try
    {
        isPlaying = NO;
        isPausing = NO;

        if (nil != player) [player stop];

        [buttonVoice setImage: [UIImage imageNamed: @"icon_200x200_voice_play.png"] forState: UIControlStateNormal];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}


- (void) actionRetake
{
    [Allo i: @"actionRetake @%@", [[self class] description]];
    
    @try
    {
        // 다시 음성 녹음 대기중
        isPausing = NO;
        isPlaying = NO;
        isRecording = NO;
        baseInterval = 0;

        if (nil != chronometer) [chronometer invalidate]; chronometer = nil;

        [bottomVoice setHidden: YES];
        [bottomRecord setHidden: NO];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}
- (void) actionVoiceRecord
{
    [Allo i: @"actionVoiceRecord @%@", [[self class] description]];

    @try
    {
        if (isRecording)
        {
            // 음성 녹음중 상태에서 녹음중단
            [self stopRecord];
            [self stopTimer];

            // 음성 녹음후 듣기 상태로 전환함
            [bottomVoice setHidden: NO];
            [bottomRecord setHidden: YES];
        }
        else
        {
            // 대기중 상태에서 음성 녹음시작
            [self startRecord];
            [self startTimer];
        }
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) startRecord
{
    [Allo i: @"startRecord @%@", [[self class] description]];

    @try
    {
        isRecording = YES;

        [self setupAndPrepareToRecord];
        // [recorder recordForDuration: 30];
        
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        [recorder record];

        [buttonRecord setImage: [UIImage imageNamed: @"icon_200x200_record_stop.png"] forState: UIControlStateNormal];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) stopRecord
{
    [Allo i: @"stopRecord @%@", [[self class] description]];

    @try
    {
        isRecording = NO;
        
        [recorder stop];
        [[AVAudioSession sharedInstance] setActive: NO error: nil];

        [buttonRecord setImage: [UIImage imageNamed: @"icon_200x200_record_start.png"] forState: UIControlStateNormal];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) startTimer
{
    [Allo i: @"startTimer @%@", [[self class] description]];
    
    @try
    {
        startDate = [NSDate date];
        if (nil == chronometer)
        {
            chronometer = [NSTimer scheduledTimerWithTimeInterval: 1.0 / 10.0
                                                         target: self
                                                         selector: @selector (updateTimer)
                                                         userInfo: nil
                                                         repeats: YES];
        }
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) stopTimer
{
    [Allo i: @"stopTimer @%@", [[self class] description]];
    
    @try
    {
        isPausing = NO;
        isPlaying = NO;
        baseInterval = 0;

        if (nil != chronometer) [chronometer invalidate]; chronometer = nil;
        
        CGFloat delay = 0.500;
        [self performSelector: @selector (clearTimer) withObject: nil afterDelay: delay];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) pauseTimer
{
    [Allo i: @"pauseTimer @%@", [[self class] description]];
    
    @try
    {
        isPlaying = NO;
        isPausing = YES;

        if (nil != chronometer) [chronometer invalidate]; chronometer = nil;

        NSDate *currentDate = [NSDate date];
        baseInterval = [currentDate timeIntervalSinceDate: startDate];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) clearTimer
{
    [Allo i: @"clearTimer @%@", [[self class] description]];
    
    @try
    {
        isPlaying = NO;
        isPausing = NO;

        baseInterval = 0;
        [tickLabel setText: @"00:00"];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) updateTimer
{
    [Allo i: @"updateTimer @%@", [[self class] description]];

    @try
    {
        tickCount++;
        NSDate *currentDate = [NSDate date];
        NSTimeInterval timeInterval = baseInterval + [currentDate timeIntervalSinceDate: startDate];
        NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970: timeInterval];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"mm:ss"];
        // [dateFormatter setDateFormat:@"mm:ss.SS"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT: 0.0]];
        NSString* timeString = [dateFormatter stringFromDate: timerDate];

        [tickLabel setText: timeString];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) setupAndPrepareToRecord
{
    [Allo i: @"setupAndPrepareToRecord @%@", [[self class] description]];

    @try
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error: nil];

        // settings for the recorder
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        
        // mp4 (mpeg4 audio)
        NSString* KOUP_VOICE_EXT = @".aac";
        NSString* KOUP_VOICE_PRE = @"KOUP-";
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"yyyyMMddHHmmss"];
        NSString* timeAs = [dateFormatter stringFromDate: [NSDate date]];
        
        [recordSetting setValue: [NSNumber numberWithInt: kAudioFormatMPEG4AAC] forKey: AVFormatIDKey];
        [recordSetting setValue: [NSNumber numberWithInt: 2] forKey: AVNumberOfChannelsKey];
        [recordSetting setValue: [NSNumber numberWithFloat: 44100.0] forKey: AVSampleRateKey];
        [recordSetting setValue: [NSNumber numberWithFloat: 192000.0] forKey: AVEncoderBitRateKey];
        // [recordSetting setValue: [NSNumber numberWithFloat: 128000.0] forKey: AVEncoderBitRateKey];

        nameAs = [NSString stringWithFormat: @"%@%@%@", KOUP_VOICE_PRE, timeAs, KOUP_VOICE_EXT];

        // 20200731 저장위치 점검요
        // NSDocumentDirectory
        // NSDownloadsDirectory
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   [NSString stringWithFormat: @"%@", [self nameAs]],
                                   nil];
        saveURL = [NSURL fileURLWithPathComponents: pathComponents];

        // initiate recorder
        NSError *error;
        recorder = [[AVAudioRecorder alloc] initWithURL: [self saveURL] settings: recordSetting error: &error];
        if (error) [Allo i: @"error %@", [error description]];
        recorder.meteringEnabled = YES;
        [recorder prepareToRecord];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer*) player successfully: (BOOL) flag
{
    [Allo i: @"audioPlayerDidFinishPlaying @%@", [[self class] description]];

    @try
    {
        [self stopVoice];
        [self stopTimer];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) viewWillLayoutSubviews
{
    [Allo i: @"viewWillLayoutSubviews @%@", [[self class] description]];

}

- (void) viewDidLayoutSubviews
{
    [Allo i: @"viewDidLayoutSubviews @%@", [[self class] description]];

}

// 20200710 디바이스 로테이션 지원을 위해 추가함
- (void) viewRearrange
{
    [Allo i: @"viewRearrange @%@", [[self class] description]];

    @try
    {
        CGRect boundsFrame = [self.view bounds];

        CGFloat imageWidth = 96.0;
        CGFloat imageHeight = 96.0;
        CGFloat buttonWidth = 120.0;
        CGFloat buttonHeight = 32.0;
        CGFloat timerHeight = TIMER_HEIGHT;

        [tickLabel setFrame: CGRectMake (0, 0, boundsFrame.size.width, timerHeight)];
        
        CGRect menuFrame = CGRectMake (0, boundsFrame.size.height - MENUBAR_HEIGHT, boundsFrame.size.width, MENUBAR_HEIGHT);
        
        // 보이스 메뉴바
        [bottomVoice setFrame: menuFrame];
        [bottomVoice setCenter: CGPointMake (boundsFrame.size.width / 2.0, boundsFrame.size.height - menuFrame.size.height)];

        [buttonRetake setFrame: CGRectMake (0, 0, buttonWidth, buttonHeight)];
        [buttonRetake setCenter: CGPointMake ((menuFrame.size.width / 3.0) * 0.5, menuFrame.size.height * 0.5)];

        [buttonVoice setFrame: CGRectMake (0, 0, imageWidth, imageHeight)];
        [buttonVoice setCenter: CGPointMake (menuFrame.size.width * 0.5, menuFrame.size.height * 0.5)];

        [buttonDone setFrame: CGRectMake (0, 0, buttonWidth, buttonHeight)];
        [buttonDone setCenter: CGPointMake ((menuFrame.size.width / 3.0) * 0.5 + (menuFrame.size.width / 3.0) * 2, menuFrame.size.height * 0.5)];

        // 레코드 메뉴바
        [bottomRecord setFrame: menuFrame];
        [bottomRecord setCenter: CGPointMake (boundsFrame.size.width / 2.0, boundsFrame.size.height - menuFrame.size.height)];

        [buttonRecord setFrame: CGRectMake (0, 0, imageWidth, imageWidth)];
        [buttonRecord setCenter: CGPointMake (menuFrame.size.width * 0.5, menuFrame.size.height * 0.5)];

        [buttonCancel setFrame: CGRectMake (0, 0, buttonWidth, buttonHeight)];
        [buttonCancel setCenter: CGPointMake ((menuFrame.size.width / 3.0) * 0.5, menuFrame.size.height * 0.5)];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (BOOL) shouldAutorotate
{
    [Allo i: @"shouldAutorotate isViewLoaded [%@] @%@", ([self isViewLoaded] ? @"YES" : @"NO"), [[self class] description]];

    if ([self isViewLoaded]) [self viewRearrange];
    
    return YES;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    [Allo i: @"supportedInterfaceOrientations @%@", [[self class] description]];

    // return UIInterfaceOrientationMaskAll;
    // return (UIInterfaceOrientationMaskPortraitUpsideDown);
    return (UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscape);
}

@end
