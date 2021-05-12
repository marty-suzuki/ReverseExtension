# ReverseExtension

[![Version](https://img.shields.io/cocoapods/v/ReverseExtension.svg?style=flat)](http://cocoapods.org/pods/ReverseExtension)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)
[![License](https://img.shields.io/cocoapods/l/ReverseExtension.svg?style=flat)](http://cocoapods.org/pods/ReverseExtension)
[![Platform](https://img.shields.io/cocoapods/p/ReverseExtension.svg?style=flat)](http://cocoapods.org/pods/ReverseExtension)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

UITableView extension that enabled to insert cell from bottom of tableView.

<img src="./Images/bottom_insert.gif" width="300">

## Concept

It is difficult to fill a tableview content from bottom.
So, ReverseExtension rotate both of UITableView and UITableViewCell like this images.

<img src="./Images/tableview1.png" width="21%">
<img src="./Images/tableview2.png" width="35%">
<img src="./Images/tableview3.png" width="21%">
<img src="./Images/tableview4.png" width="21%">

If you implement those in ViewController, it will have been fat.
So, escaping those implementation to `re` namespace property, and hiding those complex implementation.
In addition, you can rollback to normal behaviour, only removing `re` namespace.

## Example

```swift
import UIKit
import ReverseExtension

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        //You can apply reverse effect only set delegate.
        tableView.re.delegate = self
        tableView.re.scrollViewDidReachTop = { scrollView in
            print("scrollViewDidReachTop")
        }
        tableView.re.scrollViewDidReachBottom = { scrollView in
            print("scrollViewDidReachBottom")
        }
    }
}

extension ViewController: UITableViewDelegate {
    //ReverseExtension also supports handling UITableViewDelegate.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollView.contentOffset.y =", scrollView.contentOffset.y)
    }
}
```

## Requirements

- Swift 5
- Xcode 12 or greater
- iOS 10 or greater

## Installation

#### CocoaPods

ReverseExtension is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ReverseExtension"
```

#### Carthage

If you’re using [Carthage](https://github.com/Carthage/Carthage), simply add
ReverseExtension to your `Cartfile`:

```
github "marty-suzuki/ReverseExtension"
```

Make sure to add `ReverseExtension.framework` to "Linked Frameworks and Libraries" and "copy-frameworks" Build Phases.

## Special Thanks

[TouchVisualizer](https://github.com/morizotter/TouchVisualizer) (Created by [@morizotter](https://github.com/morizotter))

## Author

marty-suzuki, s1180183@gmail.com

## License

ReverseExtension is available under the MIT license. See the LICENSE file for more info.
