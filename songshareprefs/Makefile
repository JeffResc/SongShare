# Thank you to Dave van Wijk and QuitAll for providing a beautiful preferences bundle
# https://github.com/vanwijkdave/QuitAll

include $(THEOS)/makefiles/common.mk
ARCHS = armv7 arm64 arm64e

BUNDLE_NAME = songshareprefs
songshareprefs_FILES = swcRootListController.m zodiacs.m
songshareprefs_INSTALL_PATH = /Library/PreferenceBundles
songshareprefs_FRAMEWORKS = UIKit
songshareprefs_PRIVATE_FRAMEWORKS = Preferences
songshareprefs_CFLAGS = -fobjc-arc
songshareprefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/songshareprefs.plist$(ECHO_END)
