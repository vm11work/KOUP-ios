//
//  Allo.h
//

#import <Foundation/Foundation.h>
#import "ViewController.h"

// 배포 설정 (1 : 배포용, 0 : 개발용)
//2011108 김건엽 수정.
#ifdef  DEVELOP
#define RELEASE 0
#else
#define RELEASE 1
#endif

// 디버깅 설정 (YES : 로그 확인함, NO : 로그 무시함)
#define CUBE @"cube"
#define DEBUG_ECHO YES

#define RELEASE_COOKIE @"koup.kccworld.net"
#define RELEASE_SITE_ONLINE @"https://koup.kccworld.net"
//#define RELEASE_SITE_ONLINE @"https://vm11work.github.io/uploadtest-master/index.html"
#define RELEASE_SITE_OFFLINE @"index"
#define RELEASE_SITE_SET_DATA @"https://koup.kccworld.net/api/setdata"
#define RELEASE_SITE_SET_USERDEVICE @"https://koup.kccworld.net/api/setuserdevice"
#define RELEASE_SITE_SET_SIMPLELOGIN @"https://koup.kccworld.net/api/setsimplelogin"

#define SANDBOX_COOKIE @"koupdev.kccworld.net"
#define SANDBOX_SITE_ONLINE @"http://koupdev.kccworld.net"
#define SANDBOX_SITE_OFFLINE @"index"
#define SANDBOX_SITE_SET_DATA @"http://koupdev.kccworld.net/api/setdata"
#define SANDBOX_SITE_SET_USERDEVICE @"http://koupdev.kccworld.net/api/setuserdevice"
#define SANDBOX_SITE_SET_SIMPLELOGIN @"http://koupdev.kccworld.net/api/setsimplelogin"

#if (RELEASE)
    #define COOKIE RELEASE_COOKIE
    #define SITE_ONLINE RELEASE_SITE_ONLINE
    #define SITE_OFFLINE RELEASE_SITE_OFFLINE
    #define SITE_SET_DATA RELEASE_SITE_SET_DATA
    #define SITE_SET_USERDEVICE RELEASE_SITE_SET_USERDEVICE
    #define SITE_SET_SIMPLELOGIN RELEASE_SITE_SET_SIMPLELOGIN
#else
    #define COOKIE SANDBOX_COOKIE
    #define SITE_ONLINE SANDBOX_SITE_ONLINE
    #define SITE_OFFLINE SANDBOX_SITE_OFFLINE
    #define SITE_SET_DATA SANDBOX_SITE_SET_DATA
    #define SITE_SET_USERDEVICE SANDBOX_SITE_SET_USERDEVICE
    #define SITE_SET_SIMPLELOGIN SANDBOX_SITE_SET_SIMPLELOGIN
#endif

// 필요시 단위 기능 테스트 설정요
// (오프라인 모드 및 파일, 이미지, 음성녹취 업로드 등)

// 단위 기능 테스트
/*
#undef COOKIE
#define COOKIE @"[YOURHOST]"
#undef SITE_ONLINE
#define SITE_ONLINE @"[YOURHOST]/unitcase.htm"
#undef SITE_OFFLINE
#define SITE_OFFLINE @"index"
*/

// 참고 : 네이버 티비 모바일 UX 가 보기에도 인터렉션도 깔끔함
/*
#undef COOKIE
#define COOKIE @".naver.com"
#undef SITE_ONLINE
#define SITE_ONLINE @"https://m.tv.naver.com"
#undef SITE_OFFLINE
#define SITE_OFFLINE @"index"
*/

// 개인컴 테스트
/*
#undef COOKIE
#define COOKIE @"192.168.10.106"
#undef SITE_ONLINE
#define SITE_ONLINE @"http://192.168.10.106:8080"
#undef SITE_OFFLINE
#define SITE_OFFLINE @"index"
*/

#define DB_NAME @"KOUP.sqlite"
#define DB_TABLE @"KOUP"

#define APPS @"global-apps"
#define APPS_VALUE @"o" // 앱에서만 쿠키를 설정함 global-apps / app status : o for on
#define TYPE @"global-type"
#define TYPE_VALUE @"i" // 앱에서만 쿠키를 설정함 global-type / app type : i for ios
#define TYPE_SENDER @"APNS"
#define GUID @"global-guid" // 앱에서만 쿠키를 설정함, 앱 설치시 생성되는 unique id 이며 삭제후 재설치시 변경됨
#define GUID_VALUE @"global-guid-value" // 기본값 : o for on 
#define GUID_STATUS @"global-guid-status" // GUID 등록 상태, o for on, registered
#define DEVICE @"global-device"
#define CARRIER @"global-carrier"
#define BUILD @"global-build"
#define VERSION @"global-version"

#define OFFLINE @"global-offline"
#define USER @"write" // T_USER.SeqNo 정보며 로그인시 웹에서 설정함 (웹개발 이병운이 설정함)
#define ROLE @"frmDs" // TB_COMPANY_M.FRM_DS 정보며 로그인시 웹에서 설정함 (웹개발 고은지가 설정함, 1: 감리, 2: 협력업체, 3: KCC)
#define TOKEN @"global-token"
#define NUMBER @"global-number"

#define ACTION_EXEC @"app://action/exec"
#define ACTION_OPEN @"app://action/open"
#define ACTION_ROLE @"app://action/role"
#define ACTION_CHECK @"app://action/check"

#define ACTION_ONLINE @"app://action/online"
#define ACTION_OFFLINE @"app://action/offline"

#define ACTION_IMAGE_THUMB @"app://action/image/thumb"
#define ACTION_IMAGE_PHOTO @"app://action/image/photo"
#define ACTION_IMAGE_CAMERA @"app://action/image/camera"
#define ACTION_IMAGE_SUBMIT @"app://action/image/submit"

#define ACTION_VOICE_PLAY @"app://action/voice/play"
#define ACTION_VOICE_STOP @"app://action/voice/stop"
#define ACTION_VOICE_RECORD @"app://action/voice/record"
#define ACTION_VOICE_SUBMIT @"app://action/voice/submit"

#define ACTION_DATA_ALL @"app://action/data/all"
#define ACTION_DATA_DEL @"app://action/data/del"
#define ACTION_DATA_GET @"app://action/data/get"
#define ACTION_DATA_SET @"app://action/data/set"
#define ACTION_DATA_LIST @"app://action/data/list"
#define ACTION_DATA_SUBMIT @"app://action/data/submit"

#define ACTION_OFFLINE_VOICE_GET @"app://action/offline/voice/get"
#define ACTION_OFFLINE_VOICE_SET @"app://action/offline/voice/set"
#define ACTION_OFFLINE_PHOTO_GET @"app://action/offline/photo/get"
#define ACTION_OFFLINE_PHOTO_SET @"app://action/offline/photo/set"
#define ACTION_OFFLINE_CAMERA_GET @"app://action/offline/camera/get"
#define ACTION_OFFLINE_CAMERA_SET @"app://action/offline/camera/set"

// div 등으로 틀이 상단에 고정된 형태의 ux 를 사용한다면 항상 0 만 리턴함
#define SCRIPT_SCROLL_Y @"javascript: window.scrollY;"
// #define SCRIPT_SCROLL_Y @"javascript: $('.LayerWebContent').scrollTop ();"

#define SCRIPT_EXEC_EVAL @"JExec.evaluate ();"

#define SCRIPT_CONFIG_OFFLINE @"javascript: JNative.init ({ mode : false, apps : \"o\", type : \"i\", guid : \"ios-guid\", user : \"ios-user\" });"

#define SCRIPT_ROLE_CALLBACK @"javascript: try{var status = #STATUS#;var response=\"#RESPONSE#\";JRole.delegate(status, response)}catch(e){console.log(e)}"

#define SCRIPT_DATA_EVAL @"JData.evaluate ();"
#define SCRIPT_DATA_CALLBACK @"javascript: try{var status = #STATUS#;var response=\"#RESPONSE#\";JData.delegate(status, response)}catch(e){console.log(e)}"

#define SCRIPT_IMAGE_EVAL @"JImage.evaluate ();"
#define SCRIPT_IMAGE_CALLBACK @"javascript: try{var status = #STATUS#;var response=\"#RESPONSE#\";JImage.delegate(status, response)}catch(e){console.log(e)}"

#define SCRIPT_VOICE_EVAL @"JVoice.evaluate ();"
#define SCRIPT_VOICE_CALLBACK @"javascript: try{var status = #STATUS#;var response=\"#RESPONSE#\";JVoice.delegate(status, response)}catch(e){console.log(e)}"

// #define SCRIPT_VOICE_RECORD_ERROR @"javascript: try{var response=\"#RESPONSE#\";VoiceRecord.error(response)}catch(e){console.log(e)}"
// #define SCRIPT_VOICE_RECORD_SUCCESS @"javascript: try{var response=\"#RESPONSE#\";VoiceRecord.success(response)}catch(e){console.log(e)}"

// #define SCRIPT_VOICE_SUBMIT_ERROR @"javascript: try{VoiceSubmit.error()}catch(e){console.log(e)}"
// #define SCRIPT_VOICE_SUBMIT_SUCCESS @"javascript: try{var response=\"#RESPONSE#\";VoiceSubmit.success(response)}catch(e){console.log(e)}"

#define CSCROLL_UP_DETECT (101)
#define CSCROLL_DOWN_DETECT (201)
#define CSCROLL_HITTOP_DETECT (-200) // 20200813 폰 및 패드에서 테스트해본바 -200이 적합함

// 20200812 원본값 #define CSCROLL_HITTOP_DETECT (-80)

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
                 blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
                alpha:1.0]

@interface Allo : NSObject

+ (void) i: (NSString*) format, ...;
+ (void) t: (NSString*) format, ...;
// 디버그 모드 상관 없이 토스트
+ (void) toast: (NSString*) format, ...;

@end
