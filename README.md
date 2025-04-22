# Entrance

A simple Swift library for managing sequential presentation of UIViewControllers

## Overview

Entrance provides a convenient queue system for presenting multiple UIViewControllers in sequence. For example:

- Displaying multiple screens in an onboarding tutorial
- Presenting alerts and action sheets in succession
- Sequentially showing screens based on user interactions

This library leverages Swift Concurrency and uses AsyncSequence to easily manage the presentation of view controllers.

## Requirements

- iOS 16.0
- Swift 6.0

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file's `dependencies`:

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
    // Second view controller to present
    MySecondViewController()
}

// Present view controllers sequentially in an asynchronous manner
Task {
    for await presenter in presentationQueue.presenters() {
        await presenter.present(in: self)
    }
}
```

## Adding Actions

You can also add arbitrary asynchronous actions to the queue, not just UIViewControllers:

```swift
// Add an action to the queue
presentationQueue.enqueue {
    await AVCaptureDevice.requestAccess(for: .video)
}
```

## Features

- **Ease of Use**: Manage complex presentation logic with a simple API
- **Async Support**: Fully integrated with Swift Concurrency
- **Automatic Presentation Management**: Automatically presents the next view controller when the previous one is dismissed

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

