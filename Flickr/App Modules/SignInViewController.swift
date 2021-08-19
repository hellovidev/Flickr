//
//  ViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 18.08.2021.
//

import UIKit
import WebKit
import SafariServices

class SignInViewController: UIViewController, WKNavigationDelegate {
    let networkService: NetworkService = .init()
    let webView: WKWebView = .init()
    
    override func loadView() {
        self.view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkService.accountOAuth { res in
            switch res {
            case .success(let url):
                let svc = SFSafariViewController(url: url)
                
                DispatchQueue.main.async {
                    self.present(svc, animated: true, completion: nil)
//                    UIApplication.shared.open(url, options: [:]) { complete in
//                        print(complete)
//                    }
                    //self.webView.load(URLRequest(url: url))
                }
            }
        }

//        guard let urlQuery = webView.url?.query else { return }
//        let parameters = networkService.requestTokenResponseParsing(urlQuery)
//        /*
//         url => flickrsdk://success?oauth_token=XXXX&oauth_verifier=ZZZZ
//         url.query => oauth_token=XXXX&oauth_verifier=ZZZZ
//         url.query?.urlQueryStringParameters => ["oauth_token": "XXXX", "oauth_verifier": "YYYY"]
//         */
//        guard let verifier = parameters["oauth_verifier"] else { return }
//        print(verifier)
        
    }

}

extension SignInViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("CallbackNotification"), object: nil)
    }
    
}
