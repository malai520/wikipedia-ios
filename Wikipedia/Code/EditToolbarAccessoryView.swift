import UIKit

@objc(WMFEditToolbarAccessoryViewButtonDelegate)
protocol EditToolbarAccessoryViewButtonDelegate: class {
    func editToolbarAccessoryViewDidTapTextFormattingButton(_ editToolbarAccessoryView: EditToolbarAccessoryView, button: UIButton)
    func editToolbarAccessoryViewDidTapHeaderFormattingButton(_ editToolbarAccessoryView: EditToolbarAccessoryView, button: UIButton)
    func editToolbarAccessoryViewDidTapAddCitationButton(_ editToolbarAccessoryView: EditToolbarAccessoryView, button: UIButton)
    func editToolbarAccessoryViewDidTapAddLinkButton(_ editToolbarAccessoryView: EditToolbarAccessoryView, button: UIButton)
    func editToolbarAccessoryViewDidTapUnorderedListButton(_ editToolbarAccessoryView: EditToolbarAccessoryView, button: UIButton)
    func editToolbarAccessoryViewDidTapOrderedListButton(_ editToolbarAccessoryView: EditToolbarAccessoryView, button: UIButton)
}

@objc(WMFEditToolbarAccessoryView)
class EditToolbarAccessoryView: UIView {
    @objc weak var buttonDelegate: EditToolbarAccessoryViewButtonDelegate?

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var chevronButton: UIButton!

    @objc static func loadFromNib() -> EditToolbarAccessoryView {
        let nib = UINib(nibName: "EditToolbarAccessoryView", bundle: Bundle.main)
        let view = nib.instantiate(withOwner: nil, options: nil).first as! EditToolbarAccessoryView
        return view
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        addTopShadow(with: Theme.standard)
        defaultViews.forEach { self.stackView.addArrangedSubview($0) }
        secondaryViews.forEach {
            $0.isHidden = true
            self.stackView.addArrangedSubview($0)
        }
        chevronButton.imageView?.contentMode = .scaleAspectFit
    }

    // MARK: Default actions

    private lazy var defaultViews: [UIView] = {
        return [
            button(withTitle: "A", action: #selector(formatText(_:))),
            button(withTitle: "H", action: #selector(formatHeader(_:))),
            button(withTitle: "C", action: #selector(addCitation(_:))),
            button(withTitle: "L", action: #selector(addLink(_:))),
            button(withTitle: "+", action: #selector(addUnorderedList(_:))), // todo selector
            button(withTitle: "*", action: #selector(addUnorderedList(_:))),
            button(withTitle: "1)", action: #selector(addOrderedList(_:)))
        ]
    }()

    // MARK: Secondary actions

    private lazy var secondaryViews: [UIView] = {
        return [
            button(withTitle: "🥗", action: #selector(formatText(_:))),
            button(withTitle: "🤣", action: #selector(formatText(_:))),
            button(withTitle: "🍕", action: #selector(formatText(_:))),
            button(withTitle: "😉", action: #selector(formatText(_:))),
            button(withTitle: "🤡", action: #selector(formatText(_:))),
            button(withTitle: "🤗", action: #selector(formatText(_:))),
            button(withTitle: "🚌", action: #selector(formatText(_:)))
        ]
    }()

    private func button(withTitle title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func button(withImage image: UIImage, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    // MARK: Button actions

    @objc private func formatText(_ sender: UIButton) {
        buttonDelegate?.editToolbarAccessoryViewDidTapTextFormattingButton(self, button: sender)
    }

    @objc private func formatHeader(_ sender: UIBarButtonItem) {
    }

    @objc private func addCitation(_ sender: UIBarButtonItem) {
    }

    @objc private func addLink(_ sender: UIBarButtonItem) {
    }

    @objc private func addUnorderedList(_ sender: UIBarButtonItem) {
    }

    @objc private func addOrderedList(_ sender: UIBarButtonItem) {
    }

    private enum ChevronButtonType: Int {
        case `default`
        case secondary
    }

    @IBAction func slideToRevealMoreActions(_ sender: UIButton) {
        let type = ChevronButtonType(rawValue: sender.tag)
        let transform = CGAffineTransform.identity
        let buttonAnimation: () -> Void
        let stackViewAnimation: () -> Void

        if type == .default {
            buttonAnimation = {
                sender.transform = transform.rotated(by: 180 * CGFloat.pi)
                sender.transform = transform.rotated(by: -1 * CGFloat.pi)
            }
            stackViewAnimation = {
                self.defaultViews.forEach { $0.isHidden = true }
                self.secondaryViews.forEach { $0.isHidden = false }
            }
            sender.tag = 1
        } else {
            buttonAnimation = {
                sender.transform = transform
            }
            stackViewAnimation = {
                self.secondaryViews.forEach { $0.isHidden = true }
                self.defaultViews.forEach { $0.isHidden = false }
            }
            sender.tag = 0
        }

        let buttonAnimator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.7, animations: buttonAnimation)
        let stackViewAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .linear, animations: stackViewAnimation)

        buttonAnimator.startAnimation()
        stackViewAnimator.startAnimation()
    }

    // MARK: Setting items

    private func setViews(_ views: [UIView], animated: Bool) {
        stackView.arrangedSubviews.forEach { $0.isHidden = true }
        views.forEach { self.stackView.addArrangedSubview($0) }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: bounds.height + 1)
    }

    // MARK: Shadow

    private func addTopShadow(with theme: Theme) {
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowRadius = 10
        layer.shadowColor = theme.colors.shadow.cgColor
        layer.shadowOpacity = 1.0
    }

}

    }
}
