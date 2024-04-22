import UIKit

extension UITableViewCell: ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
