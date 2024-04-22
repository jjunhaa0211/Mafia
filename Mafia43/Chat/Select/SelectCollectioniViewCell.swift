import UIKit
import Then
import SnapKit

class SelectCollectioniViewCell: UICollectionViewCell {
    static let identifier = "SelectCollectioniViewCell"
    
    private let label =  UILabel().then {
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 25, weight: .semibold)
    }
    
    private var beforeColor: UIColor!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(label)
        contentView.layer.cornerRadius = 6
        contentView.layer.borderWidth = 1.5
        contentView.layer.borderColor = UIColor.quaternaryLabel.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                beforeColor = contentView.backgroundColor
                contentView.backgroundColor = .blue
            } else {
                contentView.backgroundColor = beforeColor
            }
        }
    }
    
    func configure(with viewModel: CollectionViewCellViewModel) {
        contentView.backgroundColor = viewModel.backgroundColor
        label.text = viewModel.name
    }
}
