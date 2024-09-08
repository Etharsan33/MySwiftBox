import Foundation
import UIKit

//MARK: - MessagingWidgetNewMessageDividerProtocol
public protocol MessagingWidgetNewMessageDividerProtocol : class {
    
    /// Tell attached cell if "new message" divider should be displayed
    var showNewMessageDivider : Bool {get set}
    /// Number of new messages, used mostly to handle plurals
    var numberOfNewMessages : Int {get set}
}

extension MessagingWidgetNewMessageDividerProtocol where Self: MessagingBaseMessageWidget {
    
}

//MARK: - MessagingWidgetDateProtocol
public protocol MessagingWidgetDateProtocol : class {
    
    /// previous message date (will be defined when full widget list is available)
    var previousMessageDate : Date? {get set}
    /// define if current message is same day as previsous message
    var isSameDayAsPreviousMessage : Bool {get}
    /// previous message formatted date
    var previousMessageDateString : String? {get}
}

extension MessagingWidgetDateProtocol where Self: MessagingBaseMessageWidget {
    
    /// define if current message is same day as previsous message
    public var isSameDayAsPreviousMessage : Bool {
        guard let previousMessageDate = self.previousMessageDate else {return true}
        
        return previousMessageDate.day == date.day &&
            previousMessageDate.month == date.month &&
            previousMessageDate.year == date.year
    }
    
    /// previous message formatted date
    public var previousMessageDateString : String? {
        guard let previousMessageDate = self.previousMessageDate else {return nil}
        return previousMessageDate.isToday ? "TODAY".uppercased() : previousMessageDate.toString(.date(.long)).uppercased()
    }
}

//MARK: - MessagingWidgetIdentifierProtocol
public protocol MessagingWidgetIdentifierProtocol : class {
    
    /// an unique identifier
    var identifier : Int {get set}
}

extension MessagingWidgetIdentifierProtocol where Self: MessagingBaseMessageWidget {
    
}

