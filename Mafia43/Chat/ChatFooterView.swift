import UIKit
import SnapKit
import Then

class ChatFooterView: UIView, UITextFieldDelegate, ViewRepresentable {
    
    let plusButton = UIButton(type: .system).then {
        $0.setTitle("+", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .lightGray
        $0.layer.cornerRadius = 5
    }
    
    let messageTextField = UITextField().then {
        $0.borderStyle = .none
        $0.backgroundColor = .lightGray
        $0.layer.borderColor = UIColor.black.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 5
        $0.leftPadding()
        $0.rightPading()
    }
    
    let sendButton = UIButton(type: .system).then {
        $0.setTitle("Send", for: .normal)
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .lightGray
        $0.setTitleColor(.white, for: .normal)
        $0.isEnabled = false
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.white.cgColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func attribute() {
        self.backgroundColor = .black
        addSubview(plusButton)
        addSubview(messageTextField)
        addSubview(sendButton)
        
        messageTextField.delegate = self
    }
    func layout() {
        plusButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(44)
        }
        
        messageTextField.snp.makeConstraints {
            $0.leading.equalTo(plusButton.snp.trailing).offset(10)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(44)
            $0.trailing.equalTo(sendButton.snp.leading).offset(-10)
        }
        
        sendButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(60)
            $0.height.equalTo(44)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let futureText = (currentText as NSString).replacingCharacters(in: range, with: string)
        updateSendButtonState(with: futureText)
        return true
    }
    
    func updateSendButtonState(with text: String) {
        let shouldEnableButton = !text.trimmingCharacters(in: .whitespaces).isEmpty
        sendButton.isEnabled = shouldEnableButton
        sendButton.backgroundColor = shouldEnableButton ? .red : .lightGray
    }
}
