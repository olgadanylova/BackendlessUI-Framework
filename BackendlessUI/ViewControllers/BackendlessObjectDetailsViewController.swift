
import UIKit

public class BackendlessObjectDetailsViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    private var tableName: String!
    private var object: [String : Any]!
    private var previousViewController: UIViewController!
    private var isEditModeEnabled: Bool = false
    
    private var tableView: UITableView!
    private var toolbar: UIToolbar!
    private var toolbarCancelButton: UIBarButtonItem!
    private var toolbarSaveButton: UIBarButtonItem!
    private var toolbarDeleteButton: UIBarButtonItem!
    private var toolbarHelpButton: UIBarButtonItem!
    private var editingTextField: UITextField?
    private var editingDatePicker: UIDatePicker?
    
    private let dateTextFieldIdentifier = "dateTextField"
    private let intTextFieldIdentifier = "intTextField"
    private let doubleTextFieldIdentifier = "doubleTextField"
    private let boolTextFieldIdentifier = "boolTextField"
    
    @objc public func configureWith(tableName: String, object:[String : Any], previousViewController: UIViewController) {
        self.tableName = tableName
        self.object = object
        self.previousViewController = previousViewController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let backendlessObjectDetailsView = BackendlessObjectDetailsView.init(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        view = backendlessObjectDetailsView
        
        toolbar = backendlessObjectDetailsView.toolbar
        
        toolbarCancelButton = backendlessObjectDetailsView.toolbarCancelButton
        toolbarCancelButton.action = #selector(toolbarCancelPressed)
        
        toolbarSaveButton = backendlessObjectDetailsView.toolbarSaveButton
        toolbarSaveButton.action = #selector(toolbarSavePressed)
        
        toolbarDeleteButton = backendlessObjectDetailsView.toolbarDeleteButton
        toolbarDeleteButton.action = #selector(toolbarDeletePressed)
        
        toolbarHelpButton = backendlessObjectDetailsView.toolbarHelpButton
        toolbarHelpButton.action = #selector(toolbarHelpPressed)
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ObjectDetailCell", bundle: bundle)
        tableView = backendlessObjectDetailsView.tableView
        tableView.register(nib, forCellReuseIdentifier: "ObjectDetailCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 50, right: 0);
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enableEditMode(false)
        addKeyboardHandlers()
        self.tableView.reloadData()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        enableEditMode(false)
        removeKeyboardHandlers()
    }
    
    func addKeyboardHandlers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    func removeKeyboardHandlers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func enableEditMode(_ enabled: Bool) {
        isEditModeEnabled = enabled
        if enabled {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pressedEdit))
            navigationItem.title = "Edit mode"
            toolbar.isHidden = false
        }
        else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(pressedEdit))
            navigationItem.title = "Object details"
            toolbar.isHidden = true
        }
        tableView.reloadData()
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return object.keys.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectDetailCell") as! ObjectDetailCell
        let key = Array(object.keys)[indexPath.row]
        cell.propertyField.text = key
        cell.valueField.delegate = self
        
        if let value = object[key] {
            if key == "___class" {
                cell.propertyField.text = "Table name"
                cell.valueField.text = value as? String
                cell.valueField.keyboardType = .default
            }
            Backendless.sharedInstance()?.data.describe(tableName, response: { properties in
                let property = properties?.first(where: { $0.name == key })
                let type = property?.type
                
                if type == "STRING_ID" || type == "STRING" || type == "TEXT" {
                    if !(value is NSNull) {
                        cell.valueField.text = value as? String
                    }
                    cell.valueField.keyboardType = .default
                }
                else if type == "DATETIME" {
                    if !(value is NSNull) {
                        cell.valueField.text = self.dateToString(value as! Date)
                    }
                    cell.valueField.accessibilityIdentifier = self.dateTextFieldIdentifier
                    cell.valueField.keyboardType = .default
                }
                else if type == "INT" {
                    if !(value is NSNull) {
                        cell.valueField.text = String(format:"%i", value as! Int)
                    }
                    cell.valueField.accessibilityIdentifier = self.intTextFieldIdentifier
                    cell.valueField.keyboardType = .numberPad
                }
                else if type == "DOUBLE" {
                    if !(value is NSNull) {
                        cell.valueField.text = String(format:"%f", value as! Double)
                    }
                    cell.valueField.accessibilityIdentifier = self.doubleTextFieldIdentifier
                    cell.valueField.keyboardType = .numbersAndPunctuation
                }
                else if type == "BOOLEAN" {
                    if !(value is NSNull) {
                        cell.valueField.text = String(format: "%i", (NSNumber(booleanLiteral: value as! Bool)).intValue)
                    }
                    cell.valueField.accessibilityIdentifier = self.boolTextFieldIdentifier
                    cell.valueField.keyboardType = .numberPad
                }
                else if type == "RELATION" || type == "RELATION_LIST" {
                    cell.valueField.borderStyle = .none
                    cell.valueField.text = "Show"
                    cell.valueField.textColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
                    cell.isUserInteractionEnabled = true
                    cell.relatedObjects = value
                }
            }, error: { fault in
                AlertViewController.shared.showErrorAlert(fault!, nil, self)
            })
        }
        if isEditModeEnabled && key != "___class" && key != "objectId" && key != "ownerId" && key != "created" && key != "updated" && key != "socialAccount" && key != "userStatus" && key != "lastLogin" {
            cell.valueField.isUserInteractionEnabled = true
            cell.valueField.isEnabled = true
        }
        else {
            cell.valueField.isUserInteractionEnabled = false
            cell.valueField.isEnabled = false
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ObjectDetailCell
        if cell.relatedObjects != nil {
            let relationsTableVC = BackendlessRelationsViewController()
            relationsTableVC.configureWith(tableName: tableName, relationsColumnName: cell.propertyField.text!, parentObject: object)
            navigationController?.pushViewController(relationsTableVC, animated: true)
        }
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let key = Array(object.keys)[indexPath.row]
        if isEditModeEnabled && key != "___class" && key != "objectId" && key != "ownerId" && key != "created" && key != "updated" && key != "socialAccount" && key != "userStatus" && key != "lastLogin" && key != "email" {            
            return true
        }
        return false
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {            
            let cell = tableView.cellForRow(at: indexPath) as! ObjectDetailCell
            let key = cell.propertyField.text
            object.removeValue(forKey: key!)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func pickUpDate(_ textField : UITextField) {
        // DatePicker
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        datePickerView.date = stringToDate(textField.text)
        textField.inputView = datePickerView
        editingDatePicker = datePickerView
        
        // ToolBar for DatePicker
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dateToolbarDonePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dateToolbarCancelPressed))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        editingTextField = textField
        
        if textField.accessibilityIdentifier == dateTextFieldIdentifier {
            pickUpDate(textField)
        }
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        let cell = textField.superview?.superview as! ObjectDetailCell
        editingTextField = nil
        
        if textField.accessibilityIdentifier == dateTextFieldIdentifier {
            object[cell.propertyField.text!] = stringToDate(textField.text!)
        }
        else if textField.accessibilityIdentifier == intTextFieldIdentifier {
            object[cell.propertyField.text!] = Int(textField.text!)
        }
        else if textField.accessibilityIdentifier == doubleTextFieldIdentifier {
            object[cell.propertyField.text!] = Double(textField.text!)
        }
        else if textField.accessibilityIdentifier == boolTextFieldIdentifier {
            object[cell.propertyField.text!] = NSString(string:textField.text!).boolValue
        }
        else {
            object[cell.propertyField.text!] = textField.text
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func keyboardWillShow(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        }
    }
    
    @IBAction func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 50, right: 0);
        })
    }
    
    @IBAction func pressedEdit() {
        if !isEditModeEnabled {
            enableEditMode(true)
        }
        else {
            let addObjectPropertyVC = BackendlessAddObjectPropertyViewController()
            addObjectPropertyVC.configureWith(tableName: tableName, object: object, previousViewController: previousViewController)
            navigationController?.pushViewController(addObjectPropertyVC, animated: true)
        }
    }
    
    @IBAction func dateToolbarCancelPressed() {
        editingTextField?.resignFirstResponder()
        editingDatePicker = nil
    }
    
    @IBAction func dateToolbarDonePressed() {
        editingTextField?.text = dateToString((editingDatePicker?.date)!)
        editingTextField?.resignFirstResponder()
        editingDatePicker = nil
    }
    
    @IBAction func toolbarCancelPressed() {
        enableEditMode(false)
    }
    
    @IBAction func toolbarSavePressed() {
        view.endEditing(true)
        Backendless.sharedInstance()?.data.ofTable(tableName)?.save(object, response: { updatedObject in
            AlertViewController.shared.showObjectUpdatedAlert(nil, self)
            self.enableEditMode(false)
        }, error: { fault in
            AlertViewController.shared.showErrorAlert(fault!, nil, self)
        })
    }
    
    @IBAction func toolbarDeletePressed() {
        view.endEditing(true)
        Backendless.sharedInstance()?.data.ofTable(tableName)?.remove(object, response: { removed in
            self.navigationController?.popToViewController(self.previousViewController, animated: true)
        }, error: { fault in
            AlertViewController.shared.showErrorAlert(fault!, nil, self)
        })
    }
    
    @IBAction func toolbarHelpPressed() {
        view.endEditing(true)
        let helpMessage = """
• Press '+' to add a new property
• Swipe to delete property
• Bool is represented as 0 or 1. Please make sure to put the correct value in necessary fields
"""
        AlertViewController.shared.showHelpAlert(nil, self, helpMessage)
    }
}
