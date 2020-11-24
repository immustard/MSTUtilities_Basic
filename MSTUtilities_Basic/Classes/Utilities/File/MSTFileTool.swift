//
//  MSTFileTool.swift
//  MSTUtilities_Basic
//
//  Created by Mustard on 2020/11/23.
//

import UIKit

public enum MSTFileCacheType {
    case unknown    // 未知
    case image      // 图片
    case audio      // 音频
    case video      // 视频
    case other      // 其他
    case txt        // 文本
    case head       // 头像
    case log        // 日志
    case html       // 网页
    case document   // 文件
    case pdf        // PDF
}

public class MSTFileTool: NSObject {
    /// 保存文件
    /// - Parameters:
    ///   - data: 文件数据
    ///   - path: 路径
    public class func saveFile(_ data: Data, path: String) -> Bool {
        return NSData(data: data).write(toFile: path, atomically: true)
    }
    
    /// 根据文件类型和ID获取文件名
    /// - Parameters:
    ///   - id: 文件ID
    ///   - type: 文件类型
    /// - Returns: 文件名
    public class func getFileName(byID id: String, type: MSTFileCacheType) -> String {
        switch type {
        case .image:
            return id.appending(".jpg")
        case .audio:
            return id.appending(".mav")
        case .video:
            return id.appending(".mp4")
        case .other:
            return id.appending(".a")
        case .txt:
            return id.appending(".txt")
        case .head:
            return id.appending(".jpg")
        case .log:
            return id.appending(".log")
        case .html:
            return id.appending(".html")
        case .pdf:
            return id.appending(".pdf")
        default:
            return id
        }
    }
    
    /// 获取文件路径
    /// - Parameters:
    ///   - id: 文件id
    ///   - type: 文件类型
    ///   - isZoom: 是否是缩略图
    ///   - hasSuffix: 是否包含后缀名
    /// - Returns: 文件路径
    public class func getFilePath(byID id: String, type: MSTFileCacheType, isZoom: Bool, hasSuffix: Bool) -> String {
        let cachesPath = getFolderPath(type: type, isZoom: isZoom)
        
        var tempType = type
        if type == .video && isZoom {
            tempType = .image
        }
        
        let filePath = NSString(string: cachesPath).appendingPathComponent(getFileName(byID: id, type: hasSuffix ? tempType : .unknown))
        
        return filePath
    }
    
    /// 获取文件夹路径
    /// - Parameters:
    ///   - type: 文件类型
    ///   - isZoom: 是否是缩略图
    ///   - userID: 用户id
    /// - Returns: 文件夹路径
    public class func getFolderPath(type: MSTFileCacheType, isZoom: Bool, userID: String = "0") -> String {
        let tPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        var cachesPath = ""
        
        let uid = kStrIsEmptyWithoutBlank(userID) ? "0" : userID
        
        if isZoom {
            cachesPath = cachesPath.appendingFormat("%@/%@/%@/Zoom", tPath, uid, p_getSubjectFolderName(type))
        } else {
            cachesPath = cachesPath.appendingFormat("%@/%@/%@", tPath, uid, p_getSubjectFolderName(type))
        }
        
        var isDirctory = ObjCBool(true)
        
        if !FileManager.default.fileExists(atPath: cachesPath, isDirectory: &isDirctory) {
            do {
                try FileManager.default.createDirectory(atPath: cachesPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return tPath
            }
        }
        
        return cachesPath
    }
    
    /// 根据路径判断文件是否存在
    /// - Parameter path: 路径
    public class func fileExist(_ path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    /// 根据路径删除文件
    /// - Parameter path: 路径
    public class func deleteFile(_ path: String) -> Bool {
        do {
            try FileManager.default.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }
    
    /// 根据字符串添加类型
    /// - Parameter typeString: 类型字符串
    public class func fileType(_ typeString: String) -> MSTFileCacheType {
        var type = MSTFileCacheType.unknown
        
        if typeString == "html" || typeString == "htm" {
            type = .html
        } else if typeString == "pdf" || typeString == "doc" || typeString == "docx" || typeString == "xls" || typeString == "xlsx" || typeString == "ppt" || typeString == "pptx" {
            type = .document
        } else if typeString == "png" || typeString == "jpg" || typeString == "jpeg" || typeString == "gif" || typeString == "bmp" || typeString == "tiff" || typeString == "svg" || typeString == "webp" {
            type = .image
        } else if typeString == "mp3" || typeString == "amr" || typeString == "wav" || typeString == "acc" || typeString == "wma" || typeString == "ogg" || typeString == "ape" {
            type = .audio
        } else if typeString == "mp4" || typeString == "wav" {
            type = .video
        } else if typeString == "txt" {
            type = .txt
        }
        
        return type
    }
    
    /// 获取 mime 类型
    public class func getMIMEType(_ type: MSTFileCacheType) -> String {
        var mimeType = "text/plain"
        switch type {
        case .image, .head:
            mimeType = "image/jpeg"
        case .audio:
            mimeType = "audio/x-wav"
        case .video:
            mimeType = "video/mp4"
        case .html:
            mimeType = "text/html"
        case .pdf:
            mimeType = "application/pdf"
        default:
            break
        }
        
        return mimeType
    }
    
//    /// 根据文件路径获取文件的大小
//    /// - Parameter path: 文件路径
//    /// - Returns: 文件大小(单位: Byte)
//    public class func getFileSize(_ path: String) -> Int64 {
//        var st = stat
//        lstat(path.cString(using: .utf8), UnsafeMutablePointer<stat>!)
//    }
}

// MARK: - Private Methods
private extension MSTFileTool {
    private class func p_getSubjectFolderName(_ type: MSTFileCacheType) -> String {
        var folderName = ""
        
        switch type {
        case .image:
            folderName = "Image"
        case .audio:
            folderName = "Audio"
        case .video:
            folderName = "Video"
        case .other:
            folderName = "Other"
        case .txt:
            folderName = "Txt"
        case .head:
            folderName = "Head"
        case .log:
            folderName = "Log"
        case .html:
            folderName = "Html"
        case .document:
            folderName = "Document"
        case .pdf:
            folderName = "PDF"
        default:
            break
        }
        
        return folderName
    }
}


