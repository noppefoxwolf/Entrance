import UIKit
import SwiftUI

struct ContentView: UIViewControllerRepresentable {
    func makeUIViewController(
        context: Context
    ) -> some UIViewController {
        UINavigationController(rootViewController: ViewController())
    }
    
    func updateUIViewController(
        _ uiViewController: UIViewControllerType,
        context: Context
    ) {
        
    }
}

