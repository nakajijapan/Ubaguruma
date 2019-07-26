# Ubaguruma

[![Carthage](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/Ubaguruma.svg?style=flat)](http://cocoapods.org/pods/Ubaguruma)
[![License](https://img.shields.io/cocoapods/l/Ubaguruma.svg?style=flat)](http://cocoapods.org/pods/Ubaguruma)
[![Platform](https://img.shields.io/cocoapods/p/Ubaguruma.svg?style=flat)](http://cocoapods.org/pods/Ubaguruma)
[![Language](https://img.shields.io/badge/language-Swift%204-orange.svg)](https://swift.org)
[![Backers on Open Collective](https://opencollective.com/Ubaguruma/backers/badge.svg)](#backers) 
[![Sponsors on Open Collective](https://opencollective.com/Ubaguruma/sponsors/badge.svg)](#sponsors) 

Ubaguruma is a simple photo slider and can delete slider with swiping.

<img src="https://raw.githubusercontent.com/nakajijapan/Ubaguruma/master/Ubaguruma.png" width="300" />



## Requirements

- Xcode 10.2+
- Swift 5.0+
- iOS 11+

## Installation

### CocoaPods

Ubaguruma is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Ubaguruma"
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager for Cocoa application.

``` bash
$ brew update
$ brew install carthage
```

To integrate Ubaguruma into your Xcode project using Carthage, specify it in your `Cartfile`:

``` ogdl
github "nakajijapan/Ubaguruma"
```

Then, run the following command to build the Ubaguruma framework:

``` bash
$ carthage update
```

## Usage

### Initialize

```swift

let imagePickerController = Ubaguruma.ImagePickerController()
let safeAreaInsetBottom = view.safeAreaInsets.bottom
let defaultKeyboardMinY: CGFloat = 346
chatToolbarViewBottomConstraint.constant = defaultKeyboardMinY - safeAreaInsetBottom
imagePickerController?.visibleHeight = defaultKeyboardMinY
imagePickerController?.present(containerController: navigationController, animated: animated)

```



## Author

nakajijapan

### Special Thanks

🙅‍♂️

## Contributors

This project exists thanks to all the people who contribute. 
<a href="https://github.com/nakajijapan/Ubaguruma/graphs/contributors"><img src="https://opencollective.com/Ubaguruma/contributors.svg?width=890&button=false" /></a>


## License

Ubaguruma is available under the MIT license. See the LICENSE file for more info.
