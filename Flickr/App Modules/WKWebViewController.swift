//
//  WKWebViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 09.09.2021.
//

import UIKit
import WebKit

class WKWebViewController: UIViewController, WKNavigationDelegate {
    
    private let webView = WKWebView(frame: CGRect(x: 0, y: 55, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 55), configuration: WKWebViewConfiguration())
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let navigationWebViewBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
    
    weak var delegate: WKWebViewDelegate?
    var endpoint: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self
        
        // Monitoring page loads
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)

        guard let endpoint = endpoint else {
            delegate?.close()
            return
        }
        
        webView.load(endpoint)
    }
    
    // MARK: - WKNavigationDelegate

    override func loadView() {
        self.view = UIView(frame: UIScreen.main.bounds)
        self.view.backgroundColor = UIColor.white
        
        webView.autoresizingMask = [.flexibleHeight]
        self.view.addSubview(webView)
        webView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 55).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        
        let navigationItem = UINavigationItem(title: "flikr.com")
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: #selector(doneAction))
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(reload))
        navigationItem.leftBarButtonItem = doneButton
        navigationItem.rightBarButtonItem = refresh
        self.navigationWebViewBar.setItems([navigationItem], animated: false)
        self.view.addSubview(navigationWebViewBar)
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.center = view.center
        progressView.trackTintColor = UIColor.systemGray5
        progressView.tintColor = UIColor.link
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 0.75)

        self.view.addSubview(progressView)
  
        progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progressView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 55).isActive = true
        progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
    }

    @objc
    func doneAction() { // remove @objc for Swift 3
        delegate?.close()
    }

    /// Implement the decidePolicyFor method. This is the only part that takes any work: you need to pull out the host of the URL that was requested, run any checks you want to make sure it’s OK, then call the decisionHandler() closure with either .allow to allow the URL or .cancel to deny access.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let host = navigationAction.request.url?.host {
            //print(#function, host)
            if host.contains("flickr.com") {
                decisionHandler(.allow)
                return
            }
        }

        decisionHandler(.cancel)
    }
    
    @objc func reload() {
        progressView.progress = 0
        webView.reload()
    }

    // Monitoring page load progress
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            //print(Float(webView.estimatedProgress))
            progressView.setProgress(Float(webView.estimatedProgress), animated: false)
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        progressView.isHidden = false
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.isHidden = true
    }

    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}

// MARK: - WKWebView

extension WKWebView {

    func load(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            load(request)
        }
    }
    
}
