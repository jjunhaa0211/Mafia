import UIKit
import SnapKit
import Then

class YourMessageTableViewCell: UITableViewCell, ViewRepresentable {
    let messageLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .black
        $0.numberOfLines = 0
    }
    let messageDateLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .red
    }
    let messageBubbleView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
    }
    
    func attribute() {
        contentView.backgroundColor = .black

        contentView.addSubview(messageBubbleView)
        messageBubbleView.addSubview(messageLabel)
        contentView.addSubview(messageDateLabel)
    }
    
    func layout() {
        messageBubbleView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.width.lessThanOrEqualTo(contentView.snp.width).multipliedBy(0.7)
            $0.top.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        messageLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(5)
            $0.trailing.equalToSuperview().offset(-5)
            $0.top.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().offset(-10)
        }
        messageDateLabel.snp.makeConstraints {
            $0.leading.equalTo(messageBubbleView.snp.trailing).offset(10)
            $0.centerY.equalTo(messageBubbleView.snp.bottom).offset(-10)
        }
    }
    
    func configure(with chat: Chat, label: UILabel) {
        let text = chat.text
        let attributedString = NSMutableAttributedString(string: text)

        // "잠수" 문자열이 포함된 범위를 찾아 밑줄 추가
        if let range = text.range(of: "잠수") {
            let nsRange = NSRange(range, in: text)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
        }

        label.attributedText = attributedString
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

