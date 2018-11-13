
import UIKit

public class UnrelatedObjectCell: UITableViewCell {

    @IBOutlet weak var objectIdLabel: UILabel!
    @IBOutlet weak var connectedRelationSwitch: UISwitch!    
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
}
