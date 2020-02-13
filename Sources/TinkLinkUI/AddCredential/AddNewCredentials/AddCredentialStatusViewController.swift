import UIKit

final class AddCredentialStatusViewController: UIViewController {
    private lazy var activityIndicator = UIActivityIndicatorView(style: .gray)
    private lazy var statusLabelView = UILabel()

    var status: String? {
        get {
            guard isViewLoaded else { return nil }
            return statusLabelView.text
        }
        set {
            guard isViewLoaded else { return }
            statusLabelView.text = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let stackView = UIStackView(arrangedSubviews: [activityIndicator, statusLabelView])
        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 32, left: 24, bottom: 24, right: 24)
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        statusLabelView.font = UIFont.preferredFont(forTextStyle: .headline)
        statusLabelView.numberOfLines = 0
        statusLabelView.preferredMaxLayoutWidth = 220
        statusLabelView.textAlignment = .center

        activityIndicator.startAnimating()
        activityIndicator.setContentHuggingPriority(.defaultLow, for: .vertical)

        NSLayoutConstraint.activate([
            statusLabelView.widthAnchor.constraint(equalToConstant: 240),

            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
