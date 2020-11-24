//
//  MSTSystemAuthorizationTool.swift
//  GBCommonUtilities
//
//  Created by Mustard on 2020/6/16.
//

import Photos

/// 权限类型
public enum MSTSystemAuthorizationType {
    case photos                 // 相册
    
    case camera                 // 相机
    
    case microphone             // 麦克风
     
    case cameraAndMicrophone    // 相机和麦克风(视频)
     
    case location               // 定位
     
    case notification           // 通知
}

/// 权限状态
public enum MSTSystemAuthorizationStatus {
    case notDetermined  // 未询问
    
    case noPermission   // 无权限
    
    case havePermission // 有权限
}

public class MSTSystemAuthorizationTool: NSObject {

    // MARK: - Properties
    public static let shared: MSTSystemAuthorizationTool = {
        return MSTSystemAuthorizationTool()
    }()
    
    /// 相关视图控制器
    private var _viewController: UIViewController?
    
    private var _closure: ((Bool) -> Void)?
    
    private var _locationManager: CLLocationManager?
    
}

// MARK: - Instance Methods
public extension MSTSystemAuthorizationTool {
    
    /// 通知权限
    /// - Parameter closure: 回调
    func isCanUseNotification(_ closure: @escaping (MSTSystemAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .notDetermined:
                closure(.notDetermined)
            case .denied:
                closure(.noPermission)
            default:
                closure(.havePermission)
            }
        }
    }
    
    /// 检测权限状态
    /// 不包含 notification 及 cameraAndMicrophone
    /// notification 调用 `isCanUseNotification()`
    /// - Parameter authType: 权限类型
    /// - Returns: 当前权限状态
    func status(_ authType: MSTSystemAuthorizationType) -> MSTSystemAuthorizationStatus {
        switch authType {
        case .photos:
            return p_photosAuthorizationStatus()
        case .camera:
            return p_cameraAuthorizationStatus()
        case .microphone:
            return p_microphoneAuthorizationStatus()
        case .location:
            return p_locationAuthorizationStatus()
        default:
            return .notDetermined
        }
    }
    
    func detectionAndGuideToOpen(_ authType: MSTSystemAuthorizationType, viewController: UIViewController, isForced: Bool, closure: ((Bool) -> Void)?) {
        _viewController = viewController
        _closure = closure
        
        switch authType {
        case .photos:
            p_detectPhotosAuthAndGuideToOpen(isForced, closure: closure)
        case .camera:
            p_detectCameraAuthAndGuideToOpen(isForced, closure: closure)
        case .microphone:
            p_detectMicrophoneAuthAndGuideToOpen(isForced, closure: closure)
        case .cameraAndMicrophone:
            p_detectCameraAndMicrophoneAuthAndGuideToOpen(isForced, closure: closure)
        case .location:
            p_detectLocationAuthAndGuideToOpen(isForced, closure: closure)
        case .notification:
            p_detectNotificationAuthAndGuideToOpen(isForced, closure: closure)
        }
    }
    
    func applicationDidEnterBackground() {
        _closure = nil
    }
}

// MARK: - 检测权限
private extension MSTSystemAuthorizationTool {
    func p_photosAuthorizationStatus() -> MSTSystemAuthorizationStatus {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authStatus {
        case .notDetermined:
            return .notDetermined
        case .restricted, .denied:
            return .noPermission
        default:
            return .havePermission
        }
    }
    
    func p_cameraAuthorizationStatus() -> MSTSystemAuthorizationStatus {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch authStatus {
        case .notDetermined:
            return .notDetermined
        case .restricted, .denied:
            return .noPermission
        default:
            return .havePermission
        }
    }
    
    func p_microphoneAuthorizationStatus() -> MSTSystemAuthorizationStatus {
        let authStatus = AVAudioSession.sharedInstance().recordPermission
        
        switch authStatus {
        case .undetermined:
            return .notDetermined
        case .denied:
            return .noPermission
        default:
            return .havePermission
        }
    }
    
    func p_locationAuthorizationStatus() -> MSTSystemAuthorizationStatus {
        let authStatus = CLLocationManager.authorizationStatus()
        
        switch authStatus {
        case .notDetermined:
            return .notDetermined
        case .restricted, .denied:
            return .noPermission
        default:
            return .havePermission
        }
    }
}

// MARK: - 检测权限并引导去开启
private extension MSTSystemAuthorizationTool {
    func p_detectPhotosAuthAndGuideToOpen(_ isForced: Bool, closure: ((Bool) -> Void)?) {
        let authStatus = p_photosAuthorizationStatus()
        
        if authStatus == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (status) in
                MSTTools.doTaskAsynInMain {
                    closure?(status == .authorized)
                }
            }
        } else if authStatus == .noPermission {
            p_handleNoPermission(.photos, isForced: isForced, closure: closure)
        } else {
            MSTTools.doTaskAsynInMain {
                closure?(true)
            }
        }
    }
    
    func p_detectCameraAuthAndGuideToOpen(_ isForced: Bool, closure: ((Bool) -> Void)?) {
        let authStatus = p_cameraAuthorizationStatus()
        
        if authStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if !granted {
                    self.p_handleClickUnallowed(closure)
                }
            }
        } else if authStatus == .noPermission {
            p_handleNoPermission(.camera, isForced: isForced, closure: closure)
        } else {
            MSTTools.doTaskAsynInMain {
                closure?(true)
            }
        }
    }
    
    func p_detectMicrophoneAuthAndGuideToOpen(_ isForced: Bool, closure: ((Bool) -> Void)?) {
        let authStatus = p_microphoneAuthorizationStatus()
        
        if authStatus == .notDetermined {
            AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                if !granted {
                    self.p_handleClickUnallowed(closure)
                }
            }
        } else if authStatus == .noPermission {
            p_handleNoPermission(.microphone, isForced: isForced, closure: closure)
        } else {
            MSTTools.doTaskAsynInMain {
                closure?(true)
            }
        }
    }
    
    func p_detectCameraAndMicrophoneAuthAndGuideToOpen(_ isForced: Bool, closure: ((Bool) -> Void)?) {
        var cameraStatus = p_cameraAuthorizationStatus()
        let microphoneStatus = p_microphoneAuthorizationStatus()
        
        guard cameraStatus != .havePermission || microphoneStatus != .havePermission else {
            MSTTools.doTaskAsynInMain {
                closure?(true)
            }
            return
        }
        
        // 相机和麦克风都不是第一次询问授权
        if (cameraStatus != .notDetermined && microphoneStatus != .notDetermined) {
            if cameraStatus == .noPermission && microphoneStatus == .noPermission {
                // 相机和麦克风都没有权限
                p_handleNoPermission(.cameraAndMicrophone, isForced: isForced, closure: closure)
            } else if cameraStatus == .noPermission {
                // 相机没有权限
                p_handleNoPermission(.camera, isForced: isForced, closure: closure)
            } else if microphoneStatus == .noPermission {
                // 麦克风没有权限
                p_handleNoPermission(.microphone, isForced: isForced, closure: closure)
            }
            return
        }
        
        // 第一次询问用户是否进行授权
        if cameraStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted { // 允许
                    cameraStatus = .havePermission
                    if microphoneStatus == .havePermission {
                        MSTTools.doTaskAsynInMain {
                            closure?(true)
                        }
                    } else if microphoneStatus == .noPermission {
                        self.p_handleNoPermission(.microphone, isForced: isForced, closure: closure)
                    }
                } else { // 不允许
                    if microphoneStatus == .noPermission {
                        self.p_handleClickUnallowed(closure)
                    }
                }
            }
        }
        
        if microphoneStatus == .notDetermined {
            AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                if granted {
                    if cameraStatus == .havePermission {
                        MSTTools.doTaskAsynInMain {
                            closure?(true)
                        }
                    } else if cameraStatus == .noPermission {
                        self.p_handleNoPermission(.camera, isForced: isForced, closure: closure)
                    }
                } else {
                    self.p_handleClickUnallowed(closure)
                }
            }
        }
    }
    
    func p_detectLocationAuthAndGuideToOpen(_ isForced: Bool, closure: ((Bool) -> Void)?) {
        let authStatus = p_locationAuthorizationStatus()
        
        if authStatus == .notDetermined {
            if _locationManager == nil {
                _locationManager = CLLocationManager()
                _locationManager!.delegate = self
            }
            
            _locationManager?.requestWhenInUseAuthorization()
            
        } else if authStatus == .noPermission {
            p_handleNoPermission(.location, isForced: isForced, closure: closure)
        } else {
            MSTTools.doTaskAsynInMain {
                closure?(true)
            }
        }
    }
    
    func p_detectNotificationAuthAndGuideToOpen(_ isForced: Bool, closure: ((Bool) -> Void)?) {
        isCanUseNotification { (status) in
            if status == .notDetermined {
                UNUserNotificationCenter.current().requestAuthorization(options: .alert) { (granted, error) in
                    if granted {
                        MSTTools.doTaskAsynInMain {
                            closure?(true)
                        }
                    } else {
                        self.p_handleClickUnallowed(closure)
                    }
                }
            } else if status == .noPermission {
                self.p_handleNoPermission(.notification, isForced: isForced, closure: closure)
            } else {
                MSTTools.doTaskAsynInMain {
                    closure?(true)
                }
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension MSTSystemAuthorizationTool: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        MSTTools.doTaskAsynInMain {
            self._closure?(status == .authorizedAlways || status == .authorizedWhenInUse)
        }
    }
}

// MARK: - 其他
private extension MSTSystemAuthorizationTool {
    func p_handleNoPermission(_ authType: MSTSystemAuthorizationType, isForced: Bool, closure: ((Bool) -> Void)?) {
        var alertTitle: String = ""
        
        switch authType {
        case .photos:
            alertTitle = "请在iPhone的“设置-隐私-照片”选项中，允许%@访问你的照片。"
        case .camera:
            alertTitle = "请在iPhone的“设置-隐私-相机”选项中，允许%@访问你的相机。"
        case .microphone:
            alertTitle = "请在iPhone的“设置-隐私-麦克风”选项中，允许%@访问你的麦克风。"
        case .cameraAndMicrophone:
            alertTitle = "请在iPhone的“设置-隐私”选项中，允许%@访问你的相机和麦克风。"
        case .location:
            alertTitle = "无法获取你的位置信息。\n请到手机系统的[设置]->[隐私]->[定位服务]中打开定位服务，并允许%@使用定位服务。"
        case .notification:
            alertTitle = "你现在无法收到新消息通知。\n请到系统“设置”-“通知”-“%@”中开启。"
        }
        
        let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
        
        let alert = UIAlertController(title: String(format: alertTitle, appName), message: nil, preferredStyle: .alert)
        
        if !isForced {
            alert.addAction(UIAlertAction(title: "稍后", style: .default, handler: { (action) in
                MSTTools.doTaskAsynInMain {
                    closure?(false)
                }
            }))
        }
        
        alert.addAction(UIAlertAction(title: "跳转", style: .default, handler: { (action) in
            MSTTools.doTaskAsynInMain {
                let url = URL(string: UIApplication.openSettingsURLString)!
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }))
        
        _viewController?.present(alert, animated: true, completion: nil)
    }
    
    func p_handleClickUnallowed(_ closure: ((Bool) -> Void)?) {
        _viewController?.dismiss(animated: true, completion: nil)
        
        closure?(false)
    }
}
