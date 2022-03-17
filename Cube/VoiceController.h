//
//  VoiceController.h
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "Allo.h"
#import "UIView+Toast.h"
#import "NSString+Addtions.h"
#import "VoiceDelegate.h"

NS_ASSUME_NONNULL_BEGIN

#define TIMER_HEIGHT 120
#define MENUBAR_HEIGHT 144

@interface VoiceController : UIViewController <VoiceDelegate, AVAudioPlayerDelegate>

@property (assign) id <VoiceDelegate> callback;

@property (readwrite) long tickCount;
@property (readwrite) BOOL isPausing;
@property (readwrite) BOOL isPlaying;
@property (readwrite) BOOL isRecording;

@property (nonatomic, retain) UIView* bottomVoice;
@property (nonatomic, retain) UIView* bottomRecord;
@property (nonatomic, retain) UIButton* buttonDone;
@property (nonatomic, retain) UIButton* buttonCancel;
@property (nonatomic, retain) UIButton* buttonRetake;
@property (nonatomic, retain) UIButton* buttonVoice;
@property (nonatomic, retain) UIButton* buttonRecord;

@property (nonatomic)     AVAudioPlayer       *player;
@property (nonatomic)     AVAudioRecorder     *recorder;
@property (nonatomic)     NSString            *nameAs;
@property (nonatomic)     NSURL               *saveURL;

@property (nonatomic, retain) UILabel* tickLabel;
@property (nonatomic, retain) NSTimer* chronometer;

@property (nonatomic, retain) NSDate* startDate;
@property (readwrite) NSTimeInterval baseInterval;

@end

NS_ASSUME_NONNULL_END
