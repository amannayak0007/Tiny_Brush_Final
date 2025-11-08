import UIKit

public protocol WSPalettePickerDataSource: AnyObject {
    func palettePickerColors(pickerController: WSPalettePickerController) -> [UIColor]
}

public protocol WSPalettePickerDelegate: AnyObject {
    func palettePickerShouldPresent(pickerController: WSPalettePickerController)
    func pickerDidSelect(color: UIColor)
}

public class WSPalettePickerController: UIViewController, UIPopoverPresentationControllerDelegate {

    public weak var dataSource: WSPalettePickerDataSource?
    public weak var delegate: WSPalettePickerDelegate?

    var sender: WSPalettePickerButton? {
        didSet {
            configurePopoverPresentation()
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: WSPalettePickerLayoutFlow())
        collection.register(WSPalettePickerSwachCell.self, forCellWithReuseIdentifier: "cell")
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        collection.delegate = self
        collection.dataSource = self
        return collection
    }()
    
    var colors: [UIColor] {
        return dataSource?.palettePickerColors(pickerController: self) ?? []
    }
    
    private func configurePopoverPresentation() {
        modalPresentationStyle = .popover
        preferredContentSize = CGSize(width: 295, height: 295)
        
        guard let popover = popoverPresentationController else { return }
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender?.bounds ?? .zero
        popover.permittedArrowDirections = .any
    }
            
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])

        collectionView.reloadData()
    }

    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - Collection View
extension WSPalettePickerController: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? WSPalettePickerSwachCell else {
            return UICollectionViewCell()
        }
        
        let color = colors[indexPath.row]
        cell.color = color
        cell.isSelected = color == sender?.currentColor
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        SoundManager.shared.addHapticFeedbackWithStyle(style: .rigid)
        SoundManager.shared.playOnlyOnce(sound: .Tap)
        
        let color = colors[indexPath.row]

        dismiss(animated: true)
        self.sender?.currentColor = color
        self.delegate?.pickerDidSelect(color: color)
    }
}

// MARK: - Layout
@objc public class WSPalettePickerLayoutFlow: UICollectionViewFlowLayout {
    @objc override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        scrollDirection = .vertical
        minimumInteritemSpacing = 8
        sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    public override func prepare() {
        super.prepare()
        itemSize = CGSize(width: 50, height: 50)
    }

    public override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
}
