#import <React/RCTViewManager.h>
@import JitsiMeetSDK;

@interface RNJitsiMeetViewManager : RCTViewManager <JitsiMeetViewDelegate>
- (void)setMeetOptions:(NSDictionary *)meetOptions forBuilder:(JitsiMeetConferenceOptionsBuilder *)builder withServerConf:(NSDictionary *)serverConf andUserInfo:(JitsiMeetUserInfo *)_userInfo;
- (void)setMeetFeatureFlags:(NSDictionary *)meetFeatureFlags forBuilder:(JitsiMeetConferenceOptionsBuilder *)builder;
@property (nonatomic) BOOL isPip;
@property (nonatomic, strong) NSMutableDictionary *eventSentFlags;
@end
