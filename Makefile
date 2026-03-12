SCHEME = SeeMyIP
DERIVED_DATA = $(HOME)/Library/Developer/Xcode/DerivedData
DERIVED_DIR = $(shell ls -td $(DERIVED_DATA)/$(SCHEME)-* 2>/dev/null | head -1)
BUILD_DIR = $(DERIVED_DIR)/Build/Products
SPARKLE_BIN = $(shell find $(DERIVED_DATA) -path "*/sparkle/Sparkle/bin" -maxdepth 6 -type d 2>/dev/null | head -1)
VERSION = $(shell /usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" SeeMyIP/Resources/Info.plist)
BUILD_NUMBER = $(shell /usr/libexec/PlistBuddy -c "Print CFBundleVersion" SeeMyIP/Resources/Info.plist)
ZIP_NAME = $(SCHEME)-v$(VERSION).zip

.PHONY: build release run kill rerun clean sign appcast bump help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

build: ## Build Debug configuration
	xcodebuild -scheme $(SCHEME) -configuration Debug build | tail -3

release: ## Build Release configuration
	xcodebuild -scheme $(SCHEME) -configuration Release build | tail -3

DEV_APP = $(SCHEME)-Dev

run: build ## Build and run the app
	@pkill -x $(DEV_APP) 2>/dev/null || true
	@sleep 1
	open "$(BUILD_DIR)/Debug/$(DEV_APP).app"

kill: ## Kill running app
	@pkill -x $(DEV_APP) 2>/dev/null && echo "$(DEV_APP) killed" || echo "$(DEV_APP) not running"

rerun: ## Kill and rerun the app
	@pkill -x $(DEV_APP) 2>/dev/null || true
	@sleep 1
	open "$(BUILD_DIR)/Debug/$(DEV_APP).app"

clean: ## Clean build artifacts
	xcodebuild -scheme $(SCHEME) clean | tail -3
	rm -f /tmp/$(ZIP_NAME)

resolve: ## Resolve SPM package dependencies
	xcodebuild -scheme $(SCHEME) -resolvePackageDependencies | tail -5

zip: release ## Create release zip
	cd "$(BUILD_DIR)/Release" && ditto -c -k --keepParent $(SCHEME).app /tmp/$(ZIP_NAME)
	@echo "Created /tmp/$(ZIP_NAME) ($$(stat -f%z /tmp/$(ZIP_NAME)) bytes)"

sign: zip ## Sign release zip with Sparkle EdDSA key
	@$(SPARKLE_BIN)/sign_update /tmp/$(ZIP_NAME)

dist: sign ## Create GitHub Release (usage: make dist TAG=v0.2)
	@if [ -z "$(TAG)" ]; then echo "Usage: make dist TAG=v0.x"; exit 1; fi
	gh release create $(TAG) /tmp/$(ZIP_NAME) \
		--title "$(TAG)" \
		--notes "See My IP $(TAG)"
	@echo "\nRelease: https://github.com/clover4282/see-my-ip/releases/tag/$(TAG)"

appcast: ## Show appcast item template for current version
	@echo '<item>'
	@echo '  <title>v$(VERSION)</title>'
	@echo '  <pubDate>'$$(date -R)'</pubDate>'
	@echo '  <sparkle:version>$(BUILD_NUMBER)</sparkle:version>'
	@echo '  <sparkle:shortVersionString>$(VERSION)</sparkle:shortVersionString>'
	@echo '  <sparkle:minimumSystemVersion>14.0</sparkle:minimumSystemVersion>'
	@echo '  <enclosure url="https://github.com/clover4282/see-my-ip/releases/download/v$(VERSION)/$(ZIP_NAME)"'
	@echo '             type="application/octet-stream"'
	@if [ -f /tmp/$(ZIP_NAME) ]; then \
		echo "             $$($(SPARKLE_BIN)/sign_update /tmp/$(ZIP_NAME)) />"; \
	else \
		echo '             sparkle:edSignature="" length="" />'; \
		echo "(run 'make sign' first to get signature)"; \
	fi
	@echo '</item>'

bump: ## Bump version (usage: make bump V=0.2)
	@if [ -z "$(V)" ]; then echo "Usage: make bump V=0.x"; exit 1; fi
	@build="$${B:-$$(($(BUILD_NUMBER) + 1))}"; \
	/usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString $(V)" SeeMyIP/Resources/Info.plist && \
	/usr/libexec/PlistBuddy -c "Set CFBundleVersion $$build" SeeMyIP/Resources/Info.plist && \
	echo "Version bumped to $(V) ($$build)"

info: ## Show current build info
	@echo "Version:    $(VERSION)"
	@echo "Build:      $(BUILD_NUMBER)"
	@echo "Scheme:     $(SCHEME)"
	@echo "Derived:    $(DERIVED_DIR)"
	@echo "Build dir:  $(BUILD_DIR)"
	@echo "Sparkle:    $(SPARKLE_BIN)"
