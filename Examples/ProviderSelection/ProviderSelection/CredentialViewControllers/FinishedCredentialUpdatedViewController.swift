import TinkLink
import UIKit

final class FinishedCredentialUpdatedViewController: UIViewController {
    private let credential: Credential
    private let user: User
    private var activityIndicator: UIActivityIndicatorView?
    private var authenticationResultLabel: UILabel?
    private let authorizationContext: AuthorizationContext

    init(credential: Credential, user: User) {
        self.credential = credential
        self.user = user
        self.authorizationContext = AuthorizationContext(user: user)

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

        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.startAnimating()
        self.activityIndicator = activityIndicator

        let authenticationResultLabel = UILabel()
        authenticationResultLabel.text = "Authenticating..."
        authenticationResultLabel.textAlignment = .center
        authenticationResultLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        authenticationResultLabel.numberOfLines = 0
        authenticationResultLabel.preferredMaxLayoutWidth = 200
        self.authenticationResultLabel = authenticationResultLabel

        let stackView = UIStackView(arrangedSubviews: [checkmarkView, detailLabel, authenticationResultLabel, activityIndicator])
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
        let scope = Link.Scope(scopes: [
            Link.Scope.Accounts.read,
            Link.Scope.Investments.read,
            Link.Scope.User.read,
            Link.Scope.Transactions.read
        ])
        authorizationContext.authorize(scope: scope) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.activityIndicator?.stopAnimating()
                self.activityIndicator?.removeFromSuperview()
                do {
                    let code = try result.get()
                    self.authenticationResultLabel?.text = "Authentication code: \n\(code.rawValue)"
                } catch {
                    self.authenticationResultLabel?.text = "Error: \n\(error.localizedDescription)"
                }
            }
        }
    }
}
