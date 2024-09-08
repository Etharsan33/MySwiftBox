import Foundation
import Alamofire

public class MessagingManager {
    
    public static let shared = MessagingManager()
    
    private init() {
        
    }
        
    //MARK: - Messages
    
    /// Get messaging partial for an already forged messaging partial request
    /// This method update the threadStatus
    ///
    /// - Parameters:
    ///   - request: forged messaging partial request
    ///   - completion
    public func executeMessagingPartialRequest(share: Int,
                                               limit: Int ,
                                               startAfter: Int? = nil,
                                               endBefore: Int? = nil,
                                               _ completion: @escaping (Result<MessagingPartialModel, CustomError>) -> Void) {
        let json: [String:Any] = [
            "id": 102,
            "offset": 0,
            "count": 3,
            "user": [
                "id": UserManager.shared.id,
                "name": "Tharsan"
            ],
            "user_share": [
                "id": 1088,
                "name": "Tim"
            ],
            "name": "Conversation test",
            "comments": [
                [
                    "id": 092,
                    "data": [
                        "content": "Il y a quelqu'un ?"
                    ],
                    "created_at": "2020-10-14T22:39:32+0000",
                    "user": [
                        "id": 1088,
                        "name": "Tim"
                    ],
                    "thread": 3920
                ],
                [
                    "id": 091,
                    "data": [
                        "content": "Hello"
                    ],
                    "created_at": "2020-10-13T16:42:32+0000",
                    "user": [
                        "id": 1088,
                        "name": "Tim"
                    ],
                    "thread": 3920
                ],
                [
                    "id": 090,
                    "data": [
                        "content": "Bonjour"
                    ],
                    "created_at": "2020-10-13T16:39:32+0000",
                    "user": [
                        "id": UserManager.shared.id,
                        "name": "Tharsan"
                    ],
                    "thread": 3920
                ]
            ]
        ]
        
        do {
            let partial = try MessagingPartialModel(JSON: json)
            completion(.success(partial))
        } catch {
            completion(.failure(.unknown(nil, error.localizedDescription, nil)))
        }
    }
    
    
    /// Send last message index read to server
    ///
    /// - Parameters:
    ///   - share
    ///   - upToIndex: the last read index
    ///   - completion
    public func setMessageRead(share: Int, upToMessageId: Int?, completion: @escaping (/*_ status : MessagingThreadStatusModel?*/_ success : Bool, _ error : CustomError?)->()) {
        
        let lastMessageIdRead = upToMessageId ?? -1// ?? self.lastKnownIndexForThread(thread)
        
        completion(true, nil)
    }
    
    /// Post a message
    ///
    /// - Parameters:
    ///   - thread
    ///   - lastKnownIndex: index of the last known message
    ///   - completion
    public func postMessage(message : CommentToSendModel, share: Int, _ completion: @escaping (_ success: Bool, _ error : CustomError?)->()) {
        
        guard let uuid = message.attachment, let path = message.path else {
            self.postMessageWithoutAttachment(message: message, share: share, completion)
            return
        }
        
        completion(true, nil)
        
    }
    
    fileprivate func postMessageWithoutAttachment(message : CommentToSendModel, share: Int, _ completion: @escaping (_ success: Bool, _ error : CustomError?)->()) {
        
        completion(true, nil)
        
    }
}
