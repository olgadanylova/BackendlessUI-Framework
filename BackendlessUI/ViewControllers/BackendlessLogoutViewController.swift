
import UIKit

public class BackendlessLogoutViewController: UIViewController {
    
    private var logoutButton: UIButton!

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Logout"
        
        let logoutView = BackendlessLogoutView.init(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        view = logoutView
        logoutButton = logoutView.logoutButton
        logoutButton.addTarget(self, action: #selector(logout(_:)), for: .touchUpInside)
    }
    
    @IBAction func logout(_ sender: UIButton!) {
        Backendless.sharedInstance().userService.logout({
            AlertViewController.shared.showLogoutCompleteAlert(nil, self)
        }, error: { fault in
            AlertViewController.shared.showLoginCompleteAlert(nil, self)
        })
    }
}
