#import <UIKit/UIKit.h>

typedef enum {
    ReachableViaWiFi
} ConnectionType;

@interface Reachability
+(id)reachabilityForInternetConnection; // iOS 9 - 13.1.3
-(long long)currentReachabilityStatus; // iOS 9 - 13.1.3
@end

@interface UIPasteboard (SongShare)
+(id)generalPasteboard; // iOS 4 - 11.1.2 & iOS 12.1 - 13.1.3
-(BOOL)hasStrings; // iOS 10.1.1 - 11.1.2 & iOS 12.1 - 13.1.3
-(NSArray *)strings; // iOS 6 - 11.1.2 & iOS 12.1 - 13.1.3
-(BOOL)hasURLs; // iOS 10.1.1 - 11.1.2 & iOS 12.1 - 13.1.3
-(NSArray *)URLs; // iOS 6 - 11.1.2 & iOS 12.1 - 13.1.3
@end

@interface SongShare : NSObject
+(NSMutableArray*)getEnabledHosts;
+(bool)tweakIsActive;
+(void)copyNewStrToClipboard:(NSString*)newStr;
+(void)runAPICall:(NSURL*)nsURL;
+(void)validateURL:(id)url;
+(void)addPasteboardObserver;
+(void)wholeStringParser:(NSString*)urlStr;
@end

// Thanks! - https://stackoverflow.com/a/3532264/5871303
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface CPNotification : NSObject // iOS 10
+(void)showAlertWithTitle:(NSString*)title message:(NSString*)message userInfo:(NSDictionary*)userInfo badgeCount:(int)badgeCount soundName:(NSString*)soundName delay:(double)delay repeats:(BOOL)repeats bundleId:(NSString*)bundleId;
@end
