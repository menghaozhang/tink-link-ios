import UIKit
import TinkLink

class ProviderMarketsViewController: UIViewController {
    private var providerMarketContext = ProviderMarketContext()

    // MARK: Views
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var effectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    private lazy var separatorLine = UIView()

    // MARK: View Controllers
    private var providerListViewController: ProviderListViewController?
    private let searchController = UISearchController(searchResultsController: nil)

    // MARK: Initializers
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle
extension ProviderMarketsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Choose Bank"
        
        providerMarketContext.delegate = self
        
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.itemSize = CGSize(width: 56, height: 44)
        collectionViewLayout.minimumLineSpacing = 0
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsSelection = true
        collectionView.register(MarketCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        
        setup()
    }
}

// MARK: - Setup
extension ProviderMarketsViewController {
    private func setup() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        view.addSubview(effectView)
        view.addSubview(collectionView)
        view.addSubview(separatorLine)
        
        effectView.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints  = false
        separatorLine.backgroundColor = UIColor(white: 0.87, alpha: 1.0)
        separatorLine.translatesAutoresizingMaskIntoConstraints  = false
        
        NSLayoutConstraint.activate([
            effectView.topAnchor.constraint(equalTo: collectionView.topAnchor),
            effectView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            effectView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            effectView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),

            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 44),
            
            separatorLine.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1)
            ])
    }
    
    private func setupProviderListView(for market: Market) {
        let providerListViewController = ProviderListViewController(market: market, style: .plain)
        addChild(providerListViewController)
        view.insertSubview(providerListViewController.view, at: 0)
        providerListViewController.view.translatesAutoresizingMaskIntoConstraints = false
        providerListViewController.didMove(toParent: self)
        providerListViewController.additionalSafeAreaInsets.top = 44
        
        NSLayoutConstraint.activate([
            providerListViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            providerListViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            providerListViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            providerListViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        self.providerListViewController = providerListViewController
        searchController.searchResultsUpdater = providerListViewController
    }
}

// MARK: - ProviderMarketContextDelegate
extension ProviderMarketsViewController: ProviderMarketContextDelegate {
    func providerMarketContext(_ store: ProviderMarketContext, didUpdateMarkets markets: [Market]) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            if let market = markets.first {
                self.collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition())
                self.setupProviderListView(for: market)
            }
        }
    }
    
    func providerMarketContext(_ store: ProviderMarketContext, didReceiveError error: Error) {
    }
}

// MARK: - UICollectionViewDelegate
extension ProviderMarketsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let market = providerMarketContext.markets[indexPath.item]
        if let providerListViewController = providerListViewController {
            providerListViewController.updateMarket(market: market)
        } else {
            setupProviderListView(for: market)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ProviderMarketsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return providerMarketContext.markets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let marketCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! MarketCell
        let market = providerMarketContext.markets[indexPath.item]
        marketCell.labelView.text = market.emojiFlag
        return marketCell
    }
}
