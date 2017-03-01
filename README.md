# ReverseExtension

[![Version](https://img.shields.io/cocoapods/v/ReverseExtension.svg?style=flat)](http://cocoapods.org/pods/ReverseExtension)
[![License](https://img.shields.io/cocoapods/l/ReverseExtension.svg?style=flat)](http://cocoapods.org/pods/ReverseExtension)
[![Platform](https://img.shields.io/cocoapods/p/ReverseExtension.svg?style=flat)](http://cocoapods.org/pods/ReverseExtension)

UITableView extension that enabled to insert cell from bottom of tableView.

<img src="./Images/bottom_insert.gif" width="300">

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

- Swift 3.0
- Xcode 8.0 or greater
- iOS 8.0 or greater

## Installation

ReverseExtension is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ReverseExtension"
```

## Special Thanks

[TouchVisualizer](https://github.com/morizotter/TouchVisualizer) (Created by [@morizotter](https://github.com/morizotter))

## Author

marty-suzuki, s1180183@gmail.com

## License

ReverseExtension is available under the MIT license. See the LICENSE file for more info.
