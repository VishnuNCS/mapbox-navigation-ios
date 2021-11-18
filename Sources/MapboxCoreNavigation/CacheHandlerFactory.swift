import MapboxDirections
import MapboxNavigationNative

protocol CacheHandlerData {
    var tileStorePath: String { get }
    var credentials: Credentials { get }
    var tilesVersion: String { get }
    var historyDirectoryURL: URL? { get }
    var targetVersion: String? { get }
    var configFactoryType: ConfigFactory.Type { get }
}

extension NativeHandlersFactory: CacheHandlerData { }

/**
 :nodoc:
 Creates new or returns existing `CacheHandle`.
 
 This factory is required since `CacheHandle` is used by multiple unrelated entities and is quite expensive to allocate. Since bindgen-generated `MBNNCacheFactory` is not an actual factory but just a wrapper around general init, `CacheHandlerFactory` introduces basic caching of the latest allocated entity. In most of the cases there should never be multiple cache handlers with different attributes, so such solution is adequate at the moment.
 */
enum CacheHandlerFactory {
    
    private struct CacheKey: CacheHandlerData {
        let tileStorePath: String
        let credentials: Credentials
        let tilesVersion: String
        let historyDirectoryURL: URL?
        let targetVersion: String?
        let configFactoryType: ConfigFactory.Type
        
        init(data: CacheHandlerData) {
            self.tileStorePath = data.tileStorePath
            self.credentials = data.credentials
            self.tilesVersion = data.tilesVersion
            self.historyDirectoryURL = data.historyDirectoryURL
            self.targetVersion = data.targetVersion
            self.configFactoryType = data.configFactoryType
        }
        
        private static func optionalsAreNotEqual<T: Comparable>(_ lhs: T?, _ rhs: T?) -> Bool{
            if let firstVal = lhs, let secondVal = rhs {
                return firstVal != secondVal
            }
            else {
                return lhs != nil || rhs != nil
           }
        }
        
        static func != (lhs: CacheKey, rhs: CacheHandlerData) -> Bool {
            return lhs.tileStorePath != rhs.tileStorePath ||
                lhs.credentials != rhs.credentials ||
                optionalsAreNotEqual(lhs.tilesVersion, rhs.tilesVersion) ||
                optionalsAreNotEqual(lhs.historyDirectoryURL?.absoluteString, rhs.historyDirectoryURL?.absoluteString) ||
                optionalsAreNotEqual(lhs.targetVersion, rhs.targetVersion) ||
                lhs.configFactoryType != rhs.configFactoryType
        }
    }
    
    private static var key: CacheKey? = nil
    private static var cachedHandle: CacheHandle!
    private static let lock = NSLock()
    
    static func getHandler(for tilesConfig: TilesConfig,
                           config: ConfigHandle,
                           historyRecorder: HistoryRecorderHandle?,
                           cacheData: CacheHandlerData) -> CacheHandle {
        lock.lock(); defer {
            lock.unlock()
        }
        
        if key == nil || key! != cacheData {
            cachedHandle = CacheFactory.build(for: tilesConfig,
                                              config: config,
                                              historyRecorder: historyRecorder)
            key = .init(data: cacheData)
        }
        return cachedHandle
    }
}
