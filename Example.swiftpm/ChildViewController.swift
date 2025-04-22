import UIKit

final class ChildViewController: UIViewController {
    
    override func loadView() {
        let label = UILabel()
        label.backgroundColor = .systemBackground
        label.text = "Hello, World!"
        view = label
    }
}

