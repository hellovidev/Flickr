//
//  ViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 18.08.2021.
//

import UIKit
import SafariServices

// MARK: - UIViewController
class SignInViewController: UIViewController {
    let flickrOAuth: FlickrOAuth = .init()
    var browserViewController: SFSafariViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Subscribe to notification when authorization need website confirmation
        NotificationCenter.default.addObserver(self, selector: #selector(websiteConfirmation(_:)), name: Notification.Name(Constant.NotificationName.websiteСonfirmationRequired.rawValue), object: nil)
        
        // Subscribe to notification when 'Safari' is ready to close
        NotificationCenter.default.addObserver(self, selector: #selector(triggerBrowserTargetComplete(_:)), name: Notification.Name(Constant.NotificationName.triggerBrowserTargetComplete.rawValue), object: nil)
        
        // User athorization request
        flickrOAuth.accountOAuth(presenter: self)
    }
    
    // Show preview web page in 'Safari'
    private func activateBrowserPreview(for url: URL) {
        // Initialization 'Safari' object
        browserViewController = .init(url: url)
        browserViewController?.delegate = self
        
        // Async preview after receiving the link
        DispatchQueue.main.async {
            guard let viewController = self.browserViewController else { return }
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    // Method triggered when 'Flickr' need user website confirmation
    @objc
    private func websiteConfirmation(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(Constant.NotificationName.websiteСonfirmationRequired.rawValue), object: nil)
        
        // Callback data after authorize
        guard let url = notification.object as? URL else { return }
        activateBrowserPreview(for: url)
    }
    
    // Method triggered when authorizatoin complete
    @objc
    private func triggerBrowserTargetComplete(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(Constant.NotificationName.triggerBrowserTargetComplete.rawValue), object: nil)
        
        // Finally dismiss the 'Safari' ViewController
        browserViewController?.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - SFSafariViewControllerDelegate
extension SignInViewController: SFSafariViewControllerDelegate {
    
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        print("Browser 'didLoadSuccessfully': \(didLoadSuccessfully)")
    }
    
}
