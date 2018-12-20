class TextFormattingTableViewController: TextFormattingProvidingTableViewController {

    override var titleLabelText: String? {
        return "Text formatting"
    }

    private struct Content {
        let type: ContentType
        let title: String?
        let detailText: String?
        let customView: (UIView & Themeable)?

        init(type: ContentType, title: String? = nil, detailText: String? = nil, customView: (UIView & Themeable)? = nil) {
            self.type = type
            self.title = title
            self.detailText = detailText
            self.customView = customView
        }
    }

    private enum ContentType {
        case customView
        case detail
    }

    private struct Item {
        let cell: TextFormattingTableViewCell.Type
        let content: Content
        let onSelection: (() -> Void)?

        init(with content: Content, onSelection: (() -> Void)? = nil) {
            switch content.type {
            case .customView:
                self.cell = TextFormattingCustomViewTableViewCell.self
            case .detail:
                self.cell = TextFormattingDetailTableViewCell.self
            }
            self.content = content
            self.onSelection = onSelection
        }
    }

    // MARK: - Items
    // Some are lazy, some need to be updated so they can't all be in a lazy array

    private var textStyle: Item {
        let showTextStyleFormattingTableViewController = {
            let textStyleFormattingTableViewController = TextStyleFormattingTableViewController.wmf_viewControllerFromStoryboardNamed("TextFormatting")
            textStyleFormattingTableViewController.delegate = self.delegate
            textStyleFormattingTableViewController.selectedTextStyleType = self.selectedTextStyleType
            self.navigationController?.pushViewController(textStyleFormattingTableViewController, animated: true)
        }
        return Item(with: Content(type: .detail, title: "Style", detailText: selectedTextStyleType.name), onSelection: showTextStyleFormattingTableViewController)
    }

    private let textFormattingToolbarView = TextFormattingToolbarView.wmf_viewFromClassNib()
    private let textFormattingGroupedToolbarView = TextFormattingGroupedToolbarView.wmf_viewFromClassNib()
    private let textFormattingButtonView = TextFormattingButtonView.wmf_viewFromClassNib()
    
    weak override var delegate: TextFormattingDelegate? {
        didSet {
            textFormattingToolbarView?.delegate = delegate
            textFormattingGroupedToolbarView?.delegate = delegate
            textFormattingButtonView?.delegate = delegate
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textFormattingButtonView?.buttonTitle = "Clear formatting"
        textFormattingButtonView?.buttonTitleColor = theme.colors.error
    }
    
    private lazy var staticItems: [Item] = {
        let toolbar = Item(with: Content(type: .customView, customView: textFormattingToolbarView))

        let groupedToolbar = Item(with: Content(type: .customView, customView: textFormattingGroupedToolbarView))

        let textSize = Item(with: Content(type: .detail, title: "Text size", detailText: "Normal"))

        let button = Item(with: Content(type: .customView, customView: textFormattingButtonView))

        return [toolbar, groupedToolbar, textSize, button]
    }()

    private var items: [Item] {
        var allItems = staticItems
        allItems.insert(textStyle, at: 2)
        return allItems
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let configuredCell = configuredCell(for: indexPath) else {
            assertionFailure("Expected a subclass of TextFormattingTableViewCell")
            return UITableViewCell()
        }
        return configuredCell
    }

    private func configuredCell(for indexPath: IndexPath) -> UITableViewCell? {
        let item = items[indexPath.row]
        let content = item.content
        let contentType = content.type

        switch contentType {
        case .customView:
            guard let cell = tableView.dequeueCell(ofType: TextFormattingCustomViewTableViewCell.self, for: indexPath) else {
                break
            }
            guard let customView = content.customView else {
                break
            }
            cell.configure(with: customView)
            cell.apply(theme: theme)
            return cell
        case .detail:
            guard let cell = tableView.dequeueCell(ofType: TextFormattingDetailTableViewCell.self, for: indexPath) else {
                break
            }
            guard
                let title = content.title,
                let detailText = content.detailText
            else {
                break
            }
            cell.apply(theme: theme)
            cell.configure(with: title, detailText: detailText)
            return cell
        }

        return nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        item.onSelection?()
    }

}

private extension UITableView {
    func dequeueCell<T: UITableViewCell>(ofType type: T.Type, for indexPath: IndexPath) -> T? {
        guard let cell = dequeueReusableCell(withIdentifier: type.identifier, for: indexPath) as? T else {
            assertionFailure("Could not dequeue cell of type \(T.self)")
            return nil
        }
        return cell
    }
}