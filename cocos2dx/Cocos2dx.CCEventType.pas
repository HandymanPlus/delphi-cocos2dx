unit Cocos2dx.CCEventType;

interface

(**
 * This header is used for defining event types using in CCNotificationCenter
 *)

// The application will come to foreground.
// This message is used for reloading resources before come to foreground on Android.
// This message is posted in main.cpp.
const EVENT_COME_TO_FOREGROUND  =  'event_come_to_foreground';

// The application will come to background.
// This message is used for doing something before coming to background, such as save CCRenderTexture.
// This message is posted in cocos2dx/platform/android/jni/MessageJni.cpp.
const EVENT_COME_TO_BACKGROUND  =  'event_come_to_background';



implementation

end.
