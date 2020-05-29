#include "SongShareRootListController.h"
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBPreferences.h>
#import <Preferences/PSSpecifier.h>
#import <CepheiPrefs/HBRootListController.h>
#import <Cephei/HBRespringController.h>
#include <spawn.h>

@implementation SongShareRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}
	return _specifiers;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tintColor = UIColorFromRGB(0x2980b9);
        appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithWhite:0 alpha:0];
        self.hb_appearanceSettings = appearanceSettings;
				self.respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(respring:)];
        self.respringButton.tintColor = UIColorFromRGB(0x3498db);
				self.navigationItem.rightBarButtonItem = self.respringButton;
    }
    return self;
}

- (void)respring:(id)sender {
    [HBRespringController respringAndReturnTo:[NSURL URLWithString:@"prefs:root=SongShare"]];
}

- (void)twitterLink {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/JeffRescignano"]];
}

- (void)Website_Link {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://jeffresc.dev/"]];
}

- (void)sourceCode {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/JeffResc/SongShare"]];
}

- (void)donateViaPayPal {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/JeffRescignano"]];
}

-(void)legalLink {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://jeffresc.dev/legal/SongShare"]];
}

-(void)informationLink {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://repo.dynastic.co/package/dev.jeffresc.songshare"]];
}
@end
