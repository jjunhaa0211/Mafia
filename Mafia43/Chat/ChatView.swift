import UIKit
import SnapKit

class ChatView: UIView, ViewRepresentable {

    let tableView = UITableView()
    let footerView = ChatFooterView()
    
    func attribute() {
        addSubview(tableView)
        addSubview(footerView)
        
        self.backgroundColor = .black
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .black
    }
    
    func layout() {
        footerView.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(20.0)
            $0.bottom.equalTo(footerView.snp.top)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
