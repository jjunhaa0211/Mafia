import Foundation

struct Chat: Codable {
    let text, userID, name, username: String
    let id, createdAt, updatedAt: String
    let v: Int
    let lottoID: String

    enum CodingKeys: String, CodingKey {
        case text
        case userID = "userId"
        case name, username
        case id = "_id"
        case createdAt, updatedAt
        case v = "__v"
        case lottoID = "id"
    }
}
