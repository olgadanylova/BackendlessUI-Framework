
import UIKit

public class BackendlessTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var tableName: String!
    private var objects = [[String : Any]]()
    private var findFirst = false
    private var findLast = false
    private var findById: String?
    private var dataQueryBuilder: DataQueryBuilder?
    private var relationsQueryBuilder: LoadRelationsQueryBuilder?
    
    private var tableView: UITableView!
    
    @objc public func configureWith(tableName: String) {
        self.tableName = tableName
    }
    
    @objc public func configureWith(tableName: String, dataQueryBuilder: DataQueryBuilder) {
        self.configureWith(tableName: tableName)
        self.dataQueryBuilder = dataQueryBuilder
    }
    
    @objc public func configureWith(tableName: String, findFirst: Bool) {
        self.tableName = tableName
        self.findFirst = findFirst
    }
    
    @objc public func configureWith(tableName: String, findFirst: Bool, dataQueryBuilder: DataQueryBuilder) {
        self.configureWith(tableName: tableName, findFirst: findFirst)
        self.dataQueryBuilder = dataQueryBuilder
    }
    
    @objc public func configureWith(tableName: String, findLast: Bool) {
        self.tableName = tableName
        self.findLast = findLast
    }
    
    @objc public func configureWith(tableName: String, findLast: Bool, dataQueryBuilder: DataQueryBuilder) {
        self.configureWith(tableName: tableName, findLast: findLast)
        self.dataQueryBuilder = dataQueryBuilder
    }
    
    @objc public func configureWith(tableName: String, findById: String) {
        self.tableName = tableName
        self.findById = findById
    }
    
    @objc public func configureWith(tableName: String, findById: String, dataQueryBuilder: DataQueryBuilder) {
        self.configureWith(tableName: tableName, findById: findById)
        self.dataQueryBuilder = dataQueryBuilder
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = tableName
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pressedAddObject))
        
        let backendlessTableView = BackendlessTableView.init(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        view = backendlessTableView
        tableView = backendlessTableView.tableView
        tableView.register(UITableViewCell.ofClass(), forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let dataStore = Backendless.sharedInstance()?.data.ofTable(tableName)
        
        if dataQueryBuilder == nil {
            dataQueryBuilder = DataQueryBuilder()
        }
        if !findFirst && !findLast && findById == nil {
            loadObjects()
        }
        else {
            if findFirst {
                dataStore?.findFirst(dataQueryBuilder, response: { foundObject in
                    let firstObject = foundObject as! [String : Any]
                    self.objects.append(firstObject)
                    self.tableView.reloadData()
                }, error: { fault in
                    AlertViewController.shared.showErrorAlert(fault!, nil, self)
                })
            }
            else if findLast {
                dataStore?.findLast(dataQueryBuilder, response: { foundObject in
                    let lastObject = foundObject as! [String : Any]
                    self.objects.append(lastObject)
                    self.tableView.reloadData()
                }, error: { fault in
                    AlertViewController.shared.showErrorAlert(fault!, nil, self)
                })
            }
            else if findById != nil {
                dataStore?.find(byId: findById, queryBuilder: dataQueryBuilder, response: { foundObject in
                    let foundObj = foundObject as! [String : Any]
                    self.objects.append(foundObj)
                    self.tableView.reloadData()
                }, error: { fault in
                    AlertViewController.shared.showErrorAlert(fault!, nil, self)
                })
            }
        }
    }
    
    func loadObjects() {
        let dataStore = Backendless.sharedInstance()?.data.ofTable(tableName)      
        dataStore?.find(dataQueryBuilder, response: { foundObjects in
            self.objects += foundObjects as! [[String:Any]]
            self.tableView.reloadData()
            if ((self.dataQueryBuilder?.getOffset())! > Int32(0)) {
                self.dataQueryBuilder!.prepareNextPage()
                self.loadObjects()
            }
        }, error: { fault in
            AlertViewController.shared.showErrorAlert(fault!, nil, self)
        })
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let object = objects[indexPath.row]
        cell?.textLabel?.text = object["objectId"] as? String
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (objects.count > 0) {
            let objectDetailsVC = BackendlessObjectDetailsViewController()
            objectDetailsVC.configureWith(tableName: tableName, object: objects[indexPath.row], previousViewController: self)
            navigationController?.pushViewController(objectDetailsVC, animated: true)
            objects.removeAll()
        }
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let object = objects[indexPath.row]
            Backendless.sharedInstance()?.data.ofTable(tableName)?.remove(object, response: { removed in
                self.objects.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }, error: { fault in
                AlertViewController.shared.showErrorAlert(fault!, nil, self)
            })            
        }
    }
    
    @IBAction func pressedAddObject() {
        let addObjectVC = BackendlessAddObjectViewController()
        addObjectVC.configureWith(tableName: tableName, previousViewController: self)
        self.navigationController?.pushViewController(addObjectVC, animated: true)
        self.objects.removeAll()
    }
}
