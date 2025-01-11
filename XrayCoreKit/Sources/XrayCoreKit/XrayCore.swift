import XrayCore

public class XrayCoreWrapper {
    public static let shared = XrayCoreWrapper()
    
    private init() {}
    
    public func start(documentsPath: String, configPath: String, memoryLimit: Int64) -> String {
        return XrayCoreStart(
            documentsPath,
            configPath,
            memoryLimit
        )
    }
    
    public func stop() {
        XrayCoreStop()
    }
}
