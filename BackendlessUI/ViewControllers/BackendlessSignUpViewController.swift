
import UIKit

public class BackendlessSignUpViewController: UIViewController, UITextFieldDelegate {
    
    private var scrollView: UIScrollView!
    private var nameField: UITextField!
    private var emailField: UITextField!
    private var passwordField: UITextField!
    private var signUpButton: UIButton!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Sign up"
        
        let signUpView = BackendlessSignUpView.init(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        view = signUpView
        scrollView = signUpView.scrollView
        nameField = signUpView.nameField
        emailField = signUpView.emailField
        passwordField = signUpView.passwordField
        signUpButton = signUpView.signUpButton
        signUpButton?.addTarget(self, action: #selector(signUp(_:)), for: .touchUpInside)
        
        nameField?.delegate = self
        emailField?.delegate = self
        passwordField?.delegate = self
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
        nameField.text = ""
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
    
    @IBAction func signUp(_ sender: UIButton!) {
        if !(emailField?.text?.isEmpty)! && !(passwordField?.text?.isEmpty)! {
            let user = BackendlessUser()
            user.name = nameField?.text! as NSString?
            user.email = emailField?.text as NSString?
            user.password = passwordField?.text as NSString?
            
            Backendless.sharedInstance().userService.register(user, response: { registeredUser in
                self.clearFields()
                AlertViewController.shared.showRegistrationCompleteAlert(nil, self)
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
