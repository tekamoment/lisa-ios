//
//  BookingsTableViewController.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/18/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit

class BookingsTableViewController: UITableViewController {

    var bookings: [Booking]? = nil
    var loginDetails: LoginDetails? = nil
    var notLoggedInView: SettingsNotLoggedInView! = {
        let view = SettingsNotLoggedInView()
        view.notLoggedInMessageLabel.text = "Please sign in to access your Bookings."
        view.frame = .zero
        return view
    }()
    
    @objc func signInOrRegisterTapped(sender: Any) {
        let signInVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginController")
        present(signInVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshBookings))
        self.navigationItem.title = "Temporary Bookings View"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func setupLogInView() {
        self.navigationController?.view.addSubview(notLoggedInView)
        notLoggedInView.frame = view.frame
        notLoggedInView.signInOrRegisterButton.addTarget(self, action: #selector(signInOrRegisterTapped(sender:)), for: UIControl.Event.touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let login = CombinedUserInformation.shared.loginDetails() else {
            loginDetails = nil
            setupLogInView()
            return
        }
        
        loginDetails = login
        refreshBookings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let navController = self.navigationController, navController.view.subviews.contains(notLoggedInView) {
            notLoggedInView.removeFromSuperview()
        }
    }
    
    @objc func refreshBookings() {
        guard let loginDetails = loginDetails else {
            return
        }
        let bookingRequest = NetworkRequest(url: URL(string: AppAPIBase.BookingsPath)!, method: .GET, data: nil, headers: AppAPIBase.standardHeaders(withToken: loginDetails.accessToken))
        bookingRequest.execute { (data) in
            guard let data = data else {
                self.displayAlertWithOK(title: "Fetching error", body: "Looks like there was an error fetching the bookings.")
                return
            }
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            if let bookings = try? jsonDecoder.decode([Booking].self, from: data) {
                self.bookings = bookings
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let loginDetails = loginDetails, let bookings = bookings else {
            return 0
        }
        return bookings.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        guard let bookings = bookings else {
            return cell
        }

        let booking = bookings[indexPath.item]
        cell.textLabel?.text = "Booking ID \(booking.id), status: \(booking.status)"
        
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let bookings = bookings else {
            return
        }
        
        let booking = bookings[indexPath.item]
        
        displayAlertWithOK(title: "Booking details", body: "Booking ID \(booking.id), \nstatus: \(booking.status), \nstart_time: \(booking.datetimeRequested), \nduration: \(booking.durationInMinutes / 60) hours, \namount: \(booking.totalAmount) \ncomment: \(booking.comment ?? "[no comment provided]" )")
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
