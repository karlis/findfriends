import Foundation
import Combine

// Not focusing on this part as given time limit is thight.

class Socket: NSObject {
  private var inputStream: InputStream
  private var outputStream: OutputStream
  private let maxReadLength = 4096

  let messagePublisher: PassthroughSubject<Message, Never>
  var close: () -> Void

  static func create(
    host: String,
    port: UInt32,
    messagePublisher: PassthroughSubject<Message, Never>
  ) -> Socket? {
    var readStream: Unmanaged<CFReadStream>?
    var writeStream: Unmanaged<CFWriteStream>?

    CFStreamCreatePairWithSocketToHost(
      kCFAllocatorDefault,
      host as CFString,
      port,
      &readStream,
      &writeStream
    )

    guard
      let inputStream = readStream?.takeRetainedValue(),
      let outputStream = writeStream?.takeRetainedValue()
    else { return nil }

    return Socket(
      inputStream: inputStream,
      outputStream: outputStream,
      messagePublisher: messagePublisher,
      close: {
        CFReadStreamClose(inputStream)
        CFWriteStreamClose(outputStream)
      }
    )
  }

  init(
    inputStream: InputStream,
    outputStream: OutputStream,
    messagePublisher: PassthroughSubject<Message, Never>,
    close: @escaping () -> Void
  ) {
    self.inputStream = inputStream
    self.outputStream = outputStream
    self.messagePublisher = messagePublisher
    self.close = close
    super.init()

    self.inputStream.delegate = self

    self.inputStream.schedule(in: .current, forMode: .common)
    self.outputStream.schedule(in: .current, forMode: .common)

    self.inputStream.open()
    self.outputStream.open()
  }

  func auth(email: String) {
    guard let data = "AUTHORIZE \(email)\n".data(using: .utf8) else { return }

    data.withUnsafeBytes {
      guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
        print("Error joining chat")
        return
      }
      outputStream.write(pointer, maxLength: data.count)
    }
  }

  func closeConnection() {
    close()
    messagePublisher.send(completion: .finished)
  }
}

extension Socket: StreamDelegate {
  func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
    switch eventCode {
      case .hasBytesAvailable:
        readAvailableBytes(stream: aStream as! InputStream)
      default:
        break
    }
  }

  private func readAvailableBytes(stream: InputStream) {
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
    while stream.hasBytesAvailable {
      let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
      if numberOfBytesRead < 0, let error = stream.streamError {
        print(error)
        break
      }
      if
        let input = processedMessageString(buffer: buffer, length: numberOfBytesRead),
        let message = Parser.shared.parse(input: input) {

        messagePublisher.send(message)
      }
    }
  }

  private func processedMessageString(
    buffer: UnsafeMutablePointer<UInt8>,
    length: Int
  ) -> String? {
    return String(
      bytesNoCopy: buffer,
      length: length,
      encoding: .utf8,
      freeWhenDone: true
    )
  }
}
