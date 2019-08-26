import UIKit

class FinishedCredentialUpdatedViewController: UIViewController {
    var credential: Credential
    
    init(credential: Credential) {
        self.credential = credential
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Credential Updated"
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        let providerNameLabel = UILabel()
        providerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        providerNameLabel.text = "Provider name: " + credential.providerName
        let typeLabel = UILabel()
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.text = "Credential type: " + credential.type.rawValue
        stackView.addArrangedSubview(providerNameLabel)
        stackView.addArrangedSubview(typeLabel)
        
        view.backgroundColor = .white
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }
}