import UIKit
import TinkLink

final class FinishedCredentialUpdatedViewController: UIViewController {
    let credential: Credential

    init(credential: Credential) {
        self.credential = credential
        super.init(nibName: nil, bundle: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = UIView()
        view.backgroundColor = .white

        let checkmarkView = CheckmarkView()

        let detailLabel = UILabel()
        detailLabel.text = credential.statusPayload
        detailLabel.textAlignment = .center
        detailLabel.font = UIFont.preferredFont(forTextStyle: .body)
        detailLabel.numberOfLines = 0
        detailLabel.preferredMaxLayoutWidth = 200

        let stackView = UIStackView(arrangedSubviews: [checkmarkView, detailLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ])
    }

    @objc private func done(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
}
