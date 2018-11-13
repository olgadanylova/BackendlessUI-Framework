
import UIKit

public class BackendlessAddRelationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var parentTableName: String!
    private var columnName: String!
    private var parentId: String!
    private var objects = [[String : Any]]()
    
    private var tableView: UITableView!
    private var previousViewController: UIViewController!
    
    @objc public func configureWith(unrelatedObjects: [[String : Any]], parentObjectd: String, parentTableName: String, columnName: String, previousViewController: UIViewController) {
        self.previousViewController = previousViewController
        self.objects = unrelatedObjects
        self.parentId = parentObjectd
        self.parentTableName = parentTableName
        self.columnName = columnName
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Add relations"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(pressedSave))
        
        let addRelationsTableView = BackendlessAddRelationsView.init(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        view = addRelationsTableView
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "UnrelatedObjectCell", bundle: bundle)
        tableView = addRelationsTableView.tableView
        tableView.register(nib, forCellReuseIdentifier: "UnrelatedObjectCell")
        tableView.delegate = self
        tableView.dataSource = self     
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UnrelatedObjectCell") as! UnrelatedObjectCell
        cell.objectIdLabel.text = objects[indexPath.row]["objectId"] as? String
        return cell
    }
    
    @IBAction func pressedSave() {
        var relatedObjects = [String]()
        for i in 0...objects.count - 1 {
            let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! UnrelatedObjectCell
            if cell.connectedRelationSwitch.isOn {
                relatedObjects.append(cell.objectIdLabel.text!)
            }
        }
        
        Backendless.sharedInstance()?.data!.ofTable(parentTableName)?.addRelation(columnName, parentObjectId: parentId, childObjects: relatedObjects, response: { relationsAdded in
            AlertViewController.shared.showRelationsAddedAlert({ action in
                self.navigationController?.popToViewController(self.previousViewController, animated: true)
            }, self)
        }, error: { fault in
            AlertViewController.shared.showErrorAlert(fault!, nil, self)
        })        
    }
}
