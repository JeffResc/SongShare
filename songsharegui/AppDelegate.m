#import "AppDelegate.h"
#include <RemoteLog.h>

@interface AppDelegate ()
@end

@implementation AppDelegate
- (void)openPrivateURL:(NSURL *)url {

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [[NSClassFromString(@"LSApplicationWorkspace") defaultWorkspace] openSensitiveURL:[NSURL URLWithString:@"Prefs:root=SongShare"] withOptions:nil];
  exit(0);
  return YES;
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
  [[NSClassFromString(@"LSApplicationWorkspace") defaultWorkspace] openSensitiveURL:[NSURL URLWithString:@"Prefs:root=SongShare"] withOptions:nil];
  exit(0);
}
@end
