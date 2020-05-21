#include "SongShare.h"
//#include <RemoteLog.h>
#import <Cephei/HBPreferences.h>
#include <dlfcn.h>

bool enabled = true;
int shareService = 0;
bool askBeforeCopying = false;
bool displayNotifications = true;
bool pasteOrigURL = false;
bool wifiOnlyMode = false;

bool enabledAmazon = true;
bool enabledAppleMusic = true;
bool enabledDeezer = true;
bool enabledGooglePlay = true;
bool enabledNapster = true;
bool enabledSoundCloud = true;
bool enabledSpinrilla = true;
bool enabledSpotify = true;
bool enabledTidal = true;
bool enabledYandex = true;
bool enabledYouTube = true;

bool isPurchased = true;

NSString *lastURL = nil;

@implementation SongShare
// Setting the URLs to search for
+(NSMutableArray*)getEnabledHosts {
  NSMutableArray *enabledHosts = [NSMutableArray array];
  if (enabledAmazon) {
    [enabledHosts addObject:@"(https?://)?(music\\.|www\\.)?amazon.(com\\.br|ca|com\\.mx|com|cn|in|co\\.jp|sg|com\\.tr|ae|fr|de|it|nl|es|co\\.uk|com\\.au)/.+"];
  }
  if (enabledAppleMusic) {
    [enabledHosts addObject:@"(https?://)?music.apple.com/[a-zA-Z]{2}/(track|album|artist)/[a-zA-Z0-9-_]+/[0-9]+(/?)"];
    [enabledHosts addObject:@"(https?://)?itunes.apple.com/[a-zA-Z]{2}/(track|album|artist)/[a-zA-Z0-9-_]+/(id)?[0-9]+(/?)"];
  }
  if (enabledDeezer) {
    [enabledHosts addObject:@"(https?://)?(www\\.)?deezer.com/(track|album|artist)/[0-9]+(/?)"];
  }
  if (enabledGooglePlay) {
    [enabledHosts addObject:@"(https?://)?play.google.com(/?)(store)?/music/[a-zA-Z0-9-_]+(/?)"];
  }
  if (enabledNapster) {
    [enabledHosts addObject:@"(https?://)?([a-zA-Z]{2}\\.|www\\.)?napster.com/artist/[a-zA-Z0-9-_]+/.+"];
  }
  if (enabledSoundCloud) {
    // Thanks, only took a few modifications - https://github.com/RogerDeng/wire-ios/blob/32aac82a33d7075c628bbf1cdedb13dd00a832e8/Wire-iOS/Sources/UserInterface/Conversation/Content/Cells/Utility/LinkAttachment.m#L71
    [enabledHosts addObject:@"(https?://)?(www\\.|m\\.)?soundcloud.com/[a-zA-Z0-9-_]+(/?)"];
  }
  if (enabledSpinrilla) {
    [enabledHosts addObject:@"(https?://)?(www\\.)?spinrilla.com/(songs|mixtapes)/[a-zA-Z0-9-_]+(/?)"];
  }
  if (enabledSpotify) {
    // Thanks! - https://gist.github.com/fantattitude/3627354
    [enabledHosts addObject:@"(https?://(open|play).spotify.com/(track|artist|album)/[a-zA-Z0-9]+(/playlist/[a-zA-Z0-9]+|)|spotify:(track|artist|album):[a-zA-Z0-9]+(:playlist:[a-zA-Z0-9]+|))"];
  }
  if (enabledTidal) {
    [enabledHosts addObject:@"(https?://)?listen.tidal.com/(track|album|artist)/[0-9]+(/?)"];
  }
  if (enabledYandex) {
    [enabledHosts addObject:@"(https?://)?music.yandex.(com|ru)/(track|album|artist)/[0-9]+(/?)(track|album|artist)?([0-9]+?)(/?)"];
  }
  if (enabledYouTube) {
    // Thanks! - https://stackoverflow.com/a/39599314/5871303
    [enabledHosts addObject:@"(https?://)?(www\\.|m\\.|music\\.)?youtu(be\\.com|\\.be)(\\/watch\\?([&=a-z]{0,})(v=[\\d\\w]{1,}).+|\\/[\\d\\w]{1,})"];
  }
  return enabledHosts;
}

+(bool)tweakIsActive {
  // If enabled
  if (enabled && isPurchased && !wifiOnlyMode) {
    return true;
  // If enabled and connected to wi-fi
  } else if (enabled && wifiOnlyMode) {
    if ([[%c(Reachability) reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWiFi){
      //RLog(@"On WiFi...");
      return true;
    }
  }
  return false;
}

// Copy the new URL to the pasteboard and send a notification to our SpringBoard listener
+(void)copyNewStrToClipboard:(NSString*)newStr {
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  pasteboard.string = newStr;
  CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("dev.jeffresc.songshare-copyNotification"), nil, nil, true);
  //RLog(@"New link copied: %@", newStr);
}

// Run the call to the API service on the URL we determined is valid and matching our enabledHosts
+(void)runAPICall:(NSURL*)nsURL {
  //RLog(@"Comparing: %@ VS %@", nsURL.absoluteString, lastURL);
  if (![nsURL.absoluteString isEqualToString:lastURL]) {
    lastURL = nsURL.absoluteString;
    //RLog(@"Requesting URL: %@", nsURL.absoluteString);
    NSMutableURLRequest *urlRequest;
    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    switch(shareService) {
      case 0:
        urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.song.link/v1-alpha.1/links?url=%@&userCountry=%@", nsURL.absoluteString, countryCode]]];
        [urlRequest setHTTPMethod:@"GET"];
        break;
      case 1:
        urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://songwhip.com/?country=%@", countryCode]]];
        [urlRequest setHTTPMethod:@"POST"];
        NSData *data1 = [nsURL.absoluteString dataUsingEncoding:NSUTF8StringEncoding];
        [urlRequest setHTTPBody:data1];
        break;
    }
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
      if(httpResponse.statusCode == 200) {
          NSError *parseError = nil;
          NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
          NSString *newURLStr;
          switch(shareService) {
            case 0:
              newURLStr = [responseDictionary objectForKey:@"pageUrl"];
              break;
            case 1:
              newURLStr = [responseDictionary objectForKey:@"url"];
              break;
          }
          if (newURLStr) {
            NSString *copyString;
            if (pasteOrigURL) {
              copyString = [NSString stringWithFormat:@"%@ (%@)", newURLStr, nsURL.absoluteString];
            } else {
              copyString = newURLStr;
            }
            if (askBeforeCopying) {
              //RLog(@"Prompting user...");
              dispatch_async(dispatch_get_main_queue(), ^(void) {
                NSArray *existingWindowsReversed = [[[[[UIApplication sharedApplication] windows] reverseObjectEnumerator] allObjects] mutableCopy];
                UIWindow *alertWindow;
                for (int i = 0; i < [existingWindowsReversed count]; i++) {
                  UIWindow *uiWindow = existingWindowsReversed[i];
                  if (uiWindow.rootViewController != nil && uiWindow.hidden == NO) {
                    alertWindow = uiWindow;
                    break;
                  }
                }
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"SongShare" message:[NSString stringWithFormat:@"Would you like to add this URL to your clipboard?\n%@", newURLStr] preferredStyle:UIAlertControllerStyleAlert];
                alertController.view.tintColor = UIColorFromRGB(0x3498db);
                [alertController addAction:[UIAlertAction actionWithTitle:@"No, Thanks" style:UIAlertActionStyleCancel handler:nil]];
                [alertController addAction:[UIAlertAction actionWithTitle:@"Add To Clipboard" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                  [self copyNewStrToClipboard:newURLStr];
                }]];
                [alertWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
              });
            } else {
              [self copyNewStrToClipboard:newURLStr];
            }
          }
        }
    }];
    [dataTask resume];
  //} else {
    //RLog(@"Prevented user from requesting same URL twice...");
  }
}

// Validate URLs against our enabledHosts and expand npstr.com URLs so that we may pass them to the API (API only supports Napster.com URLs, not npstr.com)
+(void)validateURL:(NSURL*)url {
  //RLog(@"Validating with URL: %@", url.absoluteString);
  if (url && url.scheme && url.host) {
    NSArray *regexArray = [SongShare getEnabledHosts];
    //RLog(@"About to loop...");
    if (enabledNapster) {
      NSError *error = NULL;
      NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(https?://)npstr.cm/[a-zA-Z0-9]+" options:0 error:&error];
      NSArray *matches = [regex matchesInString:url.absoluteString options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, [url.absoluteString length])];
      NSUInteger matchCount = [matches count];
      if (matchCount) {
        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
        [urlRequest setHTTPMethod:@"HEAD"];
        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
          [self runAPICall:httpResponse.URL];
        }];
        [dataTask resume];
      }
    }
    for (int i = 0; i < [regexArray count]; i++) {
      NSError *error = NULL;
      NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexArray[i] options:0 error:&error];
      NSArray *matches = [regex matchesInString:url.absoluteString options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, [url.absoluteString length])];
      NSUInteger matchCount = [matches count];
      if (matchCount) {
        //RLog(@"Matched!");
        [self runAPICall:url];
      //} else {
        //RLog(@"Not a match (%d/%d)", i, [regexArray count]);
      }
    }
  //} else {
    //RLog(@"Not a URL, ignoring...");
  }
}

// Take the entire string and extract any URLs from it
+(void)wholeStringParser:(NSString*)string {
  // Thanks! - https://urlregex.com/ - https://stackoverflow.com/a/24631750/5871303
  NSError *error = NULL;
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+" options:0 error:&error];
  NSArray *matches = [regex matchesInString:string options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, [string length])];
  NSUInteger matchCount = [matches count];
  if (matchCount) {
    for (NSUInteger matchIdx = 0; matchIdx < matchCount; matchIdx++) {
        NSTextCheckingResult *match = [matches objectAtIndex:matchIdx];
        NSRange matchRange = [match range];
        NSString *result = [string substringWithRange:matchRange];
        [self validateURL:[NSURL URLWithString:result]];
    }
  //} else {
    //RLog(@"No URLs found in string");
  }
}

// Add an observer that is notified when a pasteboard update is made
+(void)addPasteboardObserver {
  if ([SongShare tweakIsActive]) {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIPasteboardChangedNotification object:pasteboard queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull notification) {
      // If it has URLs, preferably use those first
      if ([pasteboard hasURLs]) {
        NSArray *urls = [pasteboard URLs];
        for(int i = 0; i < [urls count]; i++) {
          [self validateURL:urls[i]];
          //RLog(@"URL directly from observer: %@", urls[i]);
        }
      // If no URLs are available, try strings next
      } else if ([pasteboard hasStrings]) {
        NSArray *strings = [pasteboard strings];
        for (int i = 0; i < [strings count]; i++) {
          //RLog(@"String directly from observer: %@", strings[i]);
          [self wholeStringParser:strings[i]];
        }
      }
  }];
  }
}
@end

// Send a notification to the URL letting them know the new URL has been copied to the pasteboard
static void sendNotification() {
  if (displayNotifications) {
    //RLog(@"Displaying notification!");
    void *handle = dlopen("/usr/lib/libnotifications.dylib", RTLD_LAZY);
    if (handle != NULL) {
      //RLog(@"Notification sent!");
      [%c(CPNotification) showAlertWithTitle:@"SongShare"
        message:@"SongShare URL has been copied to clipboard."
        userInfo:nil
        badgeCount:nil
        soundName:@"none"
        delay:1
        repeats:NO
        bundleId:@"dev.jeffresc.SongShareGUI"
      ];
      dlclose(handle);
    }
  }
}

// Load the preferences file and inject into SpringBoard and Applications only
// Add a copyNotification observer to the SpringBoard instance (where the notifications will be sent from)
%ctor {
	@autoreleasepool {
    HBPreferences *file = [[HBPreferences alloc] initWithIdentifier:@"dev.jeffresc.songshareprefs"];
    enabled = [([file objectForKey:@"kEnabled"] ?: @(YES)) boolValue];
    shareService = [([file objectForKey:@"shareService"] ?: @(0)) intValue];
    displayNotifications = [([file objectForKey:@"displayNotifications"] ?: @(YES)) boolValue];
    askBeforeCopying = [([file objectForKey:@"askBeforeCopying"] ?: @(NO)) boolValue];
    pasteOrigURL = [([file objectForKey:@"pasteOrigURL"] ?: @(NO)) boolValue];
    wifiOnlyMode = [([file objectForKey:@"wifiOnlyMode"] ?: @(NO)) boolValue];
    enabledAmazon = [([file objectForKey:@"enabledAmazon"] ?: @(YES)) boolValue];
    enabledAppleMusic = [([file objectForKey:@"enabledAppleMusic"] ?: @(YES)) boolValue];
    enabledDeezer = [([file objectForKey:@"enabledDeezer"] ?: @(YES)) boolValue];
    enabledGooglePlay = [([file objectForKey:@"enabledGooglePlay"] ?: @(YES)) boolValue];
    enabledNapster = [([file objectForKey:@"enabledNapster"] ?: @(YES)) boolValue];
    enabledSoundCloud = [([file objectForKey:@"enabledSoundCloud"] ?: @(YES)) boolValue];
    enabledSpinrilla = [([file objectForKey:@"enabledSpinrilla"] ?: @(YES)) boolValue];
    enabledSpotify = [([file objectForKey:@"enabledSpotify"] ?: @(YES)) boolValue];
    enabledTidal = [([file objectForKey:@"enabledTidal"] ?: @(YES)) boolValue];
    enabledYandex = [([file objectForKey:@"enabledYandex"] ?: @(YES)) boolValue];
    enabledYouTube = [([file objectForKey:@"enabledYouTube"] ?: @(YES)) boolValue];
    if (enabled && [SongShare tweakIsActive]) {
      NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
      NSUInteger count = args.count;
      if (count != 0) {
        NSString *executablePath = args[0];
        if (executablePath) {
          NSString *processName = [executablePath lastPathComponent];
          BOOL isSpringBoard = [processName isEqualToString:@"SpringBoard"];
          BOOL isApplication = [executablePath rangeOfString:@"/Application/"].location != NSNotFound || [executablePath rangeOfString:@"/Applications/"].location != NSNotFound;
          if (isSpringBoard) {
            //RLog(@"Adding observer for copyNotification on SpringBoard only");
            CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)sendNotification, CFSTR("dev.jeffresc.songshare-copyNotification"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
          }
          if (isSpringBoard || isApplication) {
            //RLog(@"Injecting into %@", processName);
            %init;
            [SongShare addPasteboardObserver];
          //} else {
            //RLog(@"Not injecting into %@", processName);
          }
        }
      }
    }
	}
}
