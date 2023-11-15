import WrkstrmLog

extension Log {
  static let foundation: Log = {
    var log = Log(system: "wrkstrm", category: "foundation")
    log.maxFunctionLength = 25
    return log
  }()
}
