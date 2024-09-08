//
//  STLViewerStyletViewController.swift
//  MySwiftBox
//
//  Created by ELANKUMARAN Tharsan on 21/03/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

class STLViewerStyletViewController: UIViewController {
    
    @IBOutlet weak var zoomingView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var allViewInScrollView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var touchDrawView: TouchDrawView!
    @IBOutlet weak var changeModeButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    
    var image: UIImage? {
        didSet {
            self.imageView?.image = image
        }
    }
    var newImage : UIImage?
    @IBOutlet weak var newImageView: UIImageView!
    
    var onCommitImage: ((UIImage?) -> ())?
    
    @IBAction func containerButton(_ sender: Any) {
        self.view.endEditing(true)
        showPreview(show: false)
    }
    
    func showPreview(show : Bool) {
        self.containerView.isUserInteractionEnabled = !show
        self.newImageView.isHidden = !show
        self.newImageView.image = show ? allViewInScrollView.asImage() : nil
        self.scrollView.zoomScale = 0.0
    }

    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.delegate = self
        
        touchDrawView.delegate = self
        touchDrawView.setColor(.black)
        touchDrawView.setWidth(3)
        
        self.imageView.image = self.image
        self.imageView.contentMode = .scaleAspectFit
        
        self.undoButton.isEnabled = false
        self.touchDrawView.setColor(UIColor.red)
        
        //Init Mode Drawing
        touchDrawView.isDrawing = true
        scrollView.isScrollEnabled = !touchDrawView.isDrawing
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.showPreview(show: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.pinchGestureRecognizer?.isEnabled = !touchDrawView.isDrawing
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.newImageView.backgroundColor = .white
        self.allViewInScrollView.backgroundColor = .white
    }
    
    //MARK: - Actions
    @IBAction func drawAction(_ sender: UIButton) {
        touchDrawView.isDrawing = !touchDrawView.isDrawing
        scrollView.isScrollEnabled = !touchDrawView.isDrawing
        scrollView.pinchGestureRecognizer?.isEnabled = !touchDrawView.isDrawing
    }
    
    @IBAction func undoAction(_ sender: UIButton) {
        touchDrawView.undo()
    }
}

extension STLViewerStyletViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.zoomingView
    }
}

extension STLViewerStyletViewController: TouchDrawViewDelegate {
    
    func undoEnabled() {
        self.undoButton.isEnabled = true
    }
    
    func undoDisabled() {
        self.undoButton.isEnabled = false
    }
}
