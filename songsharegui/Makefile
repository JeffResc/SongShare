# This is a fake application in order to display notifications with our icon and add ourself to the share sheet
include $(THEOS)/makefiles/common.mk
ARCHS = armv7 arm64 arm64e

APPLICATION_NAME = SongShare
SongShare_FILES = $(wildcard *.m)
SongShare_FRAMEWORKS = UIKit CoreGraphics
SongShare_CODESIGN_FLAGS = -Sent.xml
SongShare_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall \"SongShareGUI\"" || true
	install.exec "uicache"
