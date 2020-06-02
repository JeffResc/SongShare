PACKAGE_VERSION = 1.0.1
DEBUG = 0
ARCHS = armv7 arm64 arm64e
include $(THEOS)/makefiles/common.mk
INSTALL_TARGET_PROCESSES = SpringBoard

TWEAK_NAME = SongShare
SongShare_FILES = SongShare.xm
SongShare_FRAMEWORKS = CoreServices
SongShare_PRIVATE_FRAMEWORKS = UIKitCore
SongShare_CFLAGS = -fobjc-arc
SongShare_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += songshareprefs
SUBPROJECTS += songsharegui
include $(THEOS_MAKE_PATH)/aggregate.mk
