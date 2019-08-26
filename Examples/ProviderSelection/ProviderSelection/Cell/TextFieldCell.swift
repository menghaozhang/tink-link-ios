import UIKit

protocol TextFieldCellDelegate: AnyObject {
    func textFieldCell(_ cell: TextFieldCell, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
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
    
    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
        return super.resignFirstResponder()
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return delegate?.textFieldCell(self, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
}
