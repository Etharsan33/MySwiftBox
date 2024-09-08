import Foundation
import UIKit

/// Protocol presenting basic tools to handle messaging io in a Thread
public protocol MessagingThreadProtocol : class {
    
    /// model describing the thread
    var messagingThread: MessagingPartialModel? {get}
    /// id of the thread to handle
    var thread : Int {get set}
    /// a messaging data handler
    var messagingDataHandler : MessagingDataHandler? {get set}
    /// callback describing the loading state of the messaging partial
    var onMessagingPartialLoading : ((_ : Bool)->())? {get}
    /// delegate for messaging the dataHandler
    var messagingDataHandlerDelegate : MessagingDataHandlerDelegate? {get}
    /// callback on partial loading error
    var onMessagingPartialLoadingError : ((_ : CustomError?)->())? {get}
    /// last read message index from the server.
    var lastReadIndex : Int? {get}
    /// last read message index by the user
    var lastCurrentReadMessageIdentifier : Int? {get}
    
    //MARK: - Partial
    func loadPartial(silently : Bool)
    
    //MARK: - Messages
    /// update the server with the last message read for the thread
    /// The last message read index is retrieved with 'lastReadIndex'.
    /// If 'lastReadIndex' is nil, the default implementation of this method will provide a value
    func updateLastMessageRead()
    
    /// Send a message
    ///
    /// - Parameter message
    func sendMessage(_ message : CommentToSendModel)
    /// callback describing the loading state when sending a message
    var onMessageSending : ((_ : Bool)->())? {get}
    /// callback on sending message error
    var onMessageSendingError : ((_ : CustomError?)->())? {get}
    /// callback on message sent
    var onMessageSent : ((_ message : CommentToSendModel)->())? {get}
}

extension MessagingThreadProtocol where Self: UIViewController {
    
    public var lastReadIndex : Int? {
        return messagingThread?.lastReadIndex
    }
    
    //MARK: - Partial
    public func loadPartial(silently : Bool = false) {
        
        let limit = MessagingPartialLoader.range
        
        if !silently {
            self.onMessagingPartialLoading?(true)
        }
        
        MessagingManager.shared.executeMessagingPartialRequest(share: thread, limit: limit, startAfter: nil, endBefore: nil) { [weak self] result in
            
            if !silently {
                self?.onMessagingPartialLoading?(false)
            }
            
            switch result {
            case.success(let partial):
                self?.messagingDataHandler = MessagingDataHandler(partial: partial, delegate: self?.messagingDataHandlerDelegate)
            case .failure(let error):
                if !silently {
                    self?.onMessagingPartialLoadingError?(error)
                }
                break
            }
        }
        
    }
    
    //MARK: - Messages
    public func updateLastMessageRead() {
        
        MessagingManager.shared.setMessageRead(share: thread, upToMessageId: lastCurrentReadMessageIdentifier) { (messagingThreadStatus, error) in
            print(error as Any)
        }
    }
    
    public func sendMessage(_ message : CommentToSendModel) {
        
        //        self.onMessageSending?(true)
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        //            self.onMessageSent?(message)
        ////            self.onMessageSendingError?(nil)
        //        }
        //        return
                
        self.onMessageSending?(true)
        MessagingManager.shared.postMessage(message: message, share: thread) { [weak self] (success, error) in
            
            if !success {
                self?.onMessageSendingError?(error)
                return
            }
            
            self?.onMessageSent?(message)
        }
    }
}
