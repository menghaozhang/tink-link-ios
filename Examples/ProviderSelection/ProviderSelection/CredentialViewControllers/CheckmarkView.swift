import UIKit

class CheckmarkView: UIView {
    private var label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        label.text = "✓"
        label.textAlignment = .center
        label.textColor = UIColor.systemGreen
        label.font = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle), size: 40)
        label.layer.borderColor = UIColor.systemGreen.cgColor
        label.layer.borderWidth = 3
        label.layer.cornerRadius = 40

        addSubview(label)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        label.frame = bounds
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 80, height: 80)
    }
}
