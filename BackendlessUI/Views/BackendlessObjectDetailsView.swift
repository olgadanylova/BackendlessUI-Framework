
import UIKit

class BackendlessObjectDetailsView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var toolbarCancelButton: UIBarButtonItem!
    @IBOutlet weak var toolbarSaveButton: UIBarButtonItem!
    @IBOutlet weak var toolbarDeleteButton: UIBarButtonItem!
    @IBOutlet weak var toolbarHelpButton: UIBarButtonItem!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "BackendlessObjectDetailsView", bundle: bundle)
        self.contentView = nib.instantiate(withOwner: self, options: nil).first as? UIView
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
