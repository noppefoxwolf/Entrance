import UIKit
import AVFoundation
import Entrance

final class ViewController: UIViewController {
    let label: UILabel = UILabel()
    let presentationQueue = PresentationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        label.text = "Hello, World!"
        
        let stackView = UIStackView(
            arrangedSubviews: [
                label
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
        
        presentationQueue.enqueue {
            let vc = UIAlertController(title: "Hello", message: "welcome", preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "OK", style: .cancel))
            return vc
        }
        
        presentationQueue.enqueue {
            ChildViewController()
        }
        
        presentationQueue.enqueue {
            await AVCaptureDevice.requestAccess(for: .video)
        }
        
        presentationQueue.enqueue {
            let vc = UIAlertController(title: "Hello", message: "choose", preferredStyle: .actionSheet)
            vc.addAction(UIAlertAction(title: "Option 1", style: .default))
            vc.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            return vc
        }
        
        Task {
            for await presenter in presentationQueue.presenters() {
                await presenter.present(in: self)
            }
        }
    }
}


