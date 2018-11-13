
import UIKit

public class BackendlessRelationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var tableName: String!
    private var relationsColumnName: String!
    private var parentObject: [String : Any]!
    private var objects = [[String : Any]]()
    private var findFirst = false
    private var findLast = false
    private var findById: String?
    private var dataQueryBuilder: DataQueryBuilder?
    private var relationsQueryBuilder: LoadRelationsQueryBuilder!
    
    private var tableView: UITableView!
    
    @objc public func configureWith(tableName: String, relationsColumnName: String, parentObject: [String : Any]) {
        self.tableName = tableName
        self.relationsColumnName = relationsColumnName
        self.parentObject = parentObject
        relationsQueryBuilder = LoadRelationsQueryBuilder.ofMap()!
        relationsQueryBuilder.setRelationName(relationsColumnName)
    }
    
    @objc public func configureWith(tableName: String, relationsColumnName: String, findFirst: Bool) {
        self.tableName = tableName
        self.relationsColumnName = relationsColumnName
        self.findFirst = findFirst
        relationsQueryBuilder = LoadRelationsQueryBuilder.ofMap()!
        relationsQueryBuilder.setRelationName(relationsColumnName)
    }
    
    @objc public func configureWith(tableName: String, relationsColumnName: String, findFirst: Bool, dataQueryBuilder: DataQueryBuilder) {
        self.configureWith(tableName: tableName, relationsColumnName: relationsColumnName, findFirst: findFirst)
        self.dataQueryBuilder = dataQueryBuilder
    }
    
    @objc public func configureWith(tableName: String, relationsColumnName: String, findLast: Bool) {
        self.tableName = tableName
        self.relationsColumnName = relationsColumnName
        self.findLast = findLast
        relationsQueryBuilder = LoadRelationsQueryBuilder.ofMap()!
        relationsQueryBuilder.setRelationName(relationsColumnName)
    }
    
    @objc public func configureWith(tableName: String, relationsColumnName: String, findLast: Bool, dataQueryBuilder: DataQueryBuilder) {
        self.configureWith(tableName: tableName, relationsColumnName: relationsColumnName, findLast:findLast)
        self.dataQueryBuilder = dataQueryBuilder
    }
    
    @objc public func configureWith(tableName: String, relationsColumnName: String, findById: String) {
        self.tableName = tableName
        self.relationsColumnName = relationsColumnName
        self.findById = findById
        relationsQueryBuilder = LoadRelationsQueryBuilder.ofMap()!
        relationsQueryBuilder.setRelationName(relationsColumnName)
    }
    
    @objc public func configureWith(tableName: String, relationsColumnName: String, findById: String, dataQueryBuilder: DataQueryBuilder) {
        self.configureWith(tableName: tableName, relationsColumnName: relationsColumnName, findById: findById)
        self.dataQueryBuilder = dataQueryBuilder
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "\(tableName ?? "") related \(relationsColumnName ?? "") objects"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pressedAddRelation))
        
        let relationsTableView = BackendlessRelationsView.init(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        view = relationsTableView
        tableView = relationsTableView.tableView
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
        if findFirst {
            dataStore?.findFirst(dataQueryBuilder, response: { foundObject in
                let firstObject = foundObject as! [String : Any]
                self.parentObject = firstObject
                if self.relationsQueryBuilder != nil {
                    dataStore?.loadRelations(firstObject["objectId"] as? String, queryBuilder: self.relationsQueryBuilder, response: { relatedObjects in
                        self.objects = relatedObjects as! [[String : Any]]
                        self.tableView.reloadData()
                    }, error: { fault in
                        AlertViewController.shared.showErrorAlert(fault!, nil, self)
                    })
                }
            }, error: { fault in
                AlertViewController.shared.showErrorAlert(fault!, nil, self)
            })
        }
        else if findLast {
            dataStore?.findLast(dataQueryBuilder, response: { foundObject in
                let lastObject = foundObject as! [String : Any]
                self.parentObject = lastObject
                if self.relationsQueryBuilder != nil {
                    dataStore?.loadRelations(lastObject["objectId"] as? String, queryBuilder: self.relationsQueryBuilder, response: { relatedObjects in
                        self.objects = relatedObjects as! [[String : Any]]
                        self.tableView.reloadData()
                    }, error: { fault in
                        AlertViewController.shared.showErrorAlert(fault!, nil, self)
                    })
                }
            }, error: { fault in
                AlertViewController.shared.showErrorAlert(fault!, nil, self)
            })
        }
        else if findById != nil {
            dataStore?.find(byId: findById, queryBuilder: dataQueryBuilder, response: { foundObject in
                let foundObj = foundObject as! [String : Any]
                self.parentObject = foundObj
                dataStore?.loadRelations(foundObj["objectId"] as? String, queryBuilder: self.relationsQueryBuilder, response: { relatedObjects in
                    self.objects = relatedObjects as! [[String : Any]]
                    self.tableView.reloadData()
                }, error: { fault in
                    AlertViewController.shared.showErrorAlert(fault!, nil, self)
                })
            }, error: { fault in
                AlertViewController.shared.showErrorAlert(fault!, nil, self)
            })
        }
    }
    
    func loadObjects() {
        let dataStore = Backendless.sharedInstance()?.data.ofTable(tableName)
        if self.relationsQueryBuilder != nil {
            dataStore?.loadRelations(parentObject?["objectId"] as? String, queryBuilder: self.relationsQueryBuilder, response: { relatedObjects in
                self.objects = relatedObjects as! [[String : Any]]
                self.tableView.reloadData()
            }, error: { fault in
                AlertViewController.shared.showErrorAlert(fault!, nil, self)
            })
        }
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
            let relatedObject = objects[indexPath.row]
            let relatedTableName = relatedObject["___class"] as! String
            let objectDetailsVC = BackendlessObjectDetailsViewController()
            objectDetailsVC.configureWith(tableName: relatedTableName, object: relatedObject, previousViewController: self)
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
            if let parentId = parentObject!["objectId"] as? String {
                if let childObjectId = object["objectId"] as? String {
                    Backendless.sharedInstance()?.data!.ofTable(tableName)?.deleteRelation(relationsColumnName, parentObjectId: parentId, childObjects: [childObjectId], response: { relationRemoved in
                        self.objects.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }, error: { fault in
                        AlertViewController.shared.showErrorAlert(fault!, nil, self)
                    })
                }
            }
        }
    }
    
    @IBAction func pressedAddRelation() {
        Backendless.sharedInstance()?.data.describe(tableName, response: { properties in
            var unrelatedObjects = [[String : Any]]()
            let relatedTableName = properties?.first(where: { $0.name == self.relationsColumnName })?.relatedTable
            
            Backendless.sharedInstance()?.data.ofTable(relatedTableName)?.find({ allObjects in
                for object in allObjects as! [[String : Any]] {
                    if !self.objects.contains(where: { $0["objectId"] as! String == object["objectId"] as! String }) {
                        unrelatedObjects.append(object)
                    }
                }
                let addRelationsVC = BackendlessAddRelationsViewController()
                addRelationsVC.configureWith(unrelatedObjects: unrelatedObjects, parentObjectd: self.parentObject?["objectId"] as! String, parentTableName: self.tableName, columnName: self.relationsColumnName, previousViewController: self)
                self.navigationController?.pushViewController(addRelationsVC, animated: true)
            }, error: { fault in
                AlertViewController.shared.showErrorAlert(fault!, nil, self)
            })
        }, error: { fault in
            AlertViewController.shared.showErrorAlert(fault!, nil, self)
        })   
    }
}
