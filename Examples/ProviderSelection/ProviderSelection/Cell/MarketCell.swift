import UIKit

class MarketCell: UICollectionViewCell {
    let labelView = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor(white: 0.85, alpha: 1.0)

        labelView.font = UIFont.preferredFont(forTextStyle: .title1)
        labelView.backgroundColor = .clear
        labelView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(labelView)
        NSLayoutConstraint.activate([
            labelView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            labelView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
