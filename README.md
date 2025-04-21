# Entrance

A simple Swift library for sequentially managing the presentation of UIViewControllers.

## Overview

Entrance provides a convenient queue system for displaying multiple UIViewControllers in sequence. For example:

- Display multiple screens in sequence for an onboarding tutorial
- Show alerts and action sheets consecutively
- Present multiple screens sequentially based on user interaction

This library leverages Swift Concurrency and uses AsyncSequence to easily manage the presentation of view controllers.

## Requirements

- iOS 16.0
- Swift 6.0

## Installation

### Swift Package Manager

Add the following to the `dependencies` in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/noppefoxwolf/Entrance.git", from: "1.0.0")
]
```

## Usage

Basic usage is as follows:

```swift
import Entrance

// Create a PresentationQueue instance
let presentationQueue = PresentationQueue()

// Add view controllers to the queue
presentationQueue.enqueue {
    let vc = UIAlertController(title: "Hello", message: "Welcome", preferredStyle: .alert)
    vc.addAction(UIAlertAction(title: "OK", style: .cancel))
    return vc
}

presentationQueue.enqueue {
    // Second view controller to display
    MySecondViewController()
}

// Asynchronously present view controllers in sequence
Task {
    for await vc in presentationQueue.presentableViewControllers() {
        present(vc, animated: true)
    }
}
```

## Features

- **Easy to Use**: Manage complex presentation logic with a simple API
- **Asynchronous Support**: Fully integrated with Swift Concurrency
- **Automatic Presentation Management**: Automatically presents the next view controller after the previous one is dismissed

## License

This project is released under the MIT license. See [LICENSE](LICENSE) for details.

