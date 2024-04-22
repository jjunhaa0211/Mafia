import Foundation
import SocketIO
import UIKit

class SocketIOManager {
    var socketManager: SocketManager = SocketManager(socketURL: URL(string: "\(baseURL)")!,
        config: [
            .version(.three),
            .forceWebsockets(true),
            .reconnects(true),
            .reconnectWait(1),
            .reconnectAttempts(-1),
            .reconnectWaitMax(1)
        ]
    )
    var socket: SocketIOClient!
    
    var members: Int = 0
    var deaths: Set<Int> = Set()
    
    init(_ debug: Bool = false) {
        print(socketManager.socketURL)
        socket = socketManager.socket(forNamespace: "/socket-io")
        
        if(debug) {
            socket.on(clientEvent: .error) { data, _ in
                print("Error \(data)")
            }
            
            socket.on(clientEvent: .statusChange) { data, _ in
                print("Status Changed \(data)")
            }
            
            socket.on(clientEvent: .websocketUpgrade) { data, _ in
                print("Websocket Upgrade \(data)")
            }
        }
        
        socket.on(clientEvent: .reconnect) { data, _ in
            print("Reconnect \(data)")
        }
        
        socket.on(clientEvent: .reconnectAttempt) { data, _ in
            print("Reconnect Attempt \(data)")
        }
        
        socket.on(clientEvent: .disconnect) { data, _ in
            print("Socket OFF \(data)")
        }
        
        socket.on(clientEvent: .connect) { data, _ in
            print("Socket ON")
        }
        
        socket.on("chat") { data, _ in
            print("Chat Recieved: \(data)")
            self.onChat(data[0] as! Int, data[1] as! String)
        }
        
        socket.on("game") { data, _ in
            print("Game Event Recieved: \(data)")
            let args = (data[0] as! String).components(separatedBy: ":")
            self.onEvent(String(args[0]), Array(args[1...]))
        }
    }
    
    func connect() {
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    enum PacketType {
        case select
//        case vote
        case ok
        case no
        case start
        case reset
        case add
        case remove
    }
    
    func chat(_ msg: String) {
        socket.emit("chat", msg)
    }
    
    func send(_ type: PacketType,_ data: String = "") {
        switch type {
        case .select:
            socket.emit("game", "select:" + data)
        case .ok:
            socket.emit("game", "ok:" + data)
        case .no:
            socket.emit("game", "no:" + data)
        case .start:
            deaths.removeAll()
            socket.emit("game", "start")
        case .reset:
            deaths.removeAll()
            socket.emit("game", "reset")
        case .add:
            socket.emit("game", "")
        case .remove:
            socket.emit("game", "")
        }
    }
    
    func onEvent(_ type: String,_ args: [String]) {
        let idx: Int
        switch type {
        case "start":
            members = Int(args[1])!
            onStart(args[0], members, Int(args[2])!)
        case "check":
            onCheck(args[0] == "true", Int(args[1])!)
        case "state":
            onState(args[0], Int(args[1])!, args[2])
        case "heal":
            onHeal(Int(args[0])!)
        case "kill":
            idx = Int(args[0])!
            deaths.insert(idx)
            onKill(idx)
        case "last":
            idx = Int(args[0])!
            onLast(idx)
        case "vote":
            idx = Int(args[0])!
            deaths.insert(idx)
            onVote(Int(args[0])!)
        case "add":
            onTimeAdd(Int(args[0])!)
        case "remove":
            onTimeRemove(Int(args[0])!)
        case "end":
            onEnd()
        default:
            return
        }
    }
    
    // 채팅 전달 받음
    var onChat: (Int, String) -> () = { _,_  in }
    
    // 게임 시작 (job: 직업 정보)
    var onStart: (String, Int, Int) -> () = { _, _, _ in }
    
    // 경찰 조사 결과 (true: 선택한 놈 = 마피아)
    var onCheck: (Bool, Int) -> () = { _, _ in }
    
    // 시간 변경 이벤트
    // state: [Night=밤, Day=낮, Vote=투표, Last=최후의반론, Check=찬반투표]
    // time: 소요 시간
    var onState: (String, Int, String) -> () = { _, _, _ in }
    
    // 의사가 치료함 (index: 치료한 놈 index)
    var onHeal: (Int) -> () = { _ in }
    
    // 마피아가 죽임 (index: 죽인 놈 index)
    var onKill: (Int) -> () = { _ in }
    
    // 최후의 반론 시작 (index: 투표 가장 많이 받은 놈 index)
    var onLast: (Int) -> () = { _ in }
    
    // 투표로 누구 죽임 (index: 투표로 죽인 놈 index)
    var onVote: (Int) -> () = { _ in }
    
    var onEnd: () -> () = { }
    
    var onTimeAdd: (Int) -> () = { _ in }
    
    var onTimeRemove: (Int) -> () = { _ in }
}
