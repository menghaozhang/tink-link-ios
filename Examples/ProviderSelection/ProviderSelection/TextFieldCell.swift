import UIKit
class TextFieldCell: UITableViewCell {
    
    static var reuseIdentifier: String {
        return "TextFieldCell"
    }
    
    lazy var textField = UITextField()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        setup()
    }
    
    private func setup() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            textField.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            textField.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            textField.heightAnchor.constraint(equalToConstant: 40)
            ])
    }
    
}
