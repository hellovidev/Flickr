//
//  WKWebViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 09.09.2021.
//

import UIKit
import WebKit

class WKWebViewController: UIViewController, WKNavigationDelegate {
    
    private var webView: WKWebView!
    private var progressView: UIProgressView!
    
    weak var delegate: WKWebViewDelegate?
    var endpoint: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self

        guard let endpoint = endpoint else {
            delegate?.close()
            return
        }
        
        webView.load(endpoint)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Traking Website Loads
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove Strong Link
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
    
    // MARK: - WKNavigationDelegate

    override func loadView() {
        setupUIView()
        setupWKWebView()
        setupUINavigationBar()
        setupUIProgressView()
    }
    
    private func setupUIView() {
        self.view = UIView(frame: UIScreen.main.bounds)
        self.view.backgroundColor = UIColor.white
    }
    
    private func setupWKWebView() {
        webView = WKWebView(frame: CGRect(x: 0, y: 55, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 55), configuration: WKWebViewConfiguration())
        webView.autoresizingMask = [.flexibleHeight]
        self.view.addSubview(webView)
        webView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 55).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
    }
    
    private func setupUINavigationBar() {
        let navigationWebViewBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        let navigationItem = UINavigationItem()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: #selector(doneAction))
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(reload))
        navigationItem.leftBarButtonItem = doneButton
        navigationItem.rightBarButtonItem = refresh
        navigationWebViewBar.setItems([navigationItem], animated: false)
        self.view.addSubview(navigationWebViewBar)
    }
    
    private func setupUIProgressView() {
        progressView = UIProgressView(progressViewStyle: .default)
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
    func doneAction() {
        delegate?.close()
    }
    
    @objc func reload() {
        progressView.progress = 0
        webView.reload()
    }

    // Tracking Website Load Progress
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
