//
//  UploadProgressViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 03.10.2021.
//

import UIKit

// MARK: - UploadProgressViewController

protocol ProgressDelegate: AnyObject {
    func onProgressCanceled()
}

class UploadProgressViewController: UIViewController {
    
    private let uploadProgressView: UploadProgressView = .init()
    
    private weak var delegate: ProgressDelegate?
    
    init(delegate: ProgressDelegate) {
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
        uploadProgressView.titleProcessLabel.text = "Uploading..."
        uploadProgressView.percentProgressLabel.text = "0%"
        self.delegate = delegate
        view = uploadProgressView
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProgress(_ value: Float) {
        uploadProgressView.percentProgressLabel.text = "\(Int(value * 100))%"
        uploadProgressView.setProgress(value)
        if value == 1.0 {
            delegate?.onProgressCanceled()
            uploadProgressView.setProgress(0)
        }
    }
    
    func present(from viewController: UIViewController) {
        viewController.present(self, animated: true)
    }
    
}
