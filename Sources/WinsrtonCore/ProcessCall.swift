import Foundation

@discardableResult
func processCall(executableURL: URL, arguments: [String]) async throws -> Bool {
  let process = Foundation.Process()
  process.executableURL = executableURL
  process.arguments = arguments
  process.standardOutput = FileHandle.standardOutput
  process.standardError = FileHandle.standardError
  try process.run()
  await withCheckedContinuation { c in
    process.terminationHandler = { process in
      c.resume()
    }
  }
  return process.terminationStatus == 0
}
