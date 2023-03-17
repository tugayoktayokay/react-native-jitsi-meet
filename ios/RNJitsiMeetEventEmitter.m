//
//  RNJitsiMeetEventEmitter.m
//  react-native-jitsi-meet
//
//  Created by Tugay Oktay Okay on 16.03.2023.
//

#import "RNJitsiMeetEventEmitter.h"

@implementation RNJitsiMeetEventEmitter

RCT_EXPORT_MODULE(RNJitsiMeetEventEmitter);

- (NSArray<NSString *> *)supportedEvents {
    return @[@"onConferenceJoined", @"onConferenceTerminated", @"onConferenceWillJoin",@"onEnterPictureInPicture"];
}

@end
