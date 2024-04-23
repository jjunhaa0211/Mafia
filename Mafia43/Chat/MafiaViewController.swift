import UIKit
import Then

class MafiaViewController: UIViewController {
    let username = "-1"
    var list = [Chat]()
    var socketIOManager: SocketIOManager!
    
    var chat: String?
    var name: String?
    var date: String?
    var memberCount: Int?
    let mainView = ChatView().then {
        $0.tableView.register(YourMessageTableViewCell.self, forCellReuseIdentifier: YourMessageTableViewCell.reuseIdentifier)
        $0.tableView.register(MyMessageTableViewCell.self, forCellReuseIdentifier: MyMessageTableViewCell.reuseIdentifier)
        $0.tableView.register(EventTableViewCell.self, forCellReuseIdentifier: EventTableViewCell.reuseIdentifier)
    }
    
    func tableViewConfig() {
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
    }
    
    func navBarConfig() {
        self.title = "마피아43"
        self.navigationController?.navigationBar.backgroundColor = .black
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "시작", style: .done, target: self, action: #selector(readyButtonTap)), UIBarButtonItem(title: "투표", style: .done, target: self, action: #selector(voteButtonTap)), UIBarButtonItem(title: "스킬", style: .done, target: self, action: #selector(skillButtonTap))]
    }
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewConfig()
        navBarConfig()
        mainView.footerView.sendButton.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        socketSetting()
    }
    
    func socketSetting() {
        socketIOManager = SocketIOManager()
        
        socketIOManager.onChat = { _, message in
            print("받은 메시지: \(message)")
            self.showAlertMessage(title: "직업", message: "\(message)")
        }
        
        socketIOManager.onStart = { job, memberCount, _ in
            self.list = []
            self.mainView.tableView.reloadData()
            print("당신의 직업은 \(job)입니다.")
            print("\(memberCount) 명입니다")
            self.memberCount = memberCount
        }
        
        socketIOManager.onCheck = { isMafia, _ in
            if isMafia {
                print("선택한 대상은 마피아입니다!")
            } else {
                print("선택한 대상은 마피아가 아닙니다!")
            }
        }
        
        socketIOManager.connect()
        
        socketIOManager.onStart = { job, _, idx in
            self.showAlertMessage(title: "플레이어 \(idx)", message: "당신의 직업은 \(job)입니다.")
            self.addMessage(chat: "당신은 \(idx)번째 플레이어, 직업은 \(job)입니다.", id: "0")
        }
        
        socketIOManager.onState = { state, time, last in
            DispatchQueue.main.async {
                var message = ""
                switch state {
                case "Night":
                    message = "밤이 시작되었습니다."
                case "Day":
                    message = "날이 밝았습니다."
                case "Vote":
                    message = "모두 의심되는 사람에게 투표를 해주세요."
                case "Last":
                    message = "\(last)님의 최후의 반론"
                case "Check":
                    message = "찬반 투표 시간입니다."
                    self.showTrueFalseMessage(title: "\(last)님을 처형할까요?", message: "처형하시겠습니까?")
                default:
                    break
                }
                self.addMessage(chat: message, id: "0")
            }
        }
        
        socketIOManager.onChat = { numberIndex, message in
            self.addMessage(chat: message, id: String(numberIndex == -1 ? -1 : numberIndex + 1))
        }
        
        socketIOManager.onCheck = { mafia, idx in
            self.addMessage(chat: "선택한 \(idx + 1)번째 사람은 마피아" + (mafia ? "가 아닙니다." : "입니다."), id: "0")
        }
        
        socketIOManager.onHeal = { idx in
            self.addMessage(chat: "\(idx)님이 의사의 치료를 받아 살아났습니다", id: "0")
        }
        
        socketIOManager.onKill = { idx in
            self.addMessage(chat: "\(idx)님이 마피아에게 살해당했습니다", id: "0")
        }
        
        socketIOManager.onVote = { idx in
            self.addMessage(chat: "\(idx)님이 투표로 처형당했습니다", id: "0")
        }
        
        socketIOManager.onEnd = {
            self.addMessage(chat: "게임이 종료되었습니다.", id: "0")
        }
        
        socketIOManager.onTimeAdd = { idx in
            self.addMessage(chat: "\(idx)님이 시간을 증가시켰습니다.", id: "0")
        }
        
        socketIOManager.onTimeRemove = { idx in
            self.addMessage(chat: "\(idx)님이 시간을 단축시켰습니다.", id: "0")
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func handleSendMessage() {
        chat = "\(mainView.footerView.messageTextField.text ?? " ")"
        mainView.footerView.messageTextField.text = ""
        socketIOManager.chat(chat ?? "nil")
    }
    
    @objc func timeUp() {
        socketIOManager.send(.add)
    }
    
    @objc func timeDown() {
        socketIOManager.send(.remove)
    }
    
    func addMessage(chat: String, id: String) {
        let value = Chat(text: chat, userID: "", name: "", username: id, id: id, createdAt: "", updatedAt: "", v: 0, lottoID: "")
        self.list.append(value)
        self.mainView.tableView.reloadData()
        self.mainView.tableView.scrollToRow(at: IndexPath(row: self.list.count - 1, section: 0), at: .bottom, animated: false)
    }
    
    @objc func readyButtonTap() {
        socketIOManager.send(.start)
    }
    
    @objc func voteButtonTap() {
        let controller = UsersViewController()
        controller.title = "투표"
        controller.initializer(socketIOManager)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func skillButtonTap() {
        let controller = UsersViewController()
        controller.title = "스킬"
        controller.initializer(socketIOManager)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func showTrueFalseMessage(title: String, message: String){
        let alertMessagePopUpBox = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "찬성", style: .default, handler: {_ in
            self.socketIOManager.send(.ok)
        })
        let noButton = UIAlertAction(title: "반대", style: .default) { _ in
            self.socketIOManager.send(.no)
        }
        
        alertMessagePopUpBox.addAction(okButton)
        alertMessagePopUpBox.addAction(noButton)
        self.present(alertMessagePopUpBox, animated: true)
    }
}

extension MafiaViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = list[indexPath.row]
        
        if data.username == self.username {
            guard let myCell = tableView.dequeueReusableCell(withIdentifier: MyMessageTableViewCell.reuseIdentifier, for: indexPath) as? MyMessageTableViewCell else { return UITableViewCell() }
            
            myCell.messageLabel.text = data.text
            myCell.configure(with: data, label: myCell.messageLabel)
            
            return myCell
        } else if data.username == "0" {
            guard let eventCell = tableView.dequeueReusableCell(withIdentifier: EventTableViewCell.reuseIdentifier, for: indexPath) as? EventTableViewCell else { return UITableViewCell() }
            eventCell.messageLabel.text = data.text
            eventCell.configure(with: data, label: eventCell.messageLabel)
            return eventCell
        } else {
            guard let yourCell = tableView.dequeueReusableCell(withIdentifier: YourMessageTableViewCell.reuseIdentifier, for: indexPath) as? YourMessageTableViewCell else { return UITableViewCell() }
            
            yourCell.messageLabel.text = data.text
            yourCell.configure(with: data, label: yourCell.messageLabel)
            return yourCell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = list[indexPath.row]
        if chat.text.contains("잠수") {
            let alertController = UIAlertController(title: "잠수", message: "게임 내내 아무 말과 행동도 하지 않고 있는 것, 또는 그 사람을 지칭하는 말.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "확인", style: .default))
            present(alertController, animated: true)
        }
    }
}
