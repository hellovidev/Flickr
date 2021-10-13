//
//  UploadViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 03.10.2021.
//

import UIKit

protocol ProgressDelegate: AnyObject {
    func onProgressCanceled()
}

class UploadViewController: UIViewController {

    private let uploadView: UploadView = .init()
    
    private weak var delegate: ProgressDelegate?

    init(delegate: ProgressDelegate) {
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
        uploadView.titleProcessLabel.text = "Uploading..."
        uploadView.percentProgressLabel.text = "0%"
        self.delegate = delegate
        view = uploadView
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProgress(_ value: Float) {
        uploadView.percentProgressLabel.text = "\(Int(value * 100))%"
        uploadView.setProgress(value)
        if value == 1.0 {
            delegate?.onProgressCanceled()
            uploadView.setProgress(0)
        }
    }
    
    func present(from viewController: UIViewController) {
        viewController.present(self, animated: true)
    }
    
}

private class UploadView: UIView {
    
    private let progressBar: UIProgressView = .init(progressViewStyle: .default)
    
    private let boundingBoxView: UIView = .init(frame: .zero)
    
    let titleProcessLabel = UILabel(frame: .zero)

    let percentProgressLabel = UILabel(frame: .zero)
    
    init() {
        super.init(frame: .zero)

        boundingBoxView.backgroundColor = UIColor(white: 0.0, alpha: 0.9)
        boundingBoxView.layer.cornerRadius = 12.0

        progressBar.progressTintColor = .systemBlue

        titleProcessLabel.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        titleProcessLabel.textColor = UIColor.white
        titleProcessLabel.textAlignment = .center
        titleProcessLabel.numberOfLines = 0
        
        percentProgressLabel.font = UIFont.italicSystemFont(ofSize: UIFont.labelFontSize)
        percentProgressLabel.textColor = UIColor.white
        percentProgressLabel.textAlignment = .center
        percentProgressLabel.numberOfLines = 0

        addSubview(boundingBoxView)
        addSubview(titleProcessLabel)
        addSubview(percentProgressLabel)
        addSubview(progressBar)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        boundingBoxView.frame.size.width = 256
        boundingBoxView.frame.size.height = 96
        boundingBoxView.frame.origin.x = ceil((bounds.width / 2.0) - (boundingBoxView.frame.width / 2.0))
        boundingBoxView.frame.origin.y = ceil((bounds.height / 2.0) - (boundingBoxView.frame.height / 2.0))

        let percentProgressLabelSize = percentProgressLabel.sizeThatFits(CGSize(width: boundingBoxView.frame.size.width - 10.0 * 2.0, height: CGFloat.greatestFiniteMagnitude))
        percentProgressLabel.frame.size.width = percentProgressLabelSize.width + 20
        percentProgressLabel.frame.size.height = percentProgressLabelSize.height
        percentProgressLabel.frame.origin.x = ceil((bounds.width / 2.0) - (percentProgressLabel.frame.width / 2.0))
        percentProgressLabel.frame.origin.y = ceil((bounds.height / 2.0) - (percentProgressLabel.frame.height / 2.0))
        
        progressBar.frame.origin.x = ceil((bounds.width / 2.0) - (progressBar.frame.width / 2.0))
        progressBar.frame.origin.y = ceil(percentProgressLabel.frame.origin.y + percentProgressLabel.frame.size.height + 6)
        
        let titleProcessLabelSize = titleProcessLabel.sizeThatFits(CGSize(width: boundingBoxView.frame.size.width - 10.0 * 2.0, height: CGFloat.greatestFiniteMagnitude))
        titleProcessLabel.frame.size.width = titleProcessLabelSize.width
        titleProcessLabel.frame.size.height = titleProcessLabelSize.height
        titleProcessLabel.frame.origin.x = ceil((bounds.width / 2.0) - (titleProcessLabel.frame.width / 2.0))
        titleProcessLabel.frame.origin.y = ceil(percentProgressLabel.frame.origin.y - percentProgressLabel.frame.size.height - 4)
    }
    
    func setProgress(_ value: Float) {
        progressBar.setProgress(value, animated: true)
    }
    
}
