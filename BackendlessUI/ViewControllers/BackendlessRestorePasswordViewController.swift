
import UIKit

public class BackendlessRestorePasswordViewController: UIViewController, UITextFieldDelegate {
    
    private var scrollView: UIScrollView!
    private var emailField: UITextField!
    private var restorePasswordButton: UIButton!

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Restore password"
        
        emailField?.delegate = self
        
        let restorePasswordView = BackendlessRestorePasswordView.init(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        view = restorePasswordView
        scrollView = restorePasswordView.scrollView
        emailField = restorePasswordView.emailField
        restorePasswordButton = restorePasswordView.restorePasswordButton
        restorePasswordButton.addTarget(self, action: #selector(restorePassword(_:)), for: .touchUpInside)
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
    
    func clearFields() {
        view.endEditing(true)
        emailField.text = ""
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
    
    @IBAction func restorePassword(_ sender: UIButton!) {
        if !(emailField?.text?.isEmpty)! {
            Backendless.sharedInstance().userService.restorePassword(emailField.text, response: {
                self.clearFields()
                AlertViewController.shared.showRestorePasswordAlert(nil, self)
            }, error: { fault in
                self.clearFields()
                AlertViewController.shared.showErrorAlert(fault!, nil, self)
            })
        }
        else {
            clearFields()
            let fault = Fault(message: "Please make sure to fill the email field correctly")
            AlertViewController.shared.showErrorAlert(fault!, nil, self)
        }
    }
}
