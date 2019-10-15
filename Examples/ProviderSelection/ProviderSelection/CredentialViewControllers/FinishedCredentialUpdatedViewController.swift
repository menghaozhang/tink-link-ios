import TinkLink
import UIKit

final class FinishedCredentialUpdatedViewController: UIViewController {
    let credential: Credential

    init(credential: Credential) {
        self.credential = credential
        super.init(nibName: nil, bundle: nil)
        title = "Success!"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }

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
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        authorize()
    }

    @objc private func done(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }

    private func authorize() {
        let scope = TinkLink.Scope(scopes: [
            TinkLink.Scope.Accounts.read,
            TinkLink.Scope.Investments.read,
            TinkLink.Scope.User.read,
            TinkLink.Scope.Transactions.read
        ])
        TinkLink.shared.authorize(scope: scope) { (result) in
            do {
                let code = try result.get()
                print(code)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
