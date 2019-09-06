import UIKit
import TinkLink

class ProviderMarketsViewController: UIViewController {
    private var providerMarketContext = ProviderMarketContext()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var effectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
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
    
    private func setup() {
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

extension ProviderMarketsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let market = providerMarketContext.market[indexPath.item]
        if let providerListViewController = providerListViewController {
            providerListViewController.updateMarket(market: market)
        } else {
            setupProviderListView(for: market)
        }
    }
}

extension ProviderMarketsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return providerMarketContext.market.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let marketCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! MarketCell
        let market = providerMarketContext.market[indexPath.item]
        marketCell.labelView.text = market.emojiFlag
        return marketCell
    }
}

class MarketCell: UICollectionViewCell {
    let labelView = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        
        labelView.font = UIFont.preferredFont(forTextStyle: .title1)
        labelView.backgroundColor = .clear
        labelView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(labelView)
        NSLayoutConstraint.activate([
            labelView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            labelView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
