import QuartzCore

class ScoutOperation: Operation {
  var size = CGSize.zero
  var type = ScoutedImageType.Unsupported
  var error: NSError?
  var mutableData = NSMutableData()
  var dataTask: URLSessionDataTask
  
  init(task: URLSessionDataTask) {
    dataTask = task
  }
  
  override func start() {
    if !isCancelled { dataTask.resume() }
  }
  
  func appendData(_ data: Data) {
    if !isCancelled { mutableData.append(data) }
    if (data.count < 2) { return }
    
    if !isCancelled {
      parse()
    }
  }
  
  func terminateWithError(_ completionError: NSError) {
    error = ImageScout.error(invalidURIErrorMessage, code: 100)
    complete()
  }
  
  fileprivate func parse() {
    let dataCopy = mutableData.copy() as! Data
    type = ImageParser.imageTypeFromData(dataCopy)
    
    if (type != .Unsupported) {
      size = ImageParser.imageSizeFromData(dataCopy)
      if (size != CGSize.zero) { complete() }
    } else if dataCopy.count > 2 {
      self.error = ImageScout.error(unsupportedFormatErrorMessage, code: 102)
      complete()
    }
  }
  
  fileprivate func complete() {
    completionBlock!()
    self.cancel()
  }
  
  override func cancel() {
    super.cancel()
    dataTask.cancel()
  }
}
