WORKSPACE ?= VelocidiSDK.xcworkspace
TEST_SDK ?= 15.2
TEST_DEVICE ?= iPad Pro (12.9-inch) (4th generation)

XCARGS := -workspace $(WORKSPACE) \
					-sdk "iphonesimulator" \
					-destination "platform=iOS Simulator,OS=$(TEST_SDK),name=$(TEST_DEVICE)" \
					GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO

build:
	set -o pipefail && xcodebuild $(XCARGS) -scheme VelocidiSDK build | xcpretty

format:
	clang-format -style=file -i VelocidiSDK/**/*.m VelocidiSDK/**/*.h && \
	clang-format -style=file -i Examples/ObjcExample/**/*.m Examples/ObjcExample/**/*.h

# we have to clean schemas independently because xcode does not allow to clean all schemes in a workspace
clean:
	xcodebuild $(XCARGS) -scheme VelocidiSDK clean | xcpretty && \
	xcodebuild $(XCARGS) -scheme ObjcExample clean | xcpretty && \
	xcodebuild $(XCARGS) -scheme SwiftExample clean | xcpretty

test: build
	set -o pipefail && xcodebuild $(XCARGS) -scheme VelocidiSDK test | xcpretty

examples: install-examples build-objc-example build-swift-example

install-examples: install build
	pod install --project-directory=Examples/

build-objc-example: install-examples
	set -o pipefail && xcodebuild $(XCARGS) -scheme ObjcExample clean build | xcpretty

build-swift-example: install-examples
	set -o pipefail && xcodebuild $(XCARGS) -scheme SwiftExample clean build | xcpretty

install:
	pod install

prerequisites:
	.scripts/prerequisites.sh

oclint-examples: install-examples
	set -o pipefail && \
	xcodebuild -scheme ObjcExample $(XCARGS) COMPILER_INDEX_STORE_ENABLE=NO clean build | xcpretty -r json-compilation-database --output compile_commands.json && \
	oclint-json-compilation-database -exclude Pods -exclude build -- -report-type xcode

oclint:
	set -o pipefail && \
	xcodebuild -scheme VelocidiSDK $(XCARGS) COMPILER_INDEX_STORE_ENABLE=NO clean build | xcpretty -r json-compilation-database --output compile_commands.json && \
	oclint-json-compilation-database -exclude Pods -exclude build -- -report-type xcode

swiftlint:
	Pods/SwiftLint/swiftlint lint --fix && Pods/SwiftLint/swiftlint lint --strict

podlint:
	pod lib lint --verbose

test-all: test examples oclint oclint-examples podlint
