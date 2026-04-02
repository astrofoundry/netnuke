CURRENT_VERSION := $(shell git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
MAJOR := $(shell echo $(CURRENT_VERSION) | sed 's/v//' | cut -d. -f1)
MINOR := $(shell echo $(CURRENT_VERSION) | sed 's/v//' | cut -d. -f2)
PATCH := $(shell echo $(CURRENT_VERSION) | sed 's/v//' | cut -d. -f3)

.PHONY: release-major release-minor release-patch _release build

build:
	xcodebuild -scheme NetNuke -configuration Release build

release-major:
	$(eval NEW_VERSION := v$(shell echo $$(($(MAJOR)+1))).0.0)
	@$(MAKE) _release VERSION=$(NEW_VERSION)

release-minor:
	$(eval NEW_VERSION := v$(MAJOR).$(shell echo $$(($(MINOR)+1))).0)
	@$(MAKE) _release VERSION=$(NEW_VERSION)

release-patch:
	$(eval NEW_VERSION := v$(MAJOR).$(MINOR).$(shell echo $$(($(PATCH)+1))))
	@$(MAKE) _release VERSION=$(NEW_VERSION)

_release:
	@echo "Releasing $(VERSION) (was $(CURRENT_VERSION))"
	@sed -i '' 's|<string>[0-9]*\.[0-9]*\.[0-9]*</string>|<string>'"$$(echo $(VERSION) | sed 's/v//')"'</string>|' NetNuke/Info.plist
	@git add NetNuke/Info.plist
	@git commit -m "Bump version to $(VERSION)"
	@git tag $(VERSION)
	@git push origin main --tags
	@echo "$(VERSION) pushed — GitHub Actions will build the DMG"
