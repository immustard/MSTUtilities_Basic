//
//  MSTFileBrowserVC.swift
//  GBCommonUtilities
//
//  Created by Mustard on 2020/7/1.
//

import UIKit
import WebKit
import QuickLook

open class MSTFileBrowserVC: UIViewController {

    // MARK: - Properties
    /// 文件路径
    public var filePath = ""
    
    /// 原文件名
    public var originalName = "" {
        didSet {
            self.title = originalName
        }
    }
    
    private var _fileURL: URL?
    
    // MARK: - Life Cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        p_initData()
    }
}

private extension MSTFileBrowserVC {
    func p_initData() {
        let type = NSString(string: filePath).pathExtension
        let fileType = MSTFileTool.fileType(type)
        
        _fileURL = URL(fileURLWithPath: filePath)
        p_initView(type, fileType: fileType)
    }
    
    func p_initView(_ type: String, fileType: MSTFileCacheType) {
        switch fileType {
        case .html:
            let webView = WKWebView(frame: CGRect(x: 0, y: kNavAndStatusHeight, width: self.view.mst_width, height: kScreenHeight - kNavAndStatusHeight))
            view.addSubview(webView)
            webView.navigationDelegate = self

            let url = URL(fileURLWithPath: filePath, isDirectory: false)
            webView.load(URLRequest(url: url))
        case .document, .txt:
            let vc = QLPreviewController()
            vc.view.frame = CGRect(x: 0, y: 0, width: self.view.mst_width, height: kScreenHeight - kNavAndStatusHeight)
            vc.dataSource = self
            vc.delegate = self
            vc.currentPreviewItemIndex = 0
            addChild(vc)
            view.addSubview(vc.view)
            vc.reloadData()
        case .image:
            let imgView = UIImageView(frame: CGRect(x: 100, y: 100, width: 300, height: 300))
            imgView.center = CGPoint(x: view.mst_centerX, y: view.mst_centerY)
            
            view.addSubview(imgView)
            
            let image = UIImage(contentsOfFile: filePath)
            imgView.image = image
        default:
            p_initOtherView()
        }
    }
    
    func p_initOtherView() {
        let nameLabel = UILabel(frame: CGRect(x: 24, y: 96, width: kScreenWidth-48, height: 80))
        nameLabel.text = NSString(string: filePath).lastPathComponent
        nameLabel.font = .systemFont(ofSize: 15)
        nameLabel.textColor = kHexColor("333")
        nameLabel.numberOfLines = 4
        nameLabel.textAlignment = .center
        view.addSubview(nameLabel)
        
        let tipLabel = UILabel(frame: CGRect(x: nameLabel.mst_left, y: nameLabel.mst_bottom+88, width: nameLabel.mst_width, height: 40))
        tipLabel.text = "该文件暂不支持本地浏览，请使用其他应用打开"
        tipLabel.font = .systemFont(ofSize: 14)
        tipLabel.textColor = kHexColor("666")
        tipLabel.numberOfLines = 0
        tipLabel.textAlignment = .center
        view.addSubview(tipLabel)
        
        let openBtn = MSTAppUITool.confirmButton(of: "使用其他应用打开", bgColor: kHexColor("#4A8EF7"))
        openBtn.mst_top = tipLabel.mst_bottom+44
        openBtn.addTarget(self, action: #selector(p_otherAppAction), for: .touchUpInside)
        view.addSubview(openBtn)
    }
}

// MARK: - Actions
extension MSTFileBrowserVC {
    @objc private func p_otherAppAction() {
        if _fileURL != nil {
            let vc = UIDocumentInteractionController(url: _fileURL!)
            vc.presentOpenInMenu(from: .zero, in: view, animated: true)
            vc.delegate = self
        }
    }
}

// MARK: -
extension MSTFileBrowserVC: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let str = """
                var script = document.createElement('script');
                script.type = 'text/javascript';
                script.text = \"function ResizeImages() {
                var myimg,oldwidth;
                var maxwidth=350;
                for(i=0;i <document.images.length;i++){
                myimg = document.images[i];
                if(myimg.width > maxwidth){
                oldwidth = myimg.width;
                myimg.width = maxwidth;
                myimg.height = maxwidth * (myimg.height/oldwidth);
                }
                }
                }\";
                document.getElementsByTagName('head')[0].appendChild(script);
                """
        webView.evaluateJavaScript(str, completionHandler: nil)
        webView.evaluateJavaScript("ResizeImages();", completionHandler: nil)
    }
}

// MARK: - QLPreviewControllerDataSource & Delegate
extension MSTFileBrowserVC: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return (_fileURL!) as QLPreviewItem
    }
}

// MARK: - UIDocumentInteractionControllerDelegate
extension MSTFileBrowserVC: UIDocumentInteractionControllerDelegate {
    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
