ARCHS = armv7 arm64
include theos/makefiles/common.mk

TWEAK_NAME = KillSwitcher
KillSwitcher_FILES = Tweak.xm
KillSwitcher_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
