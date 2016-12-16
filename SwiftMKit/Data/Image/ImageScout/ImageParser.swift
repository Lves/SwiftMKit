import QuartzCore

struct ImageParser {
  fileprivate enum JPEGHeaderSegment {
    case nextSegment, sofSegment, skipSegment, parseSegment, eoiSegment
  }
  
  fileprivate struct PNGSize {
    var width: UInt32 = 0
    var height: UInt32 = 0
  }
  
  fileprivate struct GIFSize {
    var width: UInt16 = 0
    var height: UInt16 = 0
  }
  
  fileprivate struct JPEGSize {
    var height: UInt16 = 0
    var width: UInt16 = 0
  }
  
  /// Takes an NSData instance and returns an image type.
  static func imageTypeFromData(_ data: Data) -> ScoutedImageType {
    let sampleLength = 2
    
    if (data.count < sampleLength) { return .Unsupported }
    
    var length = UInt16(0); (data as NSData).getBytes(&length, range: NSRange(location: 0, length: sampleLength))
    
    switch CFSwapInt16(length) {
    case 0xFFD8:
      return .JPEG
    case 0x8950:
      return .PNG
    case 0x4749:
      return .GIF
    default:
      return .Unsupported
    }
  }
  
  /// Takes an NSData instance and returns an image size (CGSize).
  static func imageSizeFromData(_ data: Data) -> CGSize {
    switch self.imageTypeFromData(data) {
    case .PNG:
      return self.PNGSizeFromData(data)
    case .GIF:
      return self.GIFSizeFromData(data)
    case .JPEG:
      return self.JPEGSizeFromData(data)
    default:
      return CGSize.zero
    }
  }
  
  // MARK: PNG
  
  static func PNGSizeFromData(_ data: Data) -> CGSize {
    if (data.count < 25) { return CGSize.zero }
    
    var size = PNGSize()
    (data as NSData).getBytes(&size, range: NSRange(location: 16, length: 8))
    
    return CGSize(width: Int(CFSwapInt32(size.width)), height: Int(CFSwapInt32(size.height)))
  }
  
  // MARK: GIF
  
  static func GIFSizeFromData(_ data: Data) -> CGSize {
    if (data.count < 11) { return CGSize.zero }
    
    var size = GIFSize(); (data as NSData).getBytes(&size, range: NSRange(location: 6, length: 4))
    
    return CGSize(width: Int(size.width), height: Int(size.height))
  }
  
  // MARK: JPEG
  
  static func JPEGSizeFromData(_ data: Data) -> CGSize {
    let offset = 2
    var size: CGSize?
    
    repeat {
      if (data.count <= offset) { size = CGSize.zero }
      size = self.parseJPEGData(data, offset: offset, segment: .nextSegment)
    } while size == nil
    
    return size!
  }
  fileprivate typealias JPEGParseTuple = (data: Data, offset: Int, segment: JPEGHeaderSegment)

  fileprivate enum JPEGParseResult {
    case size(CGSize)
    case tuple(JPEGParseTuple)
  }

  fileprivate static func parseJPEG(_ tuple: JPEGParseTuple) -> JPEGParseResult {
    let data = tuple.data
    let offset = tuple.offset
    let segment = tuple.segment

    if segment == .eoiSegment
      || (data.count <= offset + 1)
      || (data.count <= offset + 2) && segment == .skipSegment
      || (data.count <= offset + 7) && segment == .parseSegment {
        return .size(CGSize.zero)
    }
    switch segment {
    case .nextSegment:
      let newOffset = offset + 1
      var byte = 0x0; (data as NSData).getBytes(&byte, range: NSRange(location: newOffset, length: 1))

      if byte == 0xFF {
        return .tuple(JPEGParseTuple(data, offset: newOffset, segment: .sofSegment))
      } else {
        return .tuple(JPEGParseTuple(data, offset: newOffset, segment: .nextSegment))
      }
    case .sofSegment:
      let newOffset = offset + 1
      var byte = 0x0; (data as NSData).getBytes(&byte, range: NSRange(location: newOffset, length: 1))

      switch byte {
      case 0xE0...0xEF:
        return .tuple(JPEGParseTuple(data, offset: newOffset, segment: .skipSegment))
      case 0xC0...0xC3, 0xC5...0xC7, 0xC9...0xCB, 0xCD...0xCF:
        return .tuple(JPEGParseTuple(data, offset: newOffset, segment: .parseSegment))
      case 0xFF:
        return .tuple(JPEGParseTuple(data, offset: newOffset, segment: .sofSegment))
      case 0xD9:
        return .tuple(JPEGParseTuple(data, offset: newOffset, segment: .eoiSegment))
      default:
        return .tuple(JPEGParseTuple(data, offset: newOffset, segment: .skipSegment))
      }

    case .skipSegment:
      var length = UInt16(0)
      (data as NSData).getBytes(&length, range: NSRange(location: offset + 1, length: 2))

      let newOffset = offset + Int(CFSwapInt16(length)) - 1
      return .tuple(JPEGParseTuple(data, offset: Int(newOffset), segment: .nextSegment))

    case .parseSegment:
      var size = JPEGSize(); (data as NSData).getBytes(&size, range: NSRange(location: offset + 4, length: 4))
      return .size(CGSize(width: Int(CFSwapInt16(size.width)), height: Int(CFSwapInt16(size.height))))
    default:
      return .size(CGSize.zero)
    }
  }

  fileprivate static func parseJPEGData(_ data: Data, offset: Int, segment: JPEGHeaderSegment) -> CGSize {
    var tuple: JPEGParseResult = .tuple(JPEGParseTuple(data, offset: offset, segment: segment))
    while true {
      switch tuple {
      case .size(let size):
        return size
      case .tuple(let newTuple):
        tuple = parseJPEG(newTuple)
      }
    }
  }
}
