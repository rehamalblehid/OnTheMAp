//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Reham on 25/12/2018.
//  Copyright © 2018 Reham. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
   
    
    
    
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "pull to refresh")
        
        refresher.addTarget(self, action: #selector(TableViewController.refreshTable), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refresher)
        refreshTable()
        

        APICalls.shared.getStudentLocation { (studentsInfo, error) in
            
            guard error == nil  else {
                let errorAlert = UIAlertController(title: "Error", message: "There was an error performing your request", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)

                return
            }
            
            guard let studentsInfo = studentsInfo else {
                 let locationsErrorAlert = UIAlertController(title: "Erorr loading locations", message: "There was an error loading locations", preferredStyle: .alert )
                locationsErrorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(locationsErrorAlert, animated: true, completion: nil)
                return }
            DispatchQueue.main.async {
                
                UserManager.shared.locations = studentsInfo
                self.tableView.reloadData()
            }
        } 
    }
    
    @objc func refreshTable(){
        APICalls.shared.getStudentLocation { (studentsInfo, error) in
            guard error == nil else {
                let errorAlert = UIAlertController(title: "Error", message: "There was an error performing your request", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)

                return
            }
            guard let studentsInfo = studentsInfo else {
                let locationsErrorAlert = UIAlertController(title: "Erorr loading locations", message: "There was an error loading locations", preferredStyle: .alert )
                locationsErrorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(locationsErrorAlert, animated: true, completion: nil)
                return }
            DispatchQueue.main.async {
                UserManager.shared.locations = studentsInfo
                print("refreshed")
                self.tableView.reloadData()
                self.refresher.endRefreshing()
            }
        }
  
    }
    
    @IBAction func refresh(_ sender: Any) {
        refreshTable()
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        
        APICalls.shared.logout { (message, result, error) in
            guard error == nil else {
                let errorAlert = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
                return
            }
            
            guard result == true else {
                let errorAlert = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
                return
            }
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
            self.present(controller, animated: true, completion: nil)
        }
    }
    
}

extension TableViewController:  UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserManager.shared.locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        
            cell.textLabel?.text = UserManager.shared.locations[indexPath.row].fullName
            cell.detailTextLabel?.text = UserManager.shared.locations[indexPath.row].mediaURL
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard UserManager.shared.locations[indexPath.row].mediaURL != "" else{
            
            return
        }
        let app = UIApplication.shared
        if let toOpen = UserManager.shared.locations[indexPath.row].mediaURL {
            app.open(URL(string: toOpen)!)
        }
        
    }
  
}
