
import UIKit

public class BackendlessLoginViewController: UIViewController, UITextFieldDelegate {
    
    private var scrollView: UIScrollView!
    private var emailField: UITextField!
    private var passwordField: UITextField!
    private var loginButton: UIButton!

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Login"
        
        emailField?.delegate = self
        passwordField?.delegate = self
        
        let loginView = BackendlessLoginView.init(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        view = loginView
        scrollView = loginView.scrollView
        emailField = loginView.emailField
        passwordField = loginView.passwordField
        loginButton = loginView.loginButton
        loginButton?.addTarget(self, action: #selector(login(_:)), for: .touchUpInside)
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
        passwordField.text = ""
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
    
    @IBAction func login(_ sender: UIButton!) {
        if !(emailField?.text?.isEmpty)! && !(passwordField?.text?.isEmpty)! {
            Backendless.sharedInstance().userService.login(emailField.text, password: passwordField.text, response: { loggedInUser in
                self.clearFields()
                AlertViewController.shared.showLoginCompleteAlert(nil, self)
            }, error: { fault in
                self.clearFields()
                AlertViewController.shared.showErrorAlert(fault!, nil, self)
            })
        }
        else {
            clearFields()
            let fault = Fault(message: "Please make sure to fill the email and password fields correctly")
            AlertViewController.shared.showErrorAlert(fault!, nil, self)
        }
    }
}
