
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking

extension URLSession {
  func data(from url: URL) async throws -> (Data, URLResponse) {
    try await withCheckedThrowingContinuation { continuation in
      let task = dataTask(with: url) { data, response, error in
        if let error = error {
          continuation.resume(throwing: error)
        } else if let data = data, let response = response {
          continuation.resume(returning: (data, response))
        } else {
          fatalError("Either data or response is nil")
        }
      }
      task.resume()
    }
  }
}
#endif
