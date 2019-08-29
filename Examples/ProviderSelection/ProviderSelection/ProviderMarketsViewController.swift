import UIKit

class ProviderMarketsViewController: UIViewController {
    private var providerMarketRepository = ProviderMarketRepository()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var separatorLine = UIView()
    private var providerListViewController: ProviderListViewController?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ProviderMarketsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Choose your bank"
        
        providerMarketRepository.delegate = self
        
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.backgroundColor = .white
        collectionView.allowsSelection = true
        collectionView.register(MarketCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        
        setup()
    }
    
    private func setup() {
        view.addSubview(collectionView)
        view.addSubview(separatorLine)
        
        view.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints  = false
        separatorLine.backgroundColor = .black
        separatorLine.translatesAutoresizingMaskIntoConstraints  = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 40),
            
            separatorLine.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1)
            ])
    }
    
    private func addProviderListView(for market: String) {
        let providerListViewController = ProviderListViewController(market: market, style: .plain)
        addChild(providerListViewController)
        view.addSubview(providerListViewController.view)
        providerListViewController.view.translatesAutoresizingMaskIntoConstraints = false
        providerListViewController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            providerListViewController.view.topAnchor.constraint(equalTo: separatorLine.bottomAnchor),
            providerListViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            providerListViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            providerListViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        self.providerListViewController = providerListViewController
    }
}

extension ProviderMarketsViewController: ProviderMarketRepositoryDelegate {
    func providerMarketRepository(_ store: ProviderMarketRepository, didUpdateMarkets markets: [String]) {
        collectionView.reloadData()
        if let market = markets.first {
            collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition())
            addProviderListView(for: market)
        }
    }
    
    func providerMarketRepository(_ store: ProviderMarketRepository, didReceiveError error: Error) {
    }
}

extension ProviderMarketsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let market = providerMarketRepository.market[indexPath.item]
        if let providerListViewController = providerListViewController {
            providerListViewController.updateMarket(market: market)
        } else {
            addProviderListView(for: market)
        }
    }
}

extension ProviderMarketsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return providerMarketRepository.market.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath)
        if let marketCell = cell as? MarketCell {
            marketCell.update(label: providerMarketRepository.market[indexPath.item])
        }
        return cell
    }
}

class MarketCell: UICollectionViewCell {
    let labelView = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    func update(label: String) {
        labelView.text = label
    }
    
    private func setup() {
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .lightGray
        
        labelView.backgroundColor = .clear
        labelView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(labelView)
        NSLayoutConstraint.activate([
            labelView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            labelView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
    }
}
