import UIKit

protocol TextFieldCellDelegate: AnyObject {
    func textFieldCell(_ cell: TextFieldCell, DidBeginEditing textField: UITextField)
    func textFieldCell(_ cell: TextFieldCell, DidEndEditing textField: UITextField)
}

class TextFieldCell: UITableViewCell, UITextFieldDelegate {
    
    weak var delegate: TextFieldCellDelegate?
    
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
        textField.delegate = self
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            textField.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            textField.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            textField.heightAnchor.constraint(equalToConstant: 40)
            ])
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = .black
        delegate?.textFieldCell(self, DidBeginEditing: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldCell(self, DidEndEditing: textField)
    }
    
}
