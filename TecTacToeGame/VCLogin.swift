import UIKit
import FirebaseAuth
import FirebaseDatabase

class VCLogin: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      ref = Database.database().reference()
        if let useruid = Auth.auth().currentUser {
            GoToPlay()
        }
    }

    func SplitEmail(email:String)->String{
        let arrayEmail = email.split(separator: "@")
        return String(arrayEmail[0])
    }
  
    @IBAction func buRegister(_ sender: Any) {
        Auth.auth().createUser(withEmail: txtEmail.text!, password: txtPassword.text!) { (user, error) in
            if error != nil {
                print(error?.localizedDescription)
            }else{
                print(user?.uid)
                self.ref.child("TecTacToe").child("Users").child(self.SplitEmail(email: (user?.email!)!)).child("Request").setValue(user?.uid)
                self.GoToPlay()
            }
        }
    }
    func GoToPlay(){
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goToGame", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToGame" {
            if let VCGoPlay = segue.destination as? ViewController{
                if let user = Auth.auth().currentUser{
                    VCGoPlay.UserUID = user.uid
                    VCGoPlay.UserEmail = user.email
                }
            }
        }
    }
}
