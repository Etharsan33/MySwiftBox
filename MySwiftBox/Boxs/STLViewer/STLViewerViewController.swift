//
//  STLViewerViewController.swift
//  MySwiftBox
//
//  Created by ELANKUMARAN Tharsan on 21/03/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit
import SceneKit
import MySwiftSpeedUpTools

class STLViewerViewController: UIViewController, EmptyViewProtocol {
    
    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var styletLabel: UILabel!
    
    private let scene = SCNScene()
    
    // Another Ex: https://www.ozeki.hu/attachments/116/Menger_sponge_sample.stl
    private let url: String = "https://www.ozeki.hu/attachments/16/Stanford_Bunny_sample.stl"
    var onCommitImage: ((UIImage?) -> ())?
    
    public enum ViewState {
        case loading
        case none
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styletLabel.font = .systemFont(ofSize: 15)
        styletLabel.text = "Stylet".uppercased()
                
        self.downloadSTL()
    }
    
    // MARK: - STL
    func downloadSTL() {
        guard let url = URL(string: self.url),
            let filename = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else { return
        }
        
        self.emptyViewState = .loading
        STLNetworkManager.downloadSTL(url: url, filename: filename) { [weak self] result in
            self?.emptyViewState = .none
            
            switch result {
            case .success(let url):
                self?.displaySTL(localURL: url)
            case .failure(let error):
                self?.showAlert(title: nil, message: error.localizedDescription)
            }
        }
    }
    
    func displaySTL(localURL : URL) {
        
        do {
            let node = try BinarySTLParser.createNodeFromSTL(at: localURL, unit: .meter, correctFor3DPrint: true)
            scene.rootNode.addChildNode(node)
        } catch {
            print(error)
        }
        
        scene.background.contents = UIColor.clear
        scnView.scene = scene
        scnView.backgroundColor = .clear
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = true
    }
    
    // MARK: Actions
    @IBAction func styletAction(_ sender: Any) {
        let visu3DDrawStylerVC = STLViewerStyletViewController.instance
        visu3DDrawStylerVC.image = self.snapshotScnView()
        visu3DDrawStylerVC.onCommitImage = self.onCommitImage
        self.navigationController?.pushViewController(visu3DDrawStylerVC, animated: true)
    }
    
    private func snapshotScnView() -> UIImage {
        return scnView.snapshot()
    }
}

// MARK: - EmptyViewProtocol
extension STLViewerViewController {
    
    var emptyViewContainer: UIView? {
        return self.view
    }
    var emptyViewBackgroundColor: UIColor? {
        return .clear
    }
    var emptyViewText: String? {
        return "No data"
    }
    var emptyViewImage: UIImage? {
        return nil
    }
    var emptyViewTryAgainBackgroundColor: UIColor? {
        return .systemRed
    }
    var emptyViewFont: UIFont? {
        return .systemFont(ofSize: 16)
    }
    var emptyViewTextColor: UIColor? {
        return .black
    }
    var emptyViewLoaderColor: UIColor? {
        return .black
    }
    func emptyViewTryAgainAction() { }
}
