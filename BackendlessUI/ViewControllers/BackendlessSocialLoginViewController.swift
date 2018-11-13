
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import TwitterKit
import GoogleSignIn

public class BackendlessSocialLoginViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {
    
    private var facebookLogin = false
    private var googleLogin = false
    private var twitterLogin = false
    
    @objc public func configureWith(facebookLogin: Bool, googleLogin: Bool, twitterLogin: Bool) {
        self.facebookLogin = facebookLogin
        self.googleLogin = googleLogin
        self.twitterLogin = twitterLogin
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Social login"
        
        let socialLoginView = BackendlessSocialLoginView.init(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        view = socialLoginView
        
        if facebookLogin {
            let logInButton = FBSDKLoginButton()
            logInButton.delegate = self
            logInButton.readPermissions = ["public_profile", "email"]
            setupButtonCenter(logInButton)
            self.view.subviews.first?.addSubview(logInButton)
        }
        if twitterLogin {
            let logInButton = TWTRLogInButton(logInCompletion: { session, error in
                if session != nil {
                    Backendless.sharedInstance().userService.login(withTwitterSDK: session?.authToken, authTokenSecret: session?.authTokenSecret, fieldsMapping: ["email":"email"], response: { user in
                        AlertViewController.shared.showLoginCompleteAlert(nil, self)
                    }, error: { fault in
                        AlertViewController.shared.showErrorAlert(fault!, nil, self)
                    })
                } else {
                    let fault = Fault(message: error!.localizedDescription)
                    AlertViewController.shared.showErrorAlert(fault!, nil, self)
                }
            })
            setupButtonCenter(logInButton)
            self.view.subviews.first?.addSubview(logInButton)
        }
        if googleLogin {
            let logInButton = GIDSignInButton()
            logInButton.style = .wide
            setupButtonCenter(logInButton)
            self.view.subviews.first?.addSubview(logInButton)
            GIDSignIn.sharedInstance().uiDelegate = self
        }
    }
    
    func setupButtonCenter(_ button: UIButton) {
        var subviews = (self.view.subviews.first?.subviews)!
        if subviews.count > 0 {
            subviews = subviews.sorted(by: { $0.center.y > $1.center.y })
            let buttonCenter = CGPoint(x: view.center.x, y: (subviews.first?.center.y)! + 50)
            button.center = buttonCenter
        }
        else {
            button.center = self.view.center
        }
    }
    
    func setupButtonCenter(_ button: UIControl) {
        var subviews = (self.view.subviews.first?.subviews)!
        if subviews.count > 0 {
            subviews = subviews.sorted(by: { $0.center.y > $1.center.y })
            let buttonCenter = CGPoint(x: view.center.x, y: (subviews.first?.center.y)! + 50)
            button.center = buttonCenter
        }
        else {
            button.center = self.view.center
        }
    }
    
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            let fault = Fault(message: error.localizedDescription)
            AlertViewController.shared.showErrorAlert(fault!, nil, self)
        }
        else {
            let accessToken = FBSDKAccessToken.current()
            if accessToken != nil {
                Backendless.sharedInstance().userService.login(withFacebookSDK: accessToken?.userID, tokenString: accessToken?.tokenString, expirationDate: accessToken?.expirationDate, fieldsMapping: ["email":"email"], response: { loggedUser in
                    AlertViewController.shared.showLoginCompleteAlert(nil, self)
                }, error: { fault in
                    AlertViewController.shared.showErrorAlert(fault!, nil, self)
                })
            }
        }
    }
    
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        Backendless.sharedInstance().userService.logout({
            AlertViewController.shared.showLogoutCompleteAlert(nil, self)
        }, error: { fault in
            AlertViewController.shared.showErrorAlert(fault!, nil, self)
        })
    }
    
    // Use this method to logout from Twitter
    /*Backendless.sharedInstance().userService.logout({
     if let userId = Twitter.sharedInstance().sessionStore.session()?.userID {
     Twitter.sharedInstance().sessionStore.logOutUserID(userId)
     print("LOGGED OUT")
     }
     }, error: { fault in
     print("Server reported an error: \(fault?.message ?? "")")
     })*/
    
    // Use this method to logout from Google
    /*Backendless.sharedInstance().userService.logout({
     GIDSignIn.sharedInstance().signOut()
     print("LOGGED OUT")
     }, error: { fault in
     print("Server reported an error: \(fault?.message ?? "")")
     })*/
}
