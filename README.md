# Mocha

An umbrella framework replacement for Cocoa with category-based additions, extensions, and fixes.

The framework as a whole is still very **experimental** and should be used with caution, but a majority of its extensions and fixes are bug-proof.

## Features

- CG/NS-style bridging in `NSAffineTransform`, `NSImage`, `NSColor`, and `NSBezierPath`.
- Modern Objective-C Syntax support, including `NSCache`, and `NSUserDefaults`.
- Reading `NSError` call stack symbols from when the error occured.
- `NSProcessInfo` activity support with display and system sleep suspension.
- `NSString` fuzzy equivalency and symbolic link/alias resolution.
- Block-based extensions for `NSImage`, `NSTimer`, `CAAnimation`, and `CATransaction`.
- `NSTabView` animation and gesture support, slightly mimicking `NSPageController`.
- A backwards compatible `NSUUID` class implementation.
- Conical (not angular, but fan-shaped) `NSGradient` support.
- Interface Builder compatibility additions for `NSControl`, `NSCell`, `NSPopover`, and more.
- Vertical text alignment in `NSTextFieldCell`, and `NSTextField` accessory views.
- `NSSecureTextField` chroma hashing for color-based password "visibility".
- iOS-style flashing cursors with custom insertion point width and animations.
- Context-aware `NSAlert` popovers with block-based extensions.
- Sheet queueing and completion handler support for `NSWindow`.
- Context-aware `NSColorPanel` popovers with tear-off to the standard panel.
- Layer or image snapshots of `NSView`s and animated scrolling.
- Animatable `NSWindow` layers with display-synchronized live preview and animations.
- The usual plethora of convenience methods and formal AppKit deprecations.

## Platform Requirements

- OS X 10.7+
- 64-bit Modern Objective-C ABI
- LLVM/Clang 4.0+ Toolchain (Xcode 4.4+)

## Contributing

Please see [CONTRIBUTING.md](https://github.com/galaxas0/Mocha/blob/master/CONTRIBUTING.md).

## License

Mocha is released under the MIT license. See [LICENSE.md](https://github.com/galaxas0/Mocha/blob/master/LICENSE.md).
