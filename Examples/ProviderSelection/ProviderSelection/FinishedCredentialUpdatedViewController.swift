import UIKit

class FinishedCredentialUpdatedViewController: UIViewController {
    var credential: Credential?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        let providerNameLabel = UILabel()
        providerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        providerNameLabel.text = "Provider name: " + (credential?.providerName ?? "")
        let typeLabel = UILabel()
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.text = "Credential type: " + (credential?.type.rawValue ?? "")
        stackView.addArrangedSubview(providerNameLabel)
        stackView.addArrangedSubview(typeLabel)
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }
}
