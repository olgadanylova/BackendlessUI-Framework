
import UIKit

public class BackendlessAddObjectPropertyViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private var tableName: String!
    private var object: [String : Any]!
    private var previousViewController: UIViewController!
    
    private var scrollView: UIScrollView!
    private var propertyNameField: UITextField!
    private var propertyValueField: UITextField!
    private var propertyTypePicker: UIPickerView!
    private var addPropertyButton: UIButton!
    private var editingTextField: UITextField?
    private var editingDatePicker: UIDatePicker?
    private var pickerData: [String] = [String]()
    private var selectedType: String?
    
    private let stringType = "STRING"
    private let dateType = "DATE"
    private let intType = "INT"
    private let doubleType = "DOUBLE"
    private let boolType = "BOOLEAN"
    
    @objc public func configureWith(tableName: String, object:[String : Any], previousViewController: UIViewController) {
        self.tableName = tableName
        self.object = object
        self.previousViewController = previousViewController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Add property"
        
        let backendlessAddObjectPropertyView = BackendlessAddObjectPropertyView.init(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        view = backendlessAddObjectPropertyView        
        scrollView = backendlessAddObjectPropertyView.scrollView
        propertyNameField = backendlessAddObjectPropertyView.propertyNameField
        propertyValueField = backendlessAddObjectPropertyView.propertyValueField
        propertyTypePicker = backendlessAddObjectPropertyView.propertyTypePicker
        addPropertyButton = backendlessAddObjectPropertyView.addPropertyButton
        addPropertyButton?.addTarget(self, action: #selector(addProperty(_:)), for: .touchUpInside)
        
        propertyNameField?.delegate = self
        propertyValueField?.delegate = self
        
        propertyTypePicker.dataSource = self
        propertyTypePicker.delegate = self
        
        pickerData = [stringType, dateType, intType, doubleType, boolType]
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)        
        return true
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        editingTextField?.resignFirstResponder()
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        editingTextField = textField
        
        let selectedTypeIndex = propertyTypePicker.selectedRow(inComponent: 0)
        selectedType = pickerData[selectedTypeIndex]
        
        if selectedType == dateType {
            pickUpDate(propertyValueField)
        }
        else {
            propertyValueField.inputView = nil
            propertyValueField.inputAccessoryView = nil
            
            if selectedType == stringType {
                propertyValueField.keyboardType = .default
            }
            else if selectedType == intType {
                propertyValueField.keyboardType = .numberPad
            }
            else if selectedType == doubleType {
                propertyValueField.keyboardType = .numbersAndPunctuation
            }
            else if selectedType == boolType {
                propertyValueField.keyboardType = .numberPad
            }
        }
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        editingTextField = nil
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
    
    @IBAction func keyboardWillShow(notification:NSNotification){
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset:UIEdgeInsets = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 100
        scrollView.contentInset = contentInset
    }
    
    @IBAction func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    @IBAction func addProperty(_ sender: UIButton!) {
        if propertyNameField.text != "" && propertyValueField.text != "" {
            let key = propertyNameField.text!
            
            if object[key] == nil {
                if selectedType == stringType {
                    object[key] = propertyValueField.text
                }
                else if selectedType == dateType {
                    object[key] = stringToDate(propertyValueField.text)
                }
                else if selectedType == intType {
                    object[key] = Int(propertyValueField.text!)
                }
                else if selectedType == doubleType {
                    object[key] = Double(propertyValueField.text!)
                }
                else if selectedType == boolType {
                    let intValue = Int(propertyValueField.text!)
                    object[key] = NSNumber(value: intValue!).boolValue
                }
                
                Backendless.sharedInstance()?.data.ofTable(tableName)?.save(object, response: { updatedObject in
                    AlertViewController.shared.showPropertyAddedAlert({ action in
                        self.view.endEditing(true)
                        self.navigationController?.popToViewController(self.previousViewController, animated: true)
                    }, self)
                }, error: { fault in
                    AlertViewController.shared.showErrorAlert(fault!, nil, self)
                })
            }
            else {
                AlertViewController.shared.showPropertyExistsAlert({ action in
                    self.clearFields()
                }, self, key)
            }
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
    
    func clearFields() {
        view.endEditing(true)
        propertyTypePicker.selectRow(0, inComponent: 0, animated: true)
        propertyNameField.text = ""
        propertyValueField.text = ""
    }   
}
