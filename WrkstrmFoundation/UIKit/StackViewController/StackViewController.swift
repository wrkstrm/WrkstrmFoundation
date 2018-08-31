import UIKit

public extension UIStackView {
    public convenience init(elements: [UIView]) {
        self.init()
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        distribution = .fill
        spacing = 0
        elements.forEach { addArrangedSubview($0) }
    }
}

public protocol GridDelegate: AnyObject {
    func view(for stack: UIStackView, indexPath: IndexPath) -> UIView
}

open class StackViewController: UIViewController {

    public enum Style {
        case elements([UIView])
        case grid(Grid)
    }

    public var style: Style

    private (set) var stack: UIStackView

    public weak var gridDelegate: GridDelegate?

    public init(style: Style) {
        self.style = style
        if case let .elements(views) = style {
            stack = UIStackView(elements: views)
        } else {
            stack = UIStackView(elements: [])
        }
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }

    func commonInit() {
        view.addSubview(stack)
        stack.constrainEqual(attribute: .width, to: view)
        stack.constrainEqual(attribute: .height, to: view)
        stack.center(in: view)
        view.backgroundColor = .white
    }

    public required init?(coder aDecoder: NSCoder) {
        style = .elements([])
        stack = UIStackView(elements: [])
        super.init(coder: aDecoder)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        if case let .grid(grid) = style {
            let vertical = UIStackView()
            vertical.axis = .vertical
            vertical.distribution = .fillEqually
            (0..<grid.rows).forEach { rowInt in
                let horizontal = UIStackView()
                horizontal.axis = .horizontal
                horizontal.distribution = .fillEqually
                (0..<grid.columns).forEach { columnInt in
                    let path = IndexPath(row: rowInt, section: columnInt)
                    if let view = gridDelegate?.view(for: stack,
                                                     indexPath: path) {
                        horizontal.addArrangedSubview(view)
                    } else {
                        let basicView = view(for: stack, indexPath: path)
                        horizontal.addArrangedSubview(basicView)
                    }
                }
                vertical.addArrangedSubview(horizontal)
            }
            stack.addArrangedSubview(vertical)
        }
    }

    open func view(for stack: UIStackView, indexPath: IndexPath) -> UIView {
        return UIView(frame: .zero)
    }
}
