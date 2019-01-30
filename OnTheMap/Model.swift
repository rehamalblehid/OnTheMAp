//
//  Model.swift
//  OnTheMap
//
//  Created by Reham on 25/12/2018.
//  Copyright © 2018 Reham. All rights reserved.
//

import Foundation
import UIKit
struct StudentInfo: Codable {
    var results: [StudentInformation]?
}

struct StudentInformation: Codable {
    
    let objectId: String?
    let uniqueKey: String?
    
    let firstName: String?
    let lastName: String?
    
    let mapString: String?
    let mediaURL: String?
    
    let latitude: Double?
    let longitude: Double?
    
    let createdAt: String?
    let updatedAt: String?
    
    var fullName: String? {
        guard let firstName = firstName, let lastName = lastName else {
            return ""
        }
        return "\(firstName) \(lastName)"
    }
}

struct Session: Codable {
    let id: String?
    let expiration: String?
}

struct Account: Codable {
    let key: String?
    let registered: Bool?
}

struct LoginInfo: Codable {
    let session: Session
    let account: Account
}

struct LocationId: Codable {
    let objectId: String?
    let createdAt: String?
}

struct UserManager: Codable {
    var locations = [StudentInformation]()
    static  var shared = UserManager()
}

class APICalls{
    static var shared = APICalls()
    var appDelegate: AppDelegate!
    
    func login(email:String, password:String,completion:  @escaping (String?,Bool?,Error?) -> Void){
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // encoding a JSON body from a string, can also use a Codable struct
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        
        let task = appDelegate.sharedSession.dataTask(with: request) { data, response, error in
    
            guard error == nil else {
                completion("",false,error)
               
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completion("Your request returned a status code other than 2xx!",false,nil)
                return
            }
            
            guard let data = data else {
                completion("No data was returned by the request!",false,nil)
                return
            }
            
            
            let decoder = JSONDecoder()
            /* subset response data! */
            let range = (5..<data.count)
            let newData = data.subdata(in: range)
            
            do {
                let parsedResult = try decoder.decode( LoginInfo.self, from: newData)
                print(parsedResult)
                
                guard let sessionID = parsedResult.session.id else {
                    completion("Cannot find key session ID",false,nil)
                    return
                }
                
                guard let registered = parsedResult.account.registered, registered == true else {
                    completion("Cannot found the user",false,nil)
                    return
                }
                
                guard let userID = parsedResult.account.key else {
                    completion("Cannot find key user key",false,nil)
                    return
                }
                
                self.appDelegate.sessionID = sessionID
                self.appDelegate.userID = userID
                completion("",true,nil)
               // self.completeLogin()
                
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
        }
        task.resume()
    }
    
    func logout(completion:  @escaping (String,Bool,Error?) -> Void){
        
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = appDelegate.sharedSession.dataTask(with: request) { data, response, error in
            
            guard error == nil else{
                completion("There was an error performing your request",false,error)
                return
            }
            guard let data = data else {
                completion("No data was returned by the request!",false,error)
                return
            }
            
            let range = (5..<data.count)
            let newData = data.subdata(in: range)
            print(String(data: newData, encoding: .utf8)!)
            completion("",true,nil)
        }
        task.resume()
    }
    
    
    func getStudentLocation(completion:  @escaping ([StudentInformation]?,Error?) -> Void){
        
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?order=-updatedAt&limit=100")!)
        
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in

            guard  error == nil, let data = data  else {
                completion(nil, error)
                return }
            
            let decoder = JSONDecoder()
            
            do {
                let result = try decoder.decode(StudentInfo.self, from: data)
                //print(result.results![0].fullName)
                
                completion(result.results!,nil)
            } catch {
                print("json error: \(error.localizedDescription)")
            }
            
        }
        task.resume()
    }
    
    
    func postLocation(locationName:String,mediaURL:String,latitude:Double, longitude:Double, completion:  @escaping (String,Bool,Error?) -> Void){
        
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = "{\"uniqueKey\": \"\(self.appDelegate.userID!)\", \"firstName\": \"Test\", \"lastName\": \"Test\",\"mapString\": \"\(locationName)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: .utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                completion("Can not post new location",false,error)
                return
            }
            
            guard let data = data else {
                completion("",false,nil)
                return
            }
           
            let decoder = JSONDecoder()
            do {
                let result = try decoder.decode(LocationId.self, from: data)
                print(result)
                completion("",true,nil)
            } catch {
                print("json error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}


