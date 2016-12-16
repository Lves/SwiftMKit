import QuartzCore

public enum ScoutedImageType: String {
  case GIF = "gif"
  case PNG = "png"
  case JPEG = "jpeg"
  case Unsupported = "unsupported"
}

public typealias ScoutCompletionBlock = (NSError?, CGSize, ScoutedImageType) -> ()

let unsupportedFormatErrorMessage = "Unsupported image format. ImageScout only supports PNG, GIF, and JPEG."
let unableToParseErrorMessage = "Scouting operation failed. The remote image is likely malformated or corrupt."
let invalidURIErrorMessage = "Invalid URI parameter."

let errorDomain = "ImageScoutErrorDomain"

open class ImageScout {
  fileprivate var session: URLSession
  fileprivate var sessionDelegate = SessionDelegate()
  fileprivate var queue = OperationQueue()
  fileprivate var operations = [String : ScoutOperation]()
  
  public init() {
    let sessionConfig = URLSessionConfiguration.ephemeral
    session = URLSession(configuration: sessionConfig, delegate: sessionDelegate, delegateQueue: nil)
    sessionDelegate.scout = self
  }

  /// Takes a URL string and a completion block and returns void.
  /// The completion block takes an optional error, a size, and an image type,
  /// and returns void.
  
  open func scoutImageWithURI(_ URI: String, completion: @escaping ScoutCompletionBlock) {
    guard let URL = URL(string: URI) else {
      let URLError = ImageScout.error(invalidURIErrorMessage, code: 100)
      return completion(URLError, CGSize.zero, ScoutedImageType.Unsupported)
    }

    let operation = ScoutOperation(task: session.dataTask(with: URL))
    operation.completionBlock = { [unowned self] in
      completion(operation.error, operation.size, operation.type)
      self.operations[URI] = nil
    }

    addOperation(operation, withURI: URI)
  }

  // MARK: Delegate Methods

  func didReceiveData(_ data: Data, task: URLSessionDataTask) {
    guard let requestURL = task.currentRequest?.url?.absoluteString else { return }
    guard let operation = operations[requestURL] else { return }

    operation.appendData(data)
  }

  func didCompleteWithError(_ error: NSError?, task: URLSessionDataTask) {
    guard let requestURL = task.currentRequest?.url?.absoluteString else { return }
    guard let operation = operations[requestURL] else { return }

    let completionError = error ?? ImageScout.error(unableToParseErrorMessage, code: 101)
    operation.terminateWithError(completionError)
  }

  // MARK: Private Methods

  fileprivate func addOperation(_ operation: ScoutOperation, withURI URI: String) {
    operations[URI] = operation
    queue.addOperation(operation)
  }

  // MARK: Class Methods

  class func error(_ message: String, code: Int) -> NSError {
    return NSError(domain: errorDomain, code:code, userInfo:[NSLocalizedDescriptionKey: message])
  }
}
