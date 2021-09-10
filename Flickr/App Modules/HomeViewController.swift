//
//  HomeViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.09.2021.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//extension HomeViewController: PostViewDelegate {
//    func close() {
//        <#code#>
//    }
//    
//}
//
//protocol PostViewDelegate: AnyObject {
//    func close()
//}
