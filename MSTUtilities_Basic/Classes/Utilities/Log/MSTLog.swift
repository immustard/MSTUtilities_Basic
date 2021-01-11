//
//  MSTLog.swift
//  MSTUtilities_Basic
//
//  Created by Mustard on 2020/11/24.
//

import UIKit

public struct MSTLogType: OptionSet {
    public var rawValue: Int
    
    public static let debug        = MSTLogType(rawValue: 1 << 0)
    public static let error        = MSTLogType(rawValue: 1 << 1)
    public static let warning      = MSTLogType(rawValue: 1 << 2)
    public static let action       = MSTLogType(rawValue: 1 << 3)
    public static let success      = MSTLogType(rawValue: 1 << 4)
    public static let cancelled    = MSTLogType(rawValue: 1 << 5)
    public static let other        = MSTLogType(rawValue: 1 << 6)
    public static let network      = MSTLogType(rawValue: 1 << 7)
    public static let socket       = MSTLogType(rawValue: 1 << 8)
    public static let database     = MSTLogType(rawValue: 1 << 9)

    public static let base: MSTLogType = [.error, .warning, .cancelled]
    public static let all: MSTLogType = [.debug, .error, .warning, .action, .success, .cancelled, .other, .network, .socket, .database]
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public class MSTLogUtil {
    public static let shared = MSTLogUtil()
    
    public var logType: MSTLogType = .debug
}

public func mstLog<T>(_ message:T,
                      file:String = #file,
                      funcName:String = #function,
                      lineNum:Int = #line,
                      type:MSTLogType = .debug) {
    
    #if DEBUG
    
    let file = (file as NSString).lastPathComponent;
    
    if type.contains(.debug) && MSTLogUtil.shared.logType.contains(.debug) {
        p_log(tip: "🔵", text: "MSTLog DEBUG: \(file):(\(lineNum))--\(message)")
    }
    if type.contains(.error) && MSTLogUtil.shared.logType.contains(.error) {
        p_log(tip: "🔴", text: "MSTLog ERROR: \(file):(\(lineNum))--\(message)")
    }
    if type.contains(.warning) && MSTLogUtil.shared.logType.contains(.warning) {
        p_log(tip: "🟡", text: "MSTLog WARNING: \(file):(\(lineNum))--\(message)")
    }
    if type.contains(.action) && MSTLogUtil.shared.logType.contains(.action) {
        p_log(tip: "🟣", text: "MSTLog ACTION: \(file):(\(lineNum))--\(message)")
    }
    if type.contains(.success) && MSTLogUtil.shared.logType.contains(.success) {
        p_log(tip: "🟢", text: "MSTLog SUCCESS: \(file):(\(lineNum))--\(message)")
    }
    if type.contains(.cancelled) && MSTLogUtil.shared.logType.contains(.cancelled) {
        p_log(tip: "🟠", text: "MSTLog CANCELLED: \(file):(\(lineNum))--\(message)")
    }
    if type.contains(.other) && MSTLogUtil.shared.logType.contains(.other) {
        p_log(tip: "🟤", text: "MSTLog OTHER: \(file):(\(lineNum))--\(message)")
    }
    if type.contains(.network) && MSTLogUtil.shared.logType.contains(.network) {
        p_log(tip: "⚪️", text: "MSTLog NETWORK: \(file):(\(lineNum))--\(message)")
    }
    if type.contains(.socket) && MSTLogUtil.shared.logType.contains(.socket) {
        p_log(tip: "🟨", text: "MSTLog SOCKET: \(file):(\(lineNum))--\(message)")
    }
    if type.contains(.database) && MSTLogUtil.shared.logType.contains(.database) {
        p_log(tip: "🟦", text: "MSTLog SOCKET: \(file):(\(lineNum))--\(message)")
    }
    
    #endif
}


private func p_log(tip: String, text: String) {
    let tipsArr = Array(repeating: tip, count: 6)
    print(tipsArr.joined(separator: ""))

    let timeStr = MSTTools.formatTimeRightNow(formatterType: .yyyy_MM_dd_HH_mm_ss_SSS)
    print(timeStr)

    print(text)

    print(tipsArr.joined(separator: ""))
}

// MARK: - Log
public func kWriteLog(_ content: String) {
    MSTTools.writeLog(content)
}
