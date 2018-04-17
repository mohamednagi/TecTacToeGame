import UIKit
import FirebaseDatabase

class ViewController: UIViewController {

    @IBOutlet weak var bu1: UIButton!
    @IBOutlet weak var bu2: UIButton!
    @IBOutlet weak var bu3: UIButton!
    @IBOutlet weak var bu4: UIButton!
    @IBOutlet weak var bu5: UIButton!
    @IBOutlet weak var bu6: UIButton!
    @IBOutlet weak var bu7: UIButton!
    @IBOutlet weak var bu8: UIButton!
    @IBOutlet weak var bu9: UIButton!
    var UserUID:String?
    var UserEmail:String?
    var ref: DatabaseReference!
    @IBOutlet weak var txtEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        incomingRequests()
    }
    @IBAction func buSelectEvent(_ sender: Any) {
        let buSender = sender as! UIButton
        self.ref.child("TicTacToe").child("PlayingOnline").child(SessionID!).child("\(buSender.tag)").setValue(UserEmail!)
//        playGame(buSelect: buSender)
    }
    var ActivePlayer = 1
    var player1 = [Int]()
    var player2 = [Int]()
    func playGame(buSelect:UIButton){
        if ActivePlayer == 1 {
            buSelect.setTitle("X", for: UIControlState.normal)
            buSelect.backgroundColor = UIColor(red: 102/255, green: 250/255, blue: 51/255, alpha: 0.5)
            player1.append(buSelect.tag)
            ActivePlayer = 2
//            autoPlay()
        }else{
            buSelect.setTitle("O", for: UIControlState.normal)
            buSelect.backgroundColor = UIColor(red: 32/255, green: 192/255, blue: 243/255, alpha: 0.5)
            player2.append(buSelect.tag)
            ActivePlayer = 1
        }
        buSelect.isEnabled = false
        findWinner()
    }
    func findWinner(){
        var winner = -1
        // row1
        if (player1.contains(1) && player1.contains(2) && player1.contains(3)){
            winner = 1
        }
        if (player2.contains(1) && player2.contains(2) && player2.contains(3)){
            winner = 2
        }
        // row2
        if (player1.contains(4) && player1.contains(5) && player1.contains(6)){
            winner = 1
        }
        if (player2.contains(4) && player2.contains(5) && player2.contains(6)){
            winner = 2
        }
        // row3
        if (player1.contains(7) && player1.contains(8) && player1.contains(9)){
            winner = 1
        }
        if (player2.contains(7) && player2.contains(8) && player2.contains(9)){
            winner = 2
        }
        // col1
        if (player1.contains(1) && player1.contains(4) && player1.contains(7)){
            winner = 1
        }
        if (player2.contains(1) && player2.contains(4) && player2.contains(7)){
            winner = 2
        }
        // row2
        if (player1.contains(2) && player1.contains(5) && player1.contains(8)){
            winner = 1
        }
        if (player2.contains(2) && player2.contains(5) && player2.contains(8)){
            winner = 2
        }
        // row3
        if (player1.contains(3) && player1.contains(6) && player1.contains(9)){
            winner = 1
        }
        if (player2.contains(3) && player2.contains(6) && player2.contains(9)){
            winner = 2
        }
        if winner != -1 {
            var msg = ""
            if winner == 1 {
                msg = "player1 wins"
            }else{
                msg="player2 wins"
            }
           // print(msg)
            var alert = UIAlertController(title: "Winner", message: msg, preferredStyle: .alert)
            var action = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    func autoPlay(cellID:Int){
        var buSelected:UIButton?
        switch cellID {
        case 1:
            buSelected = bu1
        case 2:
            buSelected = bu2
        case 3:
            buSelected = bu3
        case 4:
            buSelected = bu4
        case 5:
            buSelected = bu5
        case 6:
            buSelected = bu6
        case 7:
            buSelected = bu7
        case 8:
            buSelected = bu8
        case 9:
            buSelected = bu9
        default:
            buSelected = bu1
        }
        playGame(buSelect: buSelected!)
    }
    var PlayerSymbole:String?
    @IBAction func BuRequest(_ sender: Any) {
        self.ref.child("TecTacToe").child("Users").child(SplitEmail(email: (txtEmail.text)!)).child("Request").childByAutoId().setValue(UserEmail)
        PlayerSymbole = "X"
        playOnline(SessionID: "\(SplitEmail(email: UserEmail!)) \(SplitEmail(email: txtEmail.text!))")
    }
    @IBAction func BuAccept(_ sender: Any) {
        self.ref.child("TecTacToe").child("Users").child(SplitEmail(email: (txtEmail.text)!)).child("Request").childByAutoId().setValue(UserEmail)
        PlayerSymbole = "O"
        playOnline(SessionID: "\(SplitEmail(email: txtEmail.text!)) \(SplitEmail(email: UserEmail!))")
    }
    func SplitEmail(email:String)->String{
        let arrayEmail = email.split(separator: "@")
        return String(arrayEmail[0])
    }
    func incomingRequests(){
        self.ref.child("TecTacToe").child("Users").child(SplitEmail(email: (UserEmail)!)).child("Request").observe(.value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshot{
                    if let playRequest = snap.value as? String{
                        self.txtEmail.text = playRequest
                        self.ref.child("TecTacToe").child("Users").child(self.SplitEmail(email: (self.UserEmail)!)).child("Request").setValue(self.UserUID)
                    }
                }
            }
        }
    }
    var SessionID:String?
    func playOnline(SessionID:String){
        self.SessionID=SessionID
         self.ref.child("TicTacToe").child("PlayingOnline").child(SessionID).removeValue()
        self.ref.child("TicTacToe").child("PlayingOnline").child(SessionID).observe(.value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                self.player1.removeAll()
                self.player2.removeAll()
                for snap in snapshot{
                    if let PlayerEmail = snap.value as? String{
                        let keyCellID = snap.key as? String
                        if PlayerEmail == self.UserEmail {
                            self.ActivePlayer = self.PlayerSymbole == "X" ? 1: 2
                        }else{
                            self.ActivePlayer = self.PlayerSymbole == "X" ? 2: 1
                        }
                        self.autoPlay(cellID: Int(keyCellID!)!)
                    }
                }
            }
        }
    }
}
