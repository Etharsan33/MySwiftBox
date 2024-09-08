import Foundation
import UIKit
import SwiftDate
import Photos
import MobileCoreServices
import MySwiftSpeedUpTools

public class MessagingThreadViewController : UIViewController, MessagingThreadProtocol, EmptyViewProtocol {
    
    var didChoseBusy = false
    
    var _lastMessageIdentifier : Int = -1
    public var lastCurrentReadMessageIdentifier: Int? {
        return _lastMessageIdentifier
    }
    
    public var onCommitMsgSended: ((Int) ->())?
    
    
    static let sendBoxTextKey = "sendBoxTextKey"
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            UIView.performWithoutAnimation {
                self.collectionView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi))
            }
            collectionView.addObserver(self, forKeyPath: "contentSize", options: [.new], context: nil)
        }
    }
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    
    open var leftCollectionViewPadding: CGFloat {
        return 20.0
    }
    
    open var rightCollectionViewPadding: CGFloat {
        return 20.0
    }
    
    var documentsController : UIDocumentInteractionController?
    
    //MARK: - Instance
    /// Used to get instance of ViewController from Storyboard
    ///
    /// - returns: instance of BaseViewController
    public class func instanceWithThreadId(_ thread : Int) -> MessagingThreadViewController {
        let vc = self.instance
        vc.thread = thread
        return vc
    }
    
    // MARK: - Life Cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Messaging"
        orientation = UIDevice.current.orientation
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)

        ModelToWidgetMapping.shared.register(modelType: CommentModel.self, widgetType: MessagingSimpleMessageWidget.self)
        
        WidgetToViewerMapping.shared.register(widgetType: MessagingSimpleMessageWidget.self, viewerType: MessagingSimpleMessageCell.self)
        WidgetToViewerMapping.shared.register(widgetType: MessagingLoadingMessageWidget.self, viewerType: MessagingLoadingMessageCell.self)
        
        #if DEBUG
        if thread == 0 {
            assertionFailure("NEED THREAD ID !")
        }
        #endif
        
        self.configureInputBar()

        collectionView.keyboardDismissMode = .interactive
        collectionView.isPrefetchingEnabled = true
        collectionView.prefetchDataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom:  10, right: 0)
        
        for (_, cellType) in WidgetToViewerMapping.shared.registeredWidgetViewers.enumerated() {
            cellType.registerNibFor(collectionView: self.collectionView)
        }
                
        self.collectionView.reloadData()
        if Helpers.osVersionIs(maj: 10) {
            collectionView.collectionViewLayout.invalidateLayout()
        }
        
        self.loadPartial()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UIDevice.current.orientation != orientation {
            changeOrientation(0.4)
        }
        
        // Text input bar notification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(notification:)), name: NSNotification.Name(rawValue: ALKeyboardFrameDidChangeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        self.view.backgroundColor = UIColor.lightGray
    
    }
    
    var setSaveText = true
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        textInputBar.frame.size.width = view.bounds.size.width
        
        if setSaveText {
            self.textInputBar.text = UserDefaults.standard.string(forKey: MessagingThreadViewController.sendBoxTextKey + String(thread))
            setSaveText = false
        }
    }
    
//    var didAppear = false
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updateScrollIndicator()
        self.collectionView.reloadData()
        if Helpers.osVersionIs(maj: 10) {
            collectionView.collectionViewLayout.invalidateLayout()
        }
        
     

    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Text input bar notification
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ALKeyboardFrameDidChangeNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UserDefaults.standard.set(textInputBar.text, forKey: MessagingThreadViewController.sendBoxTextKey + String(thread))
        setSaveText = true
        self.updateLastMessageRead()
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let size = change?[NSKeyValueChangeKey.newKey] as? CGSize, let collectionView = self.collectionView {
            var top : CGFloat = 10
            if size.height < collectionView.frame.size.height {
                top = (collectionView.frame.size.height - size.height) - top
            }
            
            collectionView.contentInset = UIEdgeInsets(top: top, left: collectionView.contentInset.left, bottom: collectionView.contentInset.bottom, right: collectionView.contentInset.right)
        }
        
    }
    
    var orientation : UIDeviceOrientation?
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        if UIApplication.topViewController() != self {
            return
        }
        
        orientation = UIDevice.current.orientation
        let duration = coordinator.transitionDuration
        self.changeOrientation(duration)
        
        
    }

    private func updateScrollIndicator() {
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top:0.0, left:0.0, bottom:0.0, right: collectionView.bounds.size.width - 8.0)
    }
    
    private func changeOrientation(_ duration : TimeInterval) {
        
        self.emptyViewState = .loading
        UIView.animate(withDuration: duration/4, animations: {
            self.textInputBar.alpha = 0
            self.collectionView.alpha = 0
            
        }) { (finished) in
            
            self.collectionView?.reloadData()
            if Helpers.osVersionIs(maj: 10) {
                self.collectionView.collectionViewLayout.invalidateLayout()
            }
            self.updateScrollIndicator()
            
            UIView.animate(withDuration: duration/4, delay: duration/2, options: .curveLinear, animations: {
                self.textInputBar.alpha = 1
                self.collectionView.alpha = 1
            }, completion: { (finished) in
                self.emptyViewState = .none
                
            })
            
        }

    }
    
    //MARK: - MessagingThreadProtocol
    public var thread: Int = 0
    
    public var messagingThread: MessagingPartialModel? {
        return messagingDataHandler?.partial
    }
    
    public var messagingDataHandlerDelegate: MessagingDataHandlerDelegate? {
        return self
    }
    
    public var messagingDataHandler: MessagingDataHandler? {
        didSet {
            messagingDataHandler?.delegate = self
        }
    }
    
    public var onMessagingPartialLoading: ((Bool) -> ())? {
        return { [weak self] (loading) in
            
            guard let strongSelf = self else {return}
            
            strongSelf.emptyViewState = .none
            
            if strongSelf.messagingThread == nil {
                if loading {
                    strongSelf.emptyViewState = .loading
                }
            }
        }
    }
    
    public var onMessagingPartialLoadingError: ((CustomError?) -> ())? {
        return { [weak self] error in
            
            guard let strongSelf = self else {return}

            print(error as Any)
            
            if strongSelf.messagingThread == nil {

                let title = error?.alertTitle ?? "ERROR_DEFAULT_ALERT_TITLE"
                let message = error?.alertMessage ?? "ERROR_DEFAULT_ALERT_MESSAGE"

                strongSelf.showAlert(title: title, message: message, buttons: [
                    .title("Retry") {
                        strongSelf.loadPartial()
                    },
                    .titleWithStyle("Cancel", .cancel) {
                        strongSelf.navigationController?.popViewController(animated: true)
                    }
                ])
            }
            else if let error = error, error == CustomError.network(nil, nil, nil) {
                self?.showAlert(title: nil, message: "ERROR_NETWORK_ALERT_MESSAGE")
            }
        }
    }
    
    enum InputViewState {
        case loading
        case none
    }

    var inputViewState : InputViewState = .none {
        didSet {
            switch inputViewState {
            case .loading:
                self.textInputBar.textViewBackgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
                self.inputBarLeftEmbedView.showModelButton.isEnabled = false
                self.inputBarRightEmbedView.loading = true
            case .none:
                self.textInputBar.textViewBackgroundColor = UIColor.white
                self.inputBarLeftEmbedView.showModelButton.isEnabled = true
                self.inputBarRightEmbedView.loading = false
            }
        }
    }
    
    public var onMessageSending: ((Bool) -> ())? {
        
        return { [weak self] loading in
            
            guard let strongSelf = self else {return}

            strongSelf.inputViewState = loading ? .loading : .none
            
        }
        
    }
    
    public var onMessageSendingError: ((CustomError?) -> ())? {
        return { [weak self] error in
            
            guard let strongSelf = self else {return}
            
            print(error as Any)
            
            strongSelf.inputViewState = .none
            
            let errorMessage = error?.alertMessage ?? "ERROR_DEFAULT_ALERT_MESSAGE"
            self?.showAlert(title: nil, message: errorMessage)
        }
    }

    public var onMessageSent: ((CommentToSendModel) -> ())? {
        
        return { [weak self] message in
            
            guard let strongSelf = self else {return}
            
            print("Message sent")
            
            strongSelf.collectionView.scrollToBottom(animated: true)
            strongSelf.loadPartial()
            strongSelf.inputViewState = .none
            strongSelf.textInputBar.text = ""
            
            strongSelf.onCommitMsgSended?(strongSelf.thread)
        }
        
    }
    
    //MARK: - CollectionView Helper
    private func cellAtIndexPath(_ indexPath : IndexPath, fetch : Bool = true) -> UICollectionViewCell? {
        
        guard let messagingDataHandler = self.messagingDataHandler, let widget = messagingDataHandler.itemAtIndex(index: indexPath.row, fetch: fetch) else {
            return nil
        }
        
        let viewer = MessagingDataHandler.viewerTypeForWidget(widget)
        
        /// if cell should be fetch, i.e fetching from the server the widget attached to the cell, we return a cell from dequeu. Otherwise we just instanciate a new cell
//        let cell : MessagingBaseMessageCell = fetch ? (viewer.cellForCollection(collectionView: collectionView, indexPath: indexPath) as! MessagingBaseMessageCell) : (viewer.instance as! MessagingBaseMessageCell)
        
        let cell : MessagingBaseMessageCell = viewer.cellForCollection(collectionView: collectionView, indexPath: indexPath) as! MessagingBaseMessageCell
        
        let width = collectionView.bounds.width - leftCollectionViewPadding - rightCollectionViewPadding
        widget.attachedCellMaxWidth = width
        
        // MessagingWidgetDateProtocol handling
        if widget is MessagingWidgetDateProtocol {
            let messagingWidgetDateProtocol = widget as! MessagingWidgetDateProtocol
                messagingWidgetDateProtocol.previousMessageDate = nil
        }

        // MessagingWidgetNewMessageDividerProtocol handling
        if widget is MessagingWidgetNewMessageDividerProtocol {
            let messagingWidgetNewMessageDividerProtocol = widget as! MessagingWidgetNewMessageDividerProtocol
                messagingWidgetNewMessageDividerProtocol.showNewMessageDivider = false
        }

        let oldLastMessageIdentifier = _lastMessageIdentifier
        if indexPath.row == 0 && widget.identifier != oldLastMessageIdentifier {
            self._lastMessageIdentifier = widget.identifier
            updateLastMessageRead()
        }
        
        cell.widget = widget
        UIView.performWithoutAnimation {
            cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        }
        
        return cell
        
    }
    
    //MARK: - TextInputBar
    let textInputBar = ALTextInputBar()
    let keyboardObserver = ALKeyboardObservingView()
    /// A cache-misere for X phones safeArea...
    let textInputBarBottomDecorationView = UIView(frame: CGRect.zero)
    /// text imput TextField strarting height
    let textInputHeight : CGFloat = 69.0
    
    /// view containing the left view of the input bar
    lazy var inputBarLeftViewContainer : UIView = {
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: textInputHeight))
        leftView.backgroundColor = UIColor.clear
        let leftEmbedView = self.inputBarLeftEmbedView
        leftEmbedView.frame = leftView.frame
        leftView.addSubview(leftEmbedView)
        return leftView
    }()
    
    /// view embeded in the left view of inputbar, the one that does the jib
    lazy var inputBarLeftEmbedView : MessagingInputLeftView = {
        
        let leftEmbedView = MessagingInputLeftView.instance
        leftEmbedView.onShowModel = { [weak self] in
        }
        return leftEmbedView
    }()
    
    /// view containing the right view of the input bar
    lazy var inputBarRightViewContainer : UIView = {
        
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 58, height: textInputHeight))
        rightView.backgroundColor = UIColor.clear
        let rightEmbedView = self.inputBarRightEmbedView
        rightEmbedView.frame = rightView.frame
        rightView.addSubview(rightEmbedView)
        return rightView
    }()
    
    /// view embeded in the right view of inputbar, the one that does the jib
    lazy var inputBarRightEmbedView : MessagingInputRightView = {
        let rightEmbedView = MessagingInputRightView.instance
        rightEmbedView.onSend = { [weak self] in
            self?.sendMessage()
        }
        rightEmbedView.loading = false
        return rightEmbedView
    }()
    
    // This is how we observe the keyboard position
    override public var inputAccessoryView: UIView? {
        get {
            return keyboardObserver
        }
    }
    
    // This is also required
    override public var canBecomeFirstResponder: Bool {
        return true
    }
    
    var sendMessageBusy = false
    @objc func sendMessage() {
        
        if textInputBar.text.isEmpty {return}
        
        if sendMessageBusy {return}
        sendMessageBusy = true
        
        let content = textInputBar.text.isEmpty ? nil : textInputBar.text
        
        if let message = CommentToSendModel(content: content, attachment: nil, path: nil, size: nil) {
            self.sendMessage(message)
            self.sendMessageBusy = false
        }
    }
    
    /// Configuration of the test input bar
    func configureInputBar() {
    
        keyboardObserver.isUserInteractionEnabled = false
        
        textInputBar.shouldShowRightButton = { [weak self] (text : String) in
            if self == nil {return true}
            return !text.isEmpty
        }
        textInputBar.showTextViewBorder = true
        textInputBar.horizontalPadding = 20.0
        textInputBar.horizontalSpacing = 0.0
        textInputBar.textViewCornerRadius = textInputBar.textView.minimumHeight / 2
        textInputBar.textView.placeholder = "INPUT_PLACEHOLDER"
        textInputBar.leftView = self.inputBarLeftViewContainer
        textInputBar.rightView = self.inputBarRightViewContainer
        textInputBar.defaultHeight = textInputHeight
        textInputBar.delegate = self
        textInputBar.frame = CGRect(x: 0, y: view.frame.size.height - textInputBar.defaultHeight, width: view.frame.size.width, height: textInputBar.defaultHeight)
        textInputBar.backgroundColor = UIColor(white: 0.95, alpha: 1)
        textInputBar.keyboardObserver = keyboardObserver
        textInputBar.setShadowLayer(opacity: 1, offset : CGSize(width: 0, height: 5), radius : 5.0, color : .black)
        textInputBar.clipsToBounds = false
        view.addSubview(textInputBar)
        
        textInputBarBottomDecorationView.frame = CGRect(x: textInputBar.frame.origin.x, y: textInputBar.frame.origin.y + textInputBar.defaultHeight, width: textInputBar.frame.width, height: textInputBar.defaultHeight)
        textInputBarBottomDecorationView.backgroundColor = UIColor.lightGray
        view.addSubview(textInputBarBottomDecorationView)
        
    }
    
    private func textInputBarOriginYWithKeyboardFrame(_ frame : CGRect) -> CGFloat {
        var safeAreaBottomPadding : CGFloat = 0
        if #available(iOS 11.0, *) {
            safeAreaBottomPadding = Helpers.SafeArea.bottom.value
        }

        let y = self.view.frame.height - frame.size.height
        let minY = self.view.frame.height - textInputBar.frame.size.height - safeAreaBottomPadding
        
        return min(y, minY)
    }
    
    fileprivate func getCollectionViewBottomConstraint() -> CGFloat {
        
        var collectionSafeAreaPadding : CGFloat = 0
        if #available(iOS 11.0, *) {
            collectionSafeAreaPadding = Helpers.SafeArea.bottom.value
        }
        
        let constant = self.view.frame.height - textInputBar.frame.origin.y - collectionSafeAreaPadding
        
        return constant
    }
    
    @objc func keyboardFrameChanged(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
            textInputBar.frame.origin.y = self.textInputBarOriginYWithKeyboardFrame(frame)
            textInputBarBottomDecorationView.frame.origin.y = textInputBar.frame.origin.y + textInputBar.frame.height
            collectionViewBottomConstraint.constant = self.getCollectionViewBottomConstraint()
        }
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
            if frame.height != textInputBar.frame.height {
                collectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    
    public struct MessagingSendingAttachement {
        let fileURL : URL?
    }
    
    @objc func applicationDidEnterBackground(notification: NSNotification) {
        UserDefaults.standard.set(textInputBar.text, forKey: MessagingThreadViewController.sendBoxTextKey + String(thread))
        setSaveText = true
    }
}

//MARK: - ALTextInputBarDelegate
extension MessagingThreadViewController : ALTextInputBarDelegate {
    public func textView(textView: ALTextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return self.inputViewState == .none
    }
}

//MARK: - MessagingDataHandlerDelegate
extension MessagingThreadViewController : MessagingDataHandlerDelegate {
    
    public func messagingDataHandlerDidUpdatePartialItems(channelDataHandler: MessagingDataHandler) {
        self.collectionView?.reloadData()
        if Helpers.osVersionIs(maj: 10) {
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    public func messagingDataHandlerDidUpdatePartial(channelDataHandler: MessagingDataHandler, partial: MessagingPartialModel) {
        
        if let userName = partial.userB.getFullname(), let name = partial.name {
            let navTitle = NSMutableAttributedString(string: userName , attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                NSAttributedString.Key.foregroundColor: UIColor.white
                ])
            
            navTitle.append(NSMutableAttributedString(string: " - " + (name ), attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                NSAttributedString.Key.foregroundColor: UIColor.white
                ]))
            
//            self.labelNavigation = navTitle
//            self.addNavigationTitleView(self.labelNavigation)
            
        }

        
        self.collectionView?.reloadData()
        if Helpers.osVersionIs(maj: 10) {
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
}

//MARK: - UICollectionViewDataSoure
extension MessagingThreadViewController: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messagingDataHandler?.count ?? 0//didAppear ? (messagingDataHandler?.count ?? 0) : 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        Logger.debug("RELOAD - cellForItemAt : \(indexPath.row)").console()
        let cell = cellAtIndexPath(indexPath)

        //Specific behaviours
        if cell is MessagingSimpleMessageCell {
            (cell as! MessagingSimpleMessageCell).delegate = self
        }
        
        return cell ?? UICollectionViewCell()
    }
}

//MARK: - UICollectionViewDelegate
extension MessagingThreadViewController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
//        if let lastReadIndex = lastReadIndex, let messagingDataHandler = self.messagingDataHandler, (messagingDataHandler.count - indexPath.row) == lastReadIndex + 1 {
//            updateLastMessageRead()
//        }

    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension MessagingThreadViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cell = cellAtIndexPath(indexPath, fetch: false)
        let width = collectionView.bounds.width - leftCollectionViewPadding - rightCollectionViewPadding
        let size = cell?.contentView.systemLayoutSizeFitting(CGSize(width: width, height: 0), withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow) ?? CGSize(width: width, height: 50)
        return size
//        return CGSize(width: width, height: 120)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
}

extension MessagingThreadViewController : UICollectionViewDataSourcePrefetching {
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach({
            _ = messagingDataHandler?.itemAtIndex(index: $0.row, fetch: true)
        })
        
    }
}

//MARK: - UICollectionView Helpers
fileprivate extension UICollectionView {
    
    func scrollToBottom(animated : Bool) {
        let visibleRect = CGRect(x: self.contentSize.width - 1, y: 0, width: 1, height: 1)
        self.scrollRectToVisible(visibleRect, animated: animated)
    }
    
    func reloadDataWithCompletion(_ completion : (() -> Void)?) {
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.reloadData()
        if Helpers.osVersionIs(maj: 10) {
            self.collectionViewLayout.invalidateLayout()
        }
        CATransaction.commit()
    }
    
    func reloadDataAndScrollToBottom(animated: Bool, _ completion :((Bool)->Void)?) {
        
        self.reloadDataWithCompletion({
            self.scrollToBottom(animated: animated)
        })
    }
}

//MARK: - MessagingSimpleMessageCellDelegate
extension MessagingThreadViewController : MessagingSimpleMessageCellDelegate {
    
    func messagingSimpleMessageCell(_ cell: MessagingSimpleMessageCell, didChose attachmentResource: ResourceModel, from resourcesWithSameCategory: [ResourceModel]) {

        print("tapped")
    }
    
    @objc func dissmissPresenting(sender : Any) {
        self.presentedViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - EmptyViewProtocol
extension MessagingThreadViewController {
    
    public var emptyViewContainer: UIView? {
        return self.collectionView
    }
    
    public var emptyViewImage: UIImage? {
        return nil
    }
    
    public var emptyViewText: String? {
        return "Empty"
    }
    
    public var emptyViewTryAgainBackgroundColor: UIColor? {
        return .systemRed
    }
    
    public var emptyViewFont: UIFont? {
        return .systemFont(ofSize: 14)
    }
    
    public func emptyViewTryAgainAction() { }
    
}

