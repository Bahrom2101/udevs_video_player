import Flutter
import UIKit

public class SwiftUdevsVideoPlayerPlugin: NSObject, FlutterPlugin, VideoPlayerDelegate {
    
    public static var viewController = FlutterViewController()
    public var flutterResult: FlutterResult?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        viewController = (UIApplication.shared.delegate?.window??.rootViewController)! as! FlutterViewController
        let channel = FlutterMethodChannel(name: "udevs_video_player", binaryMessenger: registrar.messenger())
        let instance = SwiftUdevsVideoPlayerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        flutterResult = result;
        if (call.method == "closePlayer" ) {
            let vc = VideoPlayerViewController()
            vc.dismiss(animated: true, completion: nil)
        }
        if(call.method == "playVideo"){
            guard let args = call.arguments else {
                return
            }
            
            let json = (args as! [String:Any])["playerConfigJsonString"]
            if let myArgs = json as? [String: Any],let url = (myArgs["initialResolution"] as! [String:String]).values.first,
               let selectQualityText = (myArgs["initialResolution"] as! [String:String]).keys.first,
               let title = myArgs["title"] as? String,
               let tvProgramsText = myArgs["tvProgramsText"] as? String,
               let qualityText = myArgs["qualityText"] as? String,
               let speedText = myArgs["speedText"] as? String,
               let episodeButtonText = myArgs["episodeButtonText"] as? String,
               let duration = myArgs["lastPosition"] as? Int,
               let seasons = myArgs["seasons"] as? [Dictionary<String, Any>],
               let isSerial = myArgs["isSerial"] as? Bool,
               let isLive = myArgs["isLive"] as? Bool,
               let resolutions = myArgs["resolutions"] as? [String:String] {
                guard URL(string: url) != nil else {
                    return
                }
                if(isLive){
                    var programData = [Dictionary<String, Any>()]
                    guard let videoURL = URL(string: url) else {
                        return
                    }
                    programData = myArgs["programsInfoList"] as! [Dictionary<String, Any>]
                    let sortedResolutions = SortFunctions.sortWithKeys(resolutions)
                    let vc = TVVideoPlayerViewController()
                    vc.modalPresentationStyle = .fullScreen
                    vc.delegate = self
                    vc.urlString = url
                    vc.startPosition = duration
                    vc.resolutions = sortedResolutions
                    vc.titleText = title
                    vc.speedLabelText = speedText
                    vc.qualityLabelText = qualityText
                    vc.showsBtnText = tvProgramsText
                    vc.programs = ProgramModel.fromDictinaryProgramms(map: programData)
                    SwiftUdevsVideoPlayerPlugin.viewController.present(vc, animated: true,  completion: nil)
                } else {
                    guard URL(string: url) != nil else {
                        return
                    }
                    let sortedResolutions = SortFunctions.sortWithKeys(resolutions)
                    let vc = VideoPlayerViewController()
                    vc.modalPresentationStyle = .fullScreen
                    vc.delegate = self
                    vc.urlString = url
                    vc.selectedQualityText = selectQualityText
                    vc.startPosition = duration
                    vc.qualityLabelText = qualityText
                    vc.speedLabelText = speedText
                    vc.hasNextVideo = false
                    vc.resolutions = resolutions
                    vc.isSerial = isSerial
                    vc.titleText = title
                    vc.serialLabelText = episodeButtonText
                    vc.seasons  = Seasons.fromDictinary(map: seasons)
                    SwiftUdevsVideoPlayerPlugin.viewController.present(vc, animated: true,  completion: nil)}
            } else {
                result("Parse error");
            }
        } else {
            result("iOS " + UIDevice.current.systemVersion);
        }
    }
    
    func getDuration(duration: Double) {
        flutterResult!("\(duration)")
        print("Duration: \(duration)")
    }
    
}
