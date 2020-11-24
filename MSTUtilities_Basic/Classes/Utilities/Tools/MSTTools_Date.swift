//
//  MSTTools_Date.swift
//  Reader
//
//  Created by 张宇豪 on 2019/7/1.
//  Copyright © 2019 张宇豪. All rights reserved.
//

import UIKit

public enum MSTFormatTimeType: String {
    // 日期格式
    case yyyy = "yyyy"
    case yyyy_MM = "yyyy-MM"
    case yyyy_MM_dd = "yyyy-MM-dd"
    case MM_dd = "MM-dd"
    case YYYYMMDD = "yyyyMMdd"
    case yyyyNianMMYueddRiHH_mm = "yyyy年MM月dd日 HH:mm"
    case yyyyNianMMYueddRi = "yyyy年MM月dd日"

    // 时间格式
    case HH_mm  = "HH:mm"
    case HH_mm_ss = "HH:mm:ss"
    
    // 综合格式
    case MM_dd_HH_mm = "MM-dd HH:mm"
    case MM_dd_HH_mm_ss = "MM-dd HH:mm:ss"
    case yyyy_MM_dd_HH_mm = "yyyy-MM-dd HH:mm"
    case yyyy_MM_dd_HH_mm_ss = "yyyy-MM-dd HH:mm:ss"
    case yyyy_MM_dd_HH_mm_ss_SSS = "yyyy-MM-dd HH:mm:ss.SSS"
}

let kOneMinute: Double = 60
let kOneHour: Double = 3600
let kOneDay: Double = 86400
let kOneWeek: Double = 604800

public extension MSTTools {
    class func dateFromTimestamp(_ timestamp: String) -> Date {
        let time = (TimeInterval(timestamp) ?? 0) / 1000
        return Date(timeIntervalSince1970: time)
    }
    
    class func dateFromFormatterTime(_ time: String, formatter: String) -> Date {
        let df = DateFormatter()
        df.dateFormat = formatter
        return df.date(from: time) ?? Date(timeIntervalSince1970: 0)
    }
    
    class internal func dateFromFormatterTime(_ time: String, formatterType type: MSTFormatTimeType) -> Date {
        return dateFromFormatterTime(time, formatter: type.rawValue)
    }
    
    class func timestampByDate(_ date: Date) -> String {
        return String(date.timeIntervalSince1970 * 1000)
    }
    
    class func timestampRightNow() -> String {
        return timestampByDate(Date())
    }
    
    class func timestampByFormatTime(_ time: String, format: String) -> String {
        let date = p_dateFormat(format).date(from: time)
        return timestampByDate(date ?? Date(timeIntervalSince1970: 0))
    }
    
    class func timestampByFormatTime(_ time: String, formatterType type: MSTFormatTimeType) -> String {
        return timestampByFormatTime(time, format: type.rawValue)
    }

    class func formatTimeByTimestamp(_ timestamp: String, format: String) -> String {
        return p_dateFormat(format).string(from: dateFromTimestamp(timestamp))
    }
    
    class func formatTimeRightNow(format: String) -> String {
        return formatTimeByTimestamp(timestampRightNow(), format: format)
    }
    
    class func formatTimeRightNow(formatterType type: MSTFormatTimeType) -> String {
        return formatTimeRightNow(format: type.rawValue)
    }
    
    class func formatTimeForContent(timestamp: String) -> String {
        let publishTime = Double(timestamp)!/1000.0
        let nowTime = Double(timestampRightNow())!/1000.0
        let intervalTime = nowTime - publishTime
        
        var resultTime = ""
        
        if intervalTime < 60 {
            resultTime = "刚刚"
        } else if intervalTime < kOneHour {
            resultTime = "\(Int(intervalTime/60))分钟前"
        } else if intervalTime < kOneDay {
            resultTime = "\(Int(intervalTime/kOneHour))小时前"
        } else {
            resultTime = formatTimeByTimestamp(timestamp, format: "yyyy-MM-dd HH:mm")
        }
        
        return resultTime
    }
    
    class func systemUptime() -> Int {
        var boottime = timeval()
        var size = MemoryLayout<timeval>.stride
        sysctlbyname("kern.boottime", &boottime, &size, nil, 0)

        var now = time_t()
        time(&now)

        var uptime: time_t = -1
        uptime = now - boottime.tv_sec

        return uptime
    }
    
    private class func p_dateFormat(_ format: String) -> DateFormatter {
        let df = DateFormatter()
        df.dateFormat = format
        
        return df
    }
}
