
import UIKit

public class ObjectDetailCell: UITableViewCell {

    @IBOutlet var propertyField: UITextField!
    @IBOutlet var valueField: UITextField!
    
    var relatedObjects: Any?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
}
