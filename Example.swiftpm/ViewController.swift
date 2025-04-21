import UIKit
import Entrance

final class ViewController: UIViewController {
    let label: UILabel = UILabel()
    let button: UIButton = UIButton(configuration: .filled())
    let presentationQueue = PresentationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        label.text = "Hello, World!"
        button.configuration?.title = "Button"
        
        let stackView = UIStackView(
            arrangedSubviews: [
                label,
                button
            ]
        )
        stackView.axis = .vertical
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            stackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20
            ),
            view.trailingAnchor.constraint(
                equalTo: stackView.safeAreaLayoutGuide.trailingAnchor,
                constant: 20
            ),
        ])
        
        button.addAction(UIAction { [unowned self] _ in
            let vc = ChildViewController()
            present(vc, animated: true)
        }, for: .primaryActionTriggered)
        
        presentationQueue.enqueue {
            let vc = UIAlertController(title: "Hello", message: "welcome", preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "OK", style: .cancel))
            return vc
        }
        
        presentationQueue.enqueue {
            ChildViewController()
        }
        
        presentationQueue.enqueue {
            let vc = UIAlertController(title: "Hello", message: "choose", preferredStyle: .actionSheet)
            vc.addAction(UIAlertAction(title: "Option 1", style: .default))
            vc.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            return vc
        }
        
        Task {
            for await vc in presentationQueue.presentableViewControllers() {
                present(vc, animated: true)
            }
        }
    }
}

