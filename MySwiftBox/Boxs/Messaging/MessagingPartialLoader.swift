import Foundation
import Alamofire

public class  MessagingPartialLoader {
    
    static let dispatchQueueName = "messaging.partialLoader.rodin4DClip"
    static let range : Int = 50
    
    fileprivate(set) public var total : Int = 0
    
    var messagesRequests : [(DataRequest, String)] = []
    
    let itemsCache: NSCache = { () -> NSCache<NSNumber, SoftReference<CommentModel?>> in
        let cache = NSCache<AnyObject, AnyObject>()
        cache.name = "messagingItemsCache"
        cache.countLimit = 1000 // Max 100 items in memory.
//        cache.totalCostLimit = 100*1024*1024 // Max 100MB used.
        return cache as! NSCache<NSNumber, SoftReference<CommentModel?>>
    }()
    
    var requestQueue : DispatchQueue? = DispatchQueue(label: dispatchQueueName, qos: .background)
    
    public var onPartialUpdate : ((_ partial : MessagingPartialModel)->())?
    public var onPartialItemsUpdate : (()->())?
    
    public init(partial : MessagingPartialModel,
                onPartialUpdate : ((_ partial : MessagingPartialModel)->())? = nil,
                onPartialItemsUpdate : (()->())? = nil) {
        self.partial = partial
        self.onPartialUpdate = onPartialUpdate
        self.onPartialItemsUpdate = onPartialItemsUpdate
        
        self.addPartial(partial: partial)
    }
    
    
    //MARK: Public
    func cleanData() {
        itemsCache.removeAllObjects()
    }
    
    func getItemAtIndex(_ index : Int, fetch : Bool = true) -> CommentModel? {
        
        let itemFromCache = self.itemsCache.object(forKey: NSNumber(value: index))
        
        if itemFromCache == nil && !fetch {
            return  nil
        }
        
        if itemFromCache == nil {
            self.loadItemAtIndex(index)
        }
        
        guard let item = itemFromCache?.value else {
            print("Messaging for index \(index) is already loading")
            return nil
        }
        
        return item
    }
    
    //MARK : Private
    var partial : MessagingPartialModel {
        didSet {
            self.addPartial(partial: partial)
        }
    }
    
    func addPartial(partial : MessagingPartialModel) {
        
        /*guard*/ let partialTotal = partial.count// else {
        //            self.addNewsRequest(startIndex: nil, stopIndex: nil)
        //            return
        //        }
        
        guard let messages = partial.comments, let startIndex = partial.offset else {//, let _ = partial.endIndex else {
            return
        }
        
        onPartialUpdate?(partial)
        
        let total = max(0, partialTotal)
        //        let count = items.count
        
        if self.total != total {
            self.total = total
            self.itemsCache.removeAllObjects()
        }
        
        var index = startIndex
        for (_, partialItem) in messages.enumerated() {
            //            XCGLogger.debug("Caching item at index \(index) : \(String(describing: partialItem.type))")
            self.itemsCache.setObject(SoftReference(value: partialItem), forKey: NSNumber(value: index))
            index = index + 1
        }
        
        if self.total != total {
            onPartialItemsUpdate?()
        }
        
    }
    
    func loadItemAtIndex(_ index : Int) {
        
        let modulo = index % MessagingPartialLoader.range
        let startAfter = max(0, index - modulo) - 1
        let endBefore = min(self.total, startAfter + MessagingPartialLoader.range) + 1
        
        for i in (startAfter + 1) ..< endBefore {
            
            let itemFromCache = self.itemsCache.object(forKey: NSNumber(value: i))
            
            if itemFromCache == nil {
                print("Caching loading item at index \(i)")
                self.itemsCache.setObject(SoftReference(value: nil), forKey: NSNumber(value: i))
            }
        }
        
        print("[messages for index \(index) : startAfter (\(startAfter)) , endBefore (\(endBefore))]")
        
        if startAfter == -1 {
            self.addMessagessRequest(startIndex: nil, stopIndex: MessagingPartialLoader.range)
        }
        
        self.addMessagessRequest(startIndex: max(0,startAfter), stopIndex: endBefore)
    }
    
    func addMessagessRequest(startIndex: Int?, stopIndex: Int?) {
        
        if !self.messagesRequests.isEmpty {
            if self.messagesRequests.count > 2 {
                self.messagesRequests.removeLast()
            }
        }

        requestQueue = DispatchQueue(label: MessagingPartialLoader.dispatchQueueName, qos: .background)
        
        self.requestQueue?.async { [unowned self] in

            MessagingManager.shared.executeMessagingPartialRequest(share: partial.id, limit: MessagingPartialLoader.range, startAfter: startIndex, endBefore: startIndex == nil ? stopIndex : nil) { [weak self] result in
                
                switch result {
                case .success(let partial):
                    self?.addPartial(partial: partial)
                case .failure(let error):
                    print(error)
                }
            }

        }
        
    }
}

