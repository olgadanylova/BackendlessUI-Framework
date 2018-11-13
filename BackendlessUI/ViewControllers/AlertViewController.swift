
import UIKit

public class AlertViewController: UIAlertController {
    
    @objc public static let shared = AlertViewController()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc public func showErrorAlert(_ fault: Fault, _ alertAction: ((UIAlertAction) -> Void)?, _ target: UIViewController) {
        let alert = UIAlertController(title: "Error", message: fault.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: alertAction))
        target.present(alert, animated: true, completion: nil)
    }
    
    func showRegistrationCompleteAlert(_ alertAction: ((UIAlertAction) -> Void)?, _ target: UIViewController) {
        let alert = UIAlertController(title: "Registration complete", message: "User has been registered in Backendless", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: alertAction))
        target.present(alert, animated: true, completion: nil)
    }
    
    func showLoginCompleteAlert(_ alertAction: ((UIAlertAction) -> Void)?, _ target: UIViewController) {
        let alert = UIAlertController(title: "Login complete", message: "User has been logged in Backendless", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: alertAction))
        target.present(alert, animated: true, completion: nil)
    }
    
    func showLogoutCompleteAlert(_ alertAction: ((UIAlertAction) -> Void)?, _ target: UIViewController) {
        let alert = UIAlertController(title: "Logout complete", message: "User has been logged out from Backendless", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: alertAction))
        target.present(alert, animated: true, completion: nil)
    }
    
    func showRestorePasswordAlert(_ alertAction: ((UIAlertAction) -> Void)?, _ target: UIViewController) {
        let alert = UIAlertController(title: "Restore password", message: "Please check the instructions sent to the specified email address to restore the password", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: alertAction))
        target.present(alert, animated: true, completion: nil)
    }
    
    func showHelpAlert(_ alertAction: ((UIAlertAction) -> Void)?, _ target: UIViewController, _ helpMessage: String) {
        let alert = UIAlertController(title: "Help", message: helpMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: alertAction))
        target.present(alert, animated: true, completion: nil)
    }
    
    func showObjectCreatedAlert(_ alertAction: ((UIAlertAction) -> Void)?, _ target: UIViewController) {
        let alert = UIAlertController(title: "Object created", message: "New object created successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: alertAction))
        target.present(alert, animated: true, completion: nil)
    }
    
    func showObjectUpdatedAlert(_ alertAction: ((UIAlertAction) -> Void)?, _ target: UIViewController) {
        let alert = UIAlertController(title: "Object updated", message: "Object updated successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: alertAction))
        target.present(alert, animated: true, completion: nil)
    }
    
    func showPropertyExistsAlert(_ alertAction: ((UIAlertAction) -> Void)?, _ target: UIViewController, _ propertyName: String) {
        let message = "Property " + "'" + propertyName + "'" + " already exists. Please create property with another name"        
        let alert = UIAlertController(title: "Property exists", message:message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: alertAction))
        target.present(alert, animated: true, completion: nil)
    }
    
    func showPropertyAddedAlert(_ alertAction: ((UIAlertAction) -> Void)?, _ target: UIViewController) {
        let alert = UIAlertController(title: "Property added", message: "Property added successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: alertAction))
        target.present(alert, animated: true, completion: nil)
    }
    
    func showRelationsAddedAlert(_ alertAction: ((UIAlertAction) -> Void)?, _ target: UIViewController) {
        let alert = UIAlertController(title: "Relations added", message: "Relations added successfuly", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: alertAction))
        target.present(alert, animated: true, completion: nil)
    }
}
