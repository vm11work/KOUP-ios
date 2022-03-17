//
//  VoiceDelegate.h
//

#ifndef VoiceDelegate_h
#define VoiceDelegate_h

@protocol VoiceDelegate

@optional
- (void) voiceControllerDidCancel;
- (void) voiceControllerDidFinishWithInfo: (NSDictionary*) info;
- (void) voiceControllerDidFinishWithError: (NSError*) error;
@end

#endif /* VoiceDelegate_h */
