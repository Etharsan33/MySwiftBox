import Foundation

final public class SoftReference<T> : NSDiscardableContent
{
    public func beginContentAccess() -> Bool {
        return true
    }
    
    public func endContentAccess() {
        
    }
    
    public func discardContentIfPossible() {
        
    }
    
    public func isContentDiscarded() -> Bool {
        return false
    }
    
    public var value: T?
    
    private let source: DispatchSourceMemoryPressure
    
    public init(value: T)
    {
        self.value = value
        
        source = DispatchSource.makeMemoryPressureSource(eventMask: [.warning, .critical])
        source.setEventHandler
            {
                [weak self] in
                self?.value = nil
        }
        if #available(iOS 10.0, *) {
            source.activate()
        } else {
            // Fallback on earlier versions
            source.resume()
        }
    }
    
    deinit
    {
        source.cancel()
    }
}
