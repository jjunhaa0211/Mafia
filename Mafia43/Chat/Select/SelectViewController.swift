import UIKit
import SnapKit

struct CollectionViewCellViewModel {
    let name: String
    let backgroundColor: UIColor
}

class UsersViewController: UIViewController {
    private var viewModels: [CollectionViewCellViewModel] = [
        CollectionViewCellViewModel(name: "1", backgroundColor: .gray),
        CollectionViewCellViewModel(name: "2", backgroundColor: .gray),
        CollectionViewCellViewModel(name: "3", backgroundColor: .gray),
        CollectionViewCellViewModel(name: "4", backgroundColor: .gray),
        CollectionViewCellViewModel(name: "5", backgroundColor: .gray),
        CollectionViewCellViewModel(name: "6", backgroundColor: .gray),
    ]
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        return collectionView
    }()
    
    private var socketIOManager: SocketIOManager!
    
    func initializer(_ manager: SocketIOManager) {
        socketIOManager = manager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLayout()
        configureCollectionView()
        
        view.backgroundColor = .black
        
    }
    
    @objc func textButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }

    func configureLayout() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.top.width.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(500)
        }
    }
    
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(SelectCollectioniViewCell.self, forCellWithReuseIdentifier: SelectCollectioniViewCell.identifier)
    }
}

extension UsersViewController: UICollectionViewDelegate {
    
}

extension UsersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return socketIOManager.members
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectCollectioniViewCell.identifier, for: indexPath) as? SelectCollectioniViewCell else {
            fatalError("Unable to dequeue SelectCollectioniViewCell")
        }
        
        cell.configure(with: viewModels[indexPath.row])
        
        if(socketIOManager.deaths.contains(indexPath.row)) {
            cell.backgroundColor = .gray
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("clicked: \(indexPath.row)")
        socketIOManager.send(.select, "\(indexPath.row)")
        self.navigationController?.popViewController(animated: true)
    }
}

extension UsersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let totalCellWidth: CGFloat = 100 * 3
        let totalSpacingWidth: CGFloat = 0 * (3 - 1)
        
        let leftInset = (collectionView.bounds.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset

        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
}
