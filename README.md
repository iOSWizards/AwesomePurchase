# AwesomePurchase

[![CI Status](http://img.shields.io/travis/evandro@itsdayoff.com/AwesomePurchase.svg?style=flat)](https://travis-ci.org/evandro@itsdayoff.com/AwesomePurchase)
[![Version](https://img.shields.io/cocoapods/v/AwesomePurchase.svg?style=flat)](http://cocoapods.org/pods/AwesomePurchase)
[![License](https://img.shields.io/cocoapods/l/AwesomePurchase.svg?style=flat)](http://cocoapods.org/pods/AwesomePurchase)
[![Platform](https://img.shields.io/cocoapods/p/AwesomePurchase.svg?style=flat)](http://cocoapods.org/pods/AwesomePurchase)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 9 or Higher
- Swift 5.0

## Installation

AwesomePurchase is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "AwesomePurchase", git: 'https://github.com/iOSWizards/AwesomePurchase', tag: '0.1.2'
```
## Usage

### Initiating Store

```swift
AwesomePurchase.start(with: ["identifier1", "identifier2", ...])
```

**Test Environment**

```swift
AwesomePurchase.start(with: ["identifier1", "identifier2", ...], isProduction: false)
```

### Requesting Products

**Single Product**

```swift
AwesomePurchase.shared.product(withIdentifier: "PRODUCT IDENTIFIER") { (product, message) in
    // any further action
}
```

**All Available Products**

```swift
AwesomePurchase.shared.products { (success, products, message) in
    // any further action
}
```

### Purchasing Products


```swift
AwesomePurchase.shared.purchaseProduct(withIdentifier: "PRODUCT IDENTIFIER") { (success, receipt, message) in
    // any further action
}
```

### Subscription Protocol

In order to make the usability for Subscription simpler, you can take advantage of the Subscription Protocol. Ideally, you should create a helper class to handle the subscription and be responsible for any change in the subscripton state. 

**Here's an example of the implementation:**

```swift
import AwesomePurchase
import StoreKit

enum SubscriptionId: String {
    case monthly = "IDENTIFIER 1"
    case yearly = "IDENTIFIER 2"
}

class AwesomePurchaseHelper: AwesomePurchaseSubscriptionProtocol {

    static var shared = AwesomePurchaseHelper()

    var products: [SKProduct] = []
    var iapHelper: AwesomePurchaseStore?

    var appStoreSecret: String {
        return "yourAppStoreSecret"
    }

    static func start() {
        AwesomePurchase.start(with: [SubscriptionId.monthly.rawValue, SubscriptionId.yearly.rawValue], isProduction: false)

        shared.addPurchaseObservers()

        shared.updateProducts { (products) in
            shared.products = products
        }
    }

    func receiptConfirmed(isValid: Bool) {
        // take action
    }
    
}
```

### Subscription Status Update Protocol

In order to update your view according to Subscription status update, implement the `AwesomePurchaseSubscriptionStatusProtocol`.

```swift
extension YourView: AwesomePurchaseSubscriptionStatusProtocol {
    func updatedSubscriptionStatus() {
        // update UI
    }
}
```

## License

AwesomePurchase is available under the MIT license. See the LICENSE file for more info.
