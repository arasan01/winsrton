import Foundation

public enum UnsupportedError: LocalizedError {
  case ComingSoom
  case Unsupported

  public var errorDescription: String? {
    switch self {
    case .ComingSoom:
      return "This operation is coming soon"
    case .Unsupported:
      return "This operation is not supported on this platform"
    }
  }
}

public func isSupportedOperatingSystem() throws {
  #if os(Windows) && arch(x86_64)
    return
  #elseif os(Windows) && arch(arm64)
    throw UnsupportedError.ComingSoom
  #else
    throw UnsupportedError.Unsupported
  #endif
}
