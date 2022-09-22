//
//  VideoPlayerViewController.swift
//  Runner
//
//  Created by Sunnatillo Shavkatov on 21/04/22.
//

import UIKit
import TinyConstraints
import AVFoundation
import MediaPlayer
import XLActionController
import NVActivityIndicatorView
import SnapKit


protocol QualityDelegate {
    func qualityBottomSheet()
}
protocol SpeedDelegate {
    func speedBottomSheet()
}

enum SwipeDirection: Int {
    case horizontal = 0
    case vertical   = 1
}

struct SortFunctions{
    
    static func sortWithKeys(_ dict: [String: String]) -> [String: String] {
        let sorted = dict.sorted(by: >)
        var newDict: [String: String] = [:]
        for sortedDict in sorted {
            newDict[sortedDict.key] = sortedDict.value
        }
        return newDict
    }
}

protocol VideoPlayerDelegate: AnyObject {
    func getDuration(duration: Double)
}

class VideoPlayerViewController: UIViewController, SettingsBottomSheetCellDelegate, BottomSheetCellDelegate {
    
    struct Constants {
        static let horizontalSpacing: CGFloat = 0
        static let controlButtonSize: CGFloat = 55.0
        static let maxButtonSize: CGFloat = 40.0
        static let bottomViewButtonSize: CGFloat = 16
        static let unblockButtonSize : CGFloat = 32.0
        static let unblockButtonInset : CGFloat = 24.0
        static let bottomViewButtonInset: CGFloat = 24.0
        static let topButtonSize: CGFloat = 50.0
        static let controlButtonInset: CGFloat = 48
        static let alphaValue: CGFloat = 0.3
        static let topButtonInset: CGFloat = 34
        static let nextEpisodeInset: CGFloat = 20
        static let nextEpisodeShowTime : Float = 60
    }
    private var speedList = ["0.25","0.5","0.75","1.0","1.25","1.5","1.75","2.0"].sorted()
    private var seasonList = ["1-сезон","2-сезон","3-сезон","4-сезон","5-сезон"]
    private var player = AVPlayer()
    private var playerLayer =  AVPlayerLayer()
    private var playerItemContext = 0
    weak var delegate: VideoPlayerDelegate?
    var urlString: String?
    var locale:String = "ru"
    var qualityLabelText = ""
    var speedLabelText = ""
    var startPosition: Int?
    var titleText: String?
    var isRegular: Bool = false
    var resolutions: [String:String]?
    var sortedResolutions: [String] = []
    var isSerial = false
    var hasNextVideo = false
    var sesonNum: Int?
    var isAskPermission = false
    var seasons : [Seasons] = [Seasons]()
    var seasonData: [Dictionary<String, Any>]?
    var mainEpisodes: [Dictionary<String, Any>]?
    var videoPlayerChannel: FlutterMethodChannel?
    var shouldHideHomeIndicator = false
    var binaryMessenger : FlutterBinaryMessenger?
    var qualityDelegate: QualityDelegate!
    var speedDelegte: SpeedDelegate!
    private var swipeGesture: UIPanGestureRecognizer!
    private var tapGesture: UITapGestureRecognizer!
    private var tapHideGesture: UITapGestureRecognizer!
    private var panDirection = SwipeDirection.vertical
    private var isVolume = false
    private var volumeViewSlider: UISlider!
    private var timer: Timer?
    private var seekForwardTimer: Timer?
    private var seekBackwardTimer: Timer?
    private var playerRate = 1.0
    private var isMax = false
    var selectedSeason = 0
    private var selectedSpeedText = "1.0x"
    private var selectedAudioTrack = "None"
    private var selectedSubtitle = "None"
    var qualityText = "Auto"
    private var isBlock = false
    private var videoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    private var overlayView: UIView = {
        let view = UIView()
        view.tag = 2
        view.layer.zPosition = 2
        view.backgroundColor =  UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.64)
        return view
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    private var landscapeButton: UIButton = {
        let button = UIButton()
        if(UIDevice.current.orientation.isLandscape){
            button.setImage(UIImage(named: "ic_horizontal",in: Bundle(for: SwiftUdevsVideoPlayerPlugin.self),compatibleWith: nil), for: .normal)
        } else {
            button.setImage(UIImage(named: "ic_portrait",in: Bundle(for: SwiftUdevsVideoPlayerPlugin.self),compatibleWith: nil), for: .normal)
        }
        button.addTarget(self, action: #selector(changeOrientation(_:)), for: .touchUpInside)
        return button
    }()
    
    private var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private var durationTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        
        return label
    }()
    
    private var leftTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        return label
    }()
    
    private var seperatorLabel: UILabel = {
        let label = UILabel()
        label.text = " / "
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private var blockLabel: UILabel = {
        let label = UILabel()
        label.text = "Экран заблокирован"
        label.textColor = .white
        label.font = label.font.withSize(15)
        return label
    }()
    
    private var blockLabelInfo: UILabel = {
        let label = UILabel()
        label.text = "Коснитесь, чтобы разблокировать"
        label.textColor = UIColor(named: "baseTextColor")
        label.font = label.font.withSize(13)
        return label
    }()
    
    private var blockBottomView: UIView = {
        let view = UIView()
        return view
    }()
    
    private var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    //MARK: - BottomActionsStackView
    private lazy var bottomActionsStackView: UIStackView = {
        let spacer = UIView()
        let stackView = UIStackView(arrangedSubviews: [episodesButton])
        stackView.axis = .horizontal
        stackView.backgroundColor = .clear
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private lazy var bottomBlockStackView: UIStackView = {
        let spacer = UIView()
        let stackView = UIStackView(arrangedSubviews: isAskPermission ?  [unblockButtonWithInfo,blockLabel,blockLabelInfo] : [unblockButton,blockLabel,blockLabelInfo])
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        return stackView
    }()
    //MARK: - *************Time Stack View ***************
    private lazy var timeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [timeSlider])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.backgroundColor = .clear
        stackView.distribution = .fill
        return stackView
    }()
    
    private var timeSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = UIColor(named: "mainColor")
        slider.maximumTrackTintColor = .lightGray
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    private var exitButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_exit",in: Bundle(for: SwiftUdevsVideoPlayerPlugin.self),compatibleWith: nil), for: .normal)
        button.tintColor = .white
        button.size(CGSize(width: 32, height: 32))
        button.backgroundColor = .clear
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(exitButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    private var playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_play",in: Bundle(for: SwiftUdevsVideoPlayerPlugin.self),compatibleWith: nil), for: .normal)
        button.tintColor = .white
        button.layer.zPosition = 5
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: Constants.controlButtonInset, left: Constants.controlButtonInset, bottom: Constants.controlButtonInset, right: Constants.controlButtonInset)
        button.size(CGSize(width: 48, height: 48))
        button.addTarget(self, action: #selector(playButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    private var skipForwardButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_skip_forward",in: Bundle(for: SwiftUdevsVideoPlayerPlugin.self),compatibleWith: nil), for: .normal)
        button.tintColor = .white
        button.layer.zPosition = 3
        
        button.imageView?.contentMode = .scaleAspectFit
        button.size(CGSize(width: 48, height: 48))
        button.addTarget(self, action: #selector(skipForwardButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    private var skipBackwardButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_replay",in: Bundle(for: SwiftUdevsVideoPlayerPlugin.self),compatibleWith: nil), for: .normal)
        button.tintColor = .white
        button.layer.zPosition = 3
        button.size(CGSize(width: 48, height: 48))
        
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(skipBackButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    private  var unblockButton: UIButton = {
        let button = UIButton()
        button.setTitle("blockIcon", for: .normal)
        button.setImage(UIImage(named: "blockIcon"), for: .normal)
        button.tintColor = UIColor(named: "baseTextColor")
        button.backgroundColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: Constants.unblockButtonInset, left: Constants.unblockButtonInset, bottom: Constants.unblockButtonInset, right: Constants.unblockButtonInset)
        button.addTarget(self, action: #selector(blockButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    
    private  var unblockButtonWithInfo: UIButton = {
        let button = UIButton()
        button.setTitle("blocIcon1", for: .normal)
        button.setImage(UIImage(named: "blockIcon"), for: .normal)
        button.tintColor = UIColor(named: "baseTextColor")
        button.titleLabel?.backgroundColor = .clear
        button.imageView?.backgroundColor = .clear
        button.setTitle("Разблокировать экран?", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.contentHorizontalAlignment = .center
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = .white
        button.isHidden = true
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right:6)
        button.addTarget(self, action: #selector(blockButtonWithInfoPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    private  var episodesButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_serial",in: Bundle(for: SwiftUdevsVideoPlayerPlugin.self),compatibleWith: nil), for: .normal)
        button.setTitle("Серии", for: .normal)
        button.layer.zPosition = 3
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13,weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 8)
        button.imageEdgeInsets = UIEdgeInsets(top: Constants.bottomViewButtonInset + 6, left: 0, bottom: Constants.bottomViewButtonInset, right: 0)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(episodesButtonPressed(_:)), for: .touchUpInside)
        button.isHidden = false
        return button
    }()
    
    private  var settingsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_more",in: Bundle(for: SwiftUdevsVideoPlayerPlugin.self),compatibleWith: nil), for: .normal)
        button.layer.zPosition = 3
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13,weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 8)
        button.imageEdgeInsets = UIEdgeInsets(top: Constants.bottomViewButtonInset, left: 0, bottom: Constants.bottomViewButtonInset, right: 0)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(settingPressed(_ :)), for: .touchUpInside)
        button.isHidden = false
        return button
    }()
    
    private  var nextEpisodeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "nextEpisodeIcon"), for: .normal)
        button.setTitle("След. эпизод", for: .normal)
        button.layer.zPosition = 3
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13,weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 8)
        button.imageEdgeInsets = UIEdgeInsets(top: Constants.bottomViewButtonInset, left: 0, bottom: Constants.bottomViewButtonInset, right: 0)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(nextEpisodeButtonPressed(_:)), for: .touchUpInside)
        button.isHidden = false
        return button
    }()
    
    var qualitySelectionButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "qualityIcon"), for: .normal)
        button.setTitle("Качество", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13,weight: .semibold)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 8)
        button.imageEdgeInsets = UIEdgeInsets(top: Constants.bottomViewButtonInset, left: 0, bottom: Constants.bottomViewButtonInset, right: 0)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(qualitySelectionButtonPressed(_:)), for: .touchUpInside)
        button.isHidden = false
        
        return button
    }()
    
    private  var speedButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "speedIcon"), for: .normal)
        button.setTitle("Скорость (1х)", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13,weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 8)
        button.imageEdgeInsets = UIEdgeInsets(top: Constants.bottomViewButtonInset, left: 0, bottom: Constants.bottomViewButtonInset, right: 0)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(speedButtonPressed(_:)), for: .touchUpInside)
        button.isHidden = false
        return button
    }()
    
    private  var blockButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_lock"), for: .normal)
        button.setTitle("Блокировка", for: .normal)
        button.layer.zPosition = 3
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13,weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 8)
        button.imageEdgeInsets = UIEdgeInsets(top: Constants.bottomViewButtonInset, left: 0, bottom: Constants.bottomViewButtonInset, right: 0)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(blockButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    private var activityIndicatorView: NVActivityIndicatorView = {
        let activityView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50), type: .circleStrokeSpin, color: .white)
        return activityView
    }()
    
    private var portraitConstraints = Constraints()
    private var landscapeConstraints = Constraints()
    private var enableGesture = true
    private var backwardGestureTimer: Timer?
    private var forwardGestureTimer: Timer?
    private var backwardTouches = 0
    private var forwardTouches = 0
    
    func handle(call: FlutterMethodCall, result: FlutterResult) -> Void {
        switch(call.method){
        case "nextVideoResult":
            let arguments = call.arguments as? [String:Any]
            if let args = arguments {
                let res = NextVideoResult.fromMap(map: args)
                if res.has {
                    hasNextVideo = res.hasNextVideo
                    if !hasNextVideo {
                        nextEpisodeButton.isHidden = true
                    }
                    resolutions = res.resolutions
                    setupDataSource(title: res.title, urlString: res.url,startAt: nil)
                    runPlayer(startAt: res.startAt)
                }
            }
            result(nil)
            break
        case "closePlayer":
            result(nil);
            self.dismiss(animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
    
    func setupDataSource(title:String?, urlString: String?, startAt  : Int64?){
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return
        }
        let urlAsset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: urlAsset)
        player.automaticallyWaitsToMinimizeStalling = true
        player.replaceCurrentItem(with: playerItem)
        player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerEndedPlaying), name: Notification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: nil)
        
        addTimeObserver(titleLabel: titleLabel, title: titleText ?? "")
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        videoView.layer.addSublayer(playerLayer)
        selectedAudioTrack = player.currentItem?.selected(type: .audio) ?? "None"
        selectedSubtitle = player.currentItem?.selected(type: .subtitle) ?? "None"
        if let titleText = title {
            if(UIDevice.current.orientation.isLandscape){
                titleLabel.text = titleText
            } else {
                titleLabel.text = ""
            }
        }
    }
    
    func runPlayer(startAt: Int){
        selectedAudioTrack = player.currentItem?.selected(type: .audio) ?? "None"
        selectedSubtitle = player.currentItem?.selected(type: .subtitle) ?? "None"
        player.currentItem?.preferredForwardBufferDuration = TimeInterval(40000)
        player.automaticallyWaitsToMinimizeStalling = true;
        player.seek(to:CMTimeMakeWithSeconds(Float64(Float(startAt)),preferredTimescale: 1000))
        player.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if locale == "en"{
            qualityLabelText = "Quality"
            speedLabelText = "Speed"
            qualityText = "Auto"
        } else if locale == "ru" {
            qualityLabelText = "Качество"
            speedLabelText = "Скорость"
            qualityText = "Авто"
        } else {
            qualityLabelText = "Video sifati"
            speedLabelText = "Tezlik"
            qualityText = "Avto"
        }
        let resList = resolutions ?? ["480p":urlString!]
        sortedResolutions = Array(resList.keys).sorted().reversed()
        Array(resList.keys).sorted().reversed().forEach { quality in
            if quality == "1080p"{
                sortedResolutions.removeLast()
                sortedResolutions.insert("1080p", at: 1)
            }
        }
        
        //        self.videoPlayerChannel?.setMethodCallHandler(handle)
        
        view.backgroundColor = UIColor(named: "moreColor")
        if #available(iOS 13.0, *) {
            let value = UIInterfaceOrientationMask.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        } else {
            //            appDelegate.restrictRotation = .all
        }
        
        if #available(iOS 13.0, *) {
            setSliderThumbTintColor(UIColor(named: "mainColor") ?? .white)
        } else {
            timeSlider.thumbTintColor = UIColor(named: "mainColor")
        }
        view.backgroundColor = .black
        setNeedsUpdateOfHomeIndicatorAutoHidden()
        addSubviews()
        pinchGesture()
        bottomView.clipsToBounds = true
        timeSlider.clipsToBounds = true
        addConstraints()
        addGestures()
        playButton.alpha = 0.0
        activityIndicatorView.startAnimating()
        setupDataSource(title: titleText, urlString: urlString,startAt: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (selectedSpeedText == speedList[1]) {
            isRegular = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoView.bounds
        setNeedsUpdateOfHomeIndicatorAutoHidden()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        resetTimer()
        configureVolume()
        runPlayer(startAt: startPosition ?? 0)
        self.shouldHideHomeIndicator = true
        setNeedsUpdateOfHomeIndicatorAutoHidden()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)
        player.cancelPendingPrerolls()
        player.pause()
        playerLayer.player = nil
        playerLayer.removeFromSuperlayer()
        delegate?.getDuration(duration: player.currentTime().seconds)
        let value = UIInterfaceOrientationMask.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            addVideosLandscapeConstraints()
        } else {
            print("Portrait")
            addVideoPortaitConstraints()
        }
    }
    //MARK: - Hide Home Indicator
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    //@available(iOS 11, *)
    override var childForHomeIndicatorAutoHidden: UIViewController? {
        return nil
    }
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.bottom]
    }
    
    func addGestures(){
        swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(swipePan))
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureControls))
        
        view.addGestureRecognizer(swipeGesture)
        view.addGestureRecognizer(tapGesture)
    }
    
    func addSubviews() {
        view.addSubview(videoView)
        view.addSubview(overlayView)
        overlayView.addSubview(topView)
        overlayView.addSubview(playButton)
        overlayView.addSubview(skipForwardButton)
        view.addSubview(skipForwardButton)
        overlayView.addSubview(skipBackwardButton)
        view.addSubview(skipBackwardButton)
        overlayView.addSubview(activityIndicatorView)
        overlayView.addSubview(bottomView)
        overlayView.addSubview(landscapeButton)
        addTopViewSubviews()
        addBottomViewSubviews()
    }
    
    //MARK: - addBottomViewSubviews
    func addBottomViewSubviews() {
        bottomView.addSubview(currentTimeLabel)
        bottomView.addSubview(durationTimeLabel)
        bottomView.addSubview(seperatorLabel)
        bottomView.addSubview(timeSlider)
        bottomView.addSubview(timeStackView)
        bottomView.addSubview(bottomActionsStackView)
    }
    
    func addTopViewSubviews() {
        topView.addSubview(exitButton)
        topView.addSubview(titleLabel)
        topView.addSubview(settingsButton)
    }
    
    func addConstraints() {
        addVideosLandscapeConstraints()
        addBottomViewConstraints()
        addTopViewConstraints()
        addControlButtonConstraints()
    }
    
    func addControlButtonConstraints(){
        playButton.center(in: view)
        playButton.width(Constants.controlButtonSize)
        playButton.height(Constants.controlButtonSize)
        playButton.layer.cornerRadius = Constants.controlButtonSize/2
        skipBackwardButton.width(Constants.controlButtonSize)
        skipBackwardButton.height(Constants.controlButtonSize)
        skipBackwardButton.rightToLeft(of: playButton, offset: -60)
        skipBackwardButton.top(to: playButton)
        skipBackwardButton.layer.cornerRadius = Constants.controlButtonSize/2
        skipForwardButton.width(Constants.controlButtonSize)
        skipForwardButton.height(Constants.controlButtonSize)
        skipForwardButton.leftToRight(of: playButton, offset: 60)
        skipForwardButton.top(to: playButton)
        skipForwardButton.layer.cornerRadius = Constants.controlButtonSize/2
        activityIndicatorView.center(in: view)
        activityIndicatorView.layer.cornerRadius = 20
    }
    
    func addBottomViewConstraints() {
        var bottomPad: CGFloat = 0.0
        if #available(iOS 13.0, *) {
            bottomPad = -5
        } else {
            bottomPad = 5
        }
        
        bottomView.leading(to: view.safeAreaLayoutGuide, offset: Constants.horizontalSpacing)
        bottomView.trailing(to: view.safeAreaLayoutGuide, offset: -Constants.horizontalSpacing)
        bottomView.bottom(to: view.safeAreaLayoutGuide, offset: 0)
        bottomView.height(70)
        
        //        blockBottomView.leading(to: view.safeAreaLayoutGuide)
        //        blockBottomView.trailing(to: view.safeAreaLayoutGuide)
        //        blockBottomView.bottom(to: view.safeAreaLayoutGuide, offset: 10)
        //        blockBottomView.height(90)
        //        blockBottomView.alpha = 0
        
        //        unblockButton.top(to: blockBottomView)
        //        unblockButton.centerX(to: blockBottomView)
        //        unblockButton.width(Constants.unblockButtonSize)
        //        unblockButton.height(Constants.unblockButtonSize)
        //        unblockButton.layer.cornerRadius = 8
        //
        //        unblockButtonWithInfo.top(to: blockBottomView)
        //        unblockButtonWithInfo.centerX(to: blockBottomView)
        //        unblockButtonWithInfo.width(221)
        //        unblockButtonWithInfo.height(Constants.unblockButtonSize)
        //        unblockButtonWithInfo.layer.cornerRadius = 8
        //
        //        blockLabel.centerX(to: blockBottomView)
        //        blockLabel.topToBottom(of: unblockButton,offset: 8)
        //
        //        blockLabelInfo.centerX(to: blockBottomView)
        //        blockLabelInfo.topToBottom(of: blockLabel,offset: 4)
        
        //MARK: - Time Stack View Constraint
        //        timeSlider.centerY(to: bottomView)
        //        timeSlider.left(to: bottomView)
        //        timeSlider.right(to: bottomView)
        //        timeStackView.centerY(to: bottomView)
        //        timeStackView.left(to: bottomView)
        //        timeStackView.right(to: bottomView)
        
        timeStackView.snp.makeConstraints { make in
            make.centerY.equalTo(bottomView)
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
        }
        
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if(isSerial) {
            bottomActionsStackView.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-10)
            }
        }else {
            bottomActionsStackView.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(80)
                make.right.equalToSuperview().offset(-80)
            }
        }
        currentTimeLabel.snp.makeConstraints { make in
            make.left.equalTo(bottomView).offset(16)
        }
        currentTimeLabel.bottomToTop(of: timeSlider, offset: bottomPad)
        seperatorLabel.leftToRight(of: currentTimeLabel)
        seperatorLabel.centerY(to: currentTimeLabel)
        durationTimeLabel.leftToRight(of: seperatorLabel)
        durationTimeLabel.bottomToTop(of: timeSlider, offset: bottomPad)
        landscapeButton.bottomToTop(of: timeSlider, offset: 0)
        landscapeButton.snp.makeConstraints { make in
            make.right.equalTo(bottomView).offset(-16)
        }
        speedButton.width(150)
        speedButton.height(Constants.bottomViewButtonSize)
        speedButton.layer.cornerRadius = 8
        
        blockButton.width(136)
        blockButton.height(Constants.bottomViewButtonSize)
        blockButton.layer.cornerRadius = 8
        
        
        episodesButton.width(136)
        episodesButton.height(Constants.bottomViewButtonSize)
        episodesButton.layer.cornerRadius = 8
        
        qualitySelectionButton.width(136)
        qualitySelectionButton.height(Constants.bottomViewButtonSize)
        qualitySelectionButton.layer.cornerRadius = 8
        
        nextEpisodeButton.width(136)
        nextEpisodeButton.height(Constants.bottomViewButtonSize)
        nextEpisodeButton.layer.cornerRadius = 8
        
        if !isSerial {
            episodesButton.isHidden = true
            nextEpisodeButton.isHidden = true
        }
    }
    
    func addTopViewConstraints() {
        topView.leading(to: view.safeAreaLayoutGuide, offset: Constants.horizontalSpacing)
        topView.trailing(to: view.safeAreaLayoutGuide, offset: 0)
        topView.top(to: view.safeAreaLayoutGuide, offset: 10)
        topView.height(64)
        titleLabel.centerY(to: topView)
        titleLabel.centerX(to: topView)
        titleLabel.layoutMargins = .horizontal(16)
        exitButton.width(Constants.topButtonSize)
        exitButton.height(Constants.topButtonSize)
        exitButton.left(to: topView)
        exitButton.centerY(to: topView)
        exitButton.layer.cornerRadius = Constants.topButtonSize/2
        
        settingsButton.width(50)
        settingsButton.height(Constants.bottomViewButtonSize)
        settingsButton.layer.cornerRadius = 8
        settingsButton.right(to: topView)
        settingsButton.centerY(to: topView)
        
    }
    
    func addVideosLandscapeConstraints() {
        portraitConstraints.deActivate()
        landscapeConstraints.append(contentsOf: videoView.edgesToSuperview())
    }
    func addVideoPortaitConstraints() {
        landscapeConstraints.deActivate()
        let width = view.frame.width
        let heigth = width * 9 / 16
        portraitConstraints.append(contentsOf: videoView.center(in: view))
        portraitConstraints.append(contentsOf: videoView.height(min: heigth, max: view.frame.height, priority: .defaultLow, isActive: true))
        portraitConstraints.append(videoView.left(to: view))
        portraitConstraints.append(videoView.right(to: view))
    }
    
    fileprivate func makeCircleWith(size: CGSize, backgroundColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(backgroundColor.cgColor)
        context?.setStrokeColor(UIColor.clear.cgColor)
        let bounds = CGRect(origin: .zero, size: size)
        context?.addEllipse(in: bounds)
        context?.drawPath(using: .fill)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func setSliderThumbTintColor(_ color: UIColor) {
        let circleImage = makeCircleWith(size: CGSize(width: 28, height: 28),
                                         backgroundColor: color)
        timeSlider.setThumbImage(circleImage, for: .normal)
        timeSlider.setThumbImage(circleImage, for: .highlighted)
    }
    
    func configureVolume() {
        let volumeView = MPVolumeView()
        for view in volumeView.subviews {
            if let slider = view as? UISlider {
                self.volumeViewSlider = slider
            }
        }
    }
    
    //MARK: - Buttons logic
    @objc func playButtonPressed(_ sender: UIButton){
        if !player.isPlaying {
            player.play()
            playButton.setImage(UIImage(named: "ic_pause"), for: .normal)
            self.player.preroll(atRate: Float(self.playerRate), completionHandler: nil)
            self.player.rate = Float(self.playerRate)
            resetTimer()
        } else {
            playButton.setImage(UIImage(named: "ic_play",in: Bundle(for: SwiftUdevsVideoPlayerPlugin.self),compatibleWith: nil), for: .normal)
            player.pause()
            timer?.invalidate()
            showControls()
        }
    }
    
    @objc func exitButtonPressed(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil);
    }
    
    @objc func changeOrientation(_ sender: UIButton){
        var value  = UIInterfaceOrientation.landscapeRight.rawValue
        landscapeButton.setImage(UIImage(named: "ic_horizontal",in: Bundle(for: SwiftUdevsVideoPlayerPlugin.self),compatibleWith: nil), for: .normal)
        if UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight{
            value = UIInterfaceOrientation.portrait.rawValue
            landscapeButton.setImage(UIImage(named: "ic_portrait",in: Bundle(for: SwiftUdevsVideoPlayerPlugin.self),compatibleWith: nil), for: .normal)
            videoView.backgroundColor = .black
        }
        UIDevice.current.setValue(value, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    @objc func skipBackButtonPressed(_ sender: UIButton){
        self.backwardTouches += 1
        self.seekBackwardTo(10.0 * Double(self.backwardTouches))
        self.backwardGestureTimer?.invalidate()
        self.backwardGestureTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.backwardTouches = 0
        }
        resetTimer()
    }
    
    @objc func skipForwardButtonPressed(_ sender: UIButton){
        
        self.forwardTouches += 1
        self.seekForwardTo(10.0 * Double(self.forwardTouches))
        self.forwardGestureTimer?.invalidate()
        self.forwardGestureTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.forwardTouches = 0
        }
        resetTimer()
    }
    
    func updateSeasonNum(index:Int) {
        selectedSeason = index
    }
    
    //MARK: - ****** SEASONS *******
    @objc func episodesButtonPressed(_ sender: UIButton){
        let episodeVC = EpisodeCollectionUI()
        episodeVC.modalPresentationStyle = .custom
        episodeVC.seasons = self.seasons
        episodeVC.delegate = self
        episodeVC.selectedSeasonIndex = selectedSeason
        self.present(episodeVC, animated: true, completion: nil)
    }
    
    @objc func nextEpisodeButtonPressed(_ sender: UIButton){
        DispatchQueue.main.async {
            self.videoPlayerChannel?.invokeMethod("nextVideo", arguments: self.player.currentTime().seconds)
        }
    }
    @objc func speedButtonPressed(_ sender: UIButton){
        showSpeedBottomSheet()
    }
    @objc func blockButtonWithInfoPressed(_ sender: UIButton){
        isBlock = false
        hideBlockControls()
        showControls()
    }
    @objc func settingPressed(_ sender: UIButton) {
        let vc = SettingVC()
        vc.modalPresentationStyle = .custom
        vc.delegete = self
        vc.speedDelegate = self
        vc.settingModel = [
            SettingModel(leftIcon: "ic_settings", title: qualityLabelText, configureLabel: qualityText),
            SettingModel(leftIcon: "ic_speed", title: speedLabelText, configureLabel:  selectedSpeedText)
        ]
        self.present(vc, animated: true, completion: nil)
    }
    @objc func blockButtonPressed(_ sender: UIButton){
        
        if isBlock {
            isAskPermission = true
            unblockButton.isHidden = true
            unblockButtonWithInfo.isHidden = false
        } else {
            isBlock = true
            isAskPermission = false
            unblockButton.isHidden = false
            unblockButtonWithInfo.isHidden = true
            hideControls()
            showBlockControls()
        }
    }
    
    @objc func qualitySelectionButtonPressed(_ sender: UIButton){
        showQualityBottomSheet()
    }
    
    fileprivate func seekForwardTo(_ seekPosition: Double) {
        guard let duration = player.currentItem?.duration else {return}
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + seekPosition
        if newTime < (CMTimeGetSeconds(duration) - seekPosition) {
            let time: CMTime = CMTimeMake(value: Int64(newTime*1000), timescale: 1000)
            player.seek(to: time)
        }
    }
    
    fileprivate func seekBackwardTo(_ seekPosition: Double) {
        let currentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = currentTime - seekPosition
        if newTime < 0 {
            newTime = 0
        }
        let time: CMTime = CMTimeMake(value: Int64(newTime*1000), timescale: 1000)
        player.seek(to: time)
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        player.seek(to: CMTimeMake(value: Int64(sender.value*1000), timescale: 1000))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "duration", let duration = player.currentItem?.duration.seconds, duration > 0.0 {
            self.durationTimeLabel.text = getTimeString(from: player.currentItem!.duration)
        }
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                
                DispatchQueue.main.async {[weak self] in
                    if newStatus == .playing{
                        print("PLAYING")
                        self?.playButton.setImage(UIImage(named: "ic_pause",in: Bundle(for: SwiftUdevsVideoPlayerPlugin.self),compatibleWith: nil), for: .normal)
                        self?.playButton.alpha = self?.skipBackwardButton.alpha ?? 0.0
                        self?.activityIndicatorView.stopAnimating()
                        self?.enableGesture = true
                    } else if newStatus == .paused {
                        print("PAUSE")
                        self?.playButton.setImage(UIImage(named: "ic_play",in: Bundle(for: SwiftUdevsVideoPlayerPlugin.self),compatibleWith: nil), for: .normal)
                        self?.playButton.alpha = self?.skipBackwardButton.alpha ?? 0.0
                        self?.activityIndicatorView.stopAnimating()
                        self?.enableGesture = true
                        self?.timer?.invalidate()
                        self?.showControls()
                    } else {
                        print("LOADING")
                        self?.playButton.alpha = 0.0
                        self?.activityIndicatorView.startAnimating()
                        self?.enableGesture = false
                    }
                }
            }
        }
    }
    
    @objc func playerEndedPlaying(_ notification: Notification) {
        DispatchQueue.main.async {[weak self] in
            if self?.hasNextVideo ?? false {
                DispatchQueue.main.async {
                    self?.videoPlayerChannel?.invokeMethod("nextVideo", arguments: self?.player.currentTime().seconds)
                }
            } else {
                self?.player.seek(to: CMTime.zero)
                self?.playButton.setImage(UIImage(named: "ic_play",in: Bundle(for: SwiftUdevsVideoPlayerPlugin.self),compatibleWith: nil), for: .normal)
            }
        }
    }
    
    func getTimeString(from time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds/3600)
        let minutes = Int(totalSeconds/60) % 60
        
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%i:%02i:%02i", arguments: [hours,minutes,seconds])
        }else {
            return String(format: "%02i:%02i", arguments: [minutes,seconds])
        }
    }
    
    //MARK: - Time logic
    func addTimeObserver(titleLabel: UILabel, title: String) {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        _ = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: { [weak self] time in
            guard let currentItem = self?.player.currentItem else {return}
            
            guard currentItem.duration >= .zero, !currentItem.duration.seconds.isNaN else {
                return
            }
            let newDurationSeconds = Float(currentItem.duration.seconds)
            self?.timeSlider.maximumValue = Float(newDurationSeconds)
            self?.timeSlider.minimumValue = 0
            self?.timeSlider.value = Float(currentItem.currentTime().seconds)
            let remainTime = Double(newDurationSeconds) - currentItem.currentTime().seconds
            let time = CMTimeMake(value: Int64(remainTime), timescale: 1)
            //            self?.leftTimeLabel.text = "-\(self?.getTimeString(from: time) ?? "00:00")"
            self?.currentTimeLabel.text = self?.getTimeString(from: currentItem.currentTime())
            if(UIDevice.current.orientation.isLandscape){
                titleLabel.text = title
            } else {
                titleLabel.text = ""
            }
        })
    }
    
    func resetTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(hideControls), userInfo: nil, repeats: false)
    }
    
    func resetSeekForwardTimer() {
        seekForwardTimer?.invalidate()
        seekForwardTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(hideSeekForwardButton), userInfo: nil, repeats: false)
    }
    
    func resetSeekBackwardTimer() {
        seekBackwardTimer?.invalidate()
        seekBackwardTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(hideSeekBackwardButton), userInfo: nil, repeats: false)
    }
    
    private func pinchGesture() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didpinch))
        videoView.addGestureRecognizer(pinchGesture)
    }
    @objc func didpinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            let scale = gesture.scale
            print("Scale \(scale)")
            if scale < 0.9 {
                self.playerLayer.videoGravity = .resizeAspect
            }else {
                self.playerLayer.videoGravity = .resizeAspectFill
            }
            resetTimer()
        }
    }
    
    @objc func hideControls() {
        let options: UIView.AnimationOptions = [.curveEaseIn]
        UIView.animate(withDuration: 0.3, delay: 0.2, options: options, animations: {[self] in
            let alpha = 0.0
            topView.alpha = alpha
            skipForwardButton.alpha = alpha
            overlayView.alpha = alpha
            if enableGesture {
                playButton.alpha = alpha
            }
            skipBackwardButton.alpha = alpha
            bottomView.alpha = alpha
            //            maximizeButton.alpha = alpha
            //            blockBottomView.alpha = alpha
        }, completion: nil)
    }
    
    @objc func hideSeekForwardButton() {
        if topView.alpha == 0 {
            let options: UIView.AnimationOptions = [.curveEaseIn]
            UIView.animate(withDuration: 0.1, delay: 0.1, options: options, animations: {[self] in
                let alpha = 0.0
                skipForwardButton.alpha = alpha
            }, completion: nil)
        }
    }
    @objc func hideSeekBackwardButton() {
        if topView.alpha == 0 {
            let options: UIView.AnimationOptions = [.curveEaseIn]
            UIView.animate(withDuration: 0.1, delay: 0.1, options: options, animations: {[self] in
                let alpha = 0.0
                skipBackwardButton.alpha = alpha
            }, completion: nil)
        }
    }
    
    func showSeekForwardButton(){
        skipForwardButton.alpha = 1.0
        print("=======FORWARD SHOW")
    }
    func showSeekBackwardButton(){
        skipBackwardButton.alpha = 1.0
        print("=======BACK SHOW")
    }
    
    @objc func hideBlockControls() {
        let options: UIView.AnimationOptions = [.curveEaseIn]
        UIView.animate(withDuration: 0.3, delay: 0.2, options: options, animations: {[self] in
            let alpha = 0.0
            //            blockBottomView.alpha = alpha
        }, completion: nil)
    }
    
    func showBlockControls(){
        let options: UIView.AnimationOptions = [.curveEaseIn]
        UIView.animate(withDuration: 0.3, delay: 0.2, options: options, animations: {[self] in
            let alpha = 1.0
            //            blockBottomView.alpha = alpha
            topView.alpha = alpha
            resetTimer()
        }, completion: nil)
    }
    func showControls() {
        let options: UIView.AnimationOptions = [.curveEaseIn]
        UIView.animate(withDuration: 0.3, delay: 0.2, options: options, animations: {[self] in
            let alpha = 1.0
            topView.alpha = alpha
            skipForwardButton.alpha = alpha
            skipBackwardButton.alpha = alpha
            if enableGesture {
                playButton.alpha = alpha
            }
            bottomView.alpha = alpha
            //            maximizeButton.alpha = alpha
        }, completion: nil)
        
    }
    
    func toggleViews() {
        let options: UIView.AnimationOptions = [.curveEaseIn]
        UIView.animate(withDuration: 0.05, delay: 0, options: options, animations: {[self] in
            let alpha = topView.alpha == 0.0 ? 1.0 : 0.0
            topView.alpha = alpha
            overlayView.alpha = alpha
            if isBlock {
                //                blockBottomView.alpha = alpha
            }else{
                skipForwardButton.alpha = alpha
                skipBackwardButton.alpha = alpha
                if enableGesture {
                    playButton.alpha = alpha
                }
                
                bottomView.alpha = alpha
                //                maximizeButton.alpha = alpha
            }
            if(alpha == 1.0){
                resetTimer()
            }
        }, completion: nil)
    }
    
    @objc func tapGestureControls() {
        
        let location = tapGesture.location(in: view)
        
        if location.x > view.bounds.width / 2 + 50 {
            self.fastForward()
            print("RIGHT SIDE PREESSED")
            
        } else if location.x <= view.bounds.width / 2 - 50 {
            self.fastBackward()
            print("LEFT SIDE PREESSED")
        } else {
            toggleViews()
        }
    }
    
    func fastForward() {
        self.forwardTouches += 1
        if forwardTouches < 2{
            self.forwardGestureTimer?.invalidate()
            self.forwardGestureTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                self.forwardTouches = 0
                self.toggleViews()
            }
        } else {
            print("===========FORWARD=========")
            self.showSeekForwardButton()
            self.seekForwardTo(10.0 * Double(self.forwardTouches))
            self.forwardGestureTimer?.invalidate()
            self.forwardGestureTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                self.forwardTouches = 0
                self.resetSeekForwardTimer()
            }
        }
    }
    func fastBackward() {
        self.backwardTouches += 1
        if backwardTouches < 2{
            self.backwardGestureTimer?.invalidate()
            self.backwardGestureTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                self.backwardTouches = 0
                self.toggleViews()
            }
        } else {
            print("**********BACK**********")
            self.showSeekBackwardButton()
            self.seekBackwardTo(10.0 * Double(self.backwardTouches))
            self.backwardGestureTimer?.invalidate()
            self.backwardGestureTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                self.backwardTouches = 0
                self.resetSeekBackwardTimer()
            }
        }
    }
    
    @objc func swipePan() {
        let locationPoint = swipeGesture.location(in: view)
        
        let velocityPoint = swipeGesture.velocity(in: view)
        
        switch swipeGesture.state {
        case .began:
            
            let x = abs(velocityPoint.x)
            let y = abs(velocityPoint.y)
            
            if x > y {
                panDirection = SwipeDirection.horizontal
            } else {
                panDirection = SwipeDirection.vertical
                if locationPoint.x > view.bounds.size.width / 2 {
                    isVolume = true
                } else {
                    isVolume = false
                }
            }
            
        case UIGestureRecognizer.State.changed:
            switch panDirection {
            case SwipeDirection.horizontal:
                //                horizontalMoved(velocityPoint.x)
                break
            case SwipeDirection.vertical:
                verticalMoved(velocityPoint.y)
                break
            }
            
        case UIGestureRecognizer.State.ended:
            switch panDirection {
            case SwipeDirection.horizontal:
                break
            case SwipeDirection.vertical:
                isVolume = false
                break
            }
        default:
            break
        }
    }
    func verticalMoved(_ value: CGFloat) {
        if isVolume{
            self.volumeViewSlider.value -= Float(value / 10000)
        }
        else{
            UIScreen.main.brightness -= value / 10000
        }
    }
    
    @objc func settingsButtonPressed(_ sender: UIButton){
        let vc = SettingsBottomSheetViewController()
        vc.modalPresentationStyle = .overCurrentContext
        vc.cellDelegate = self
        vc.items = [
            SettingsBottomSheetModel(title: "Качества", icon: "qualityIcon", currentLabel: qualityText),
            //            SettingsBottomSheetModel(title: "Скорость воспроизведения", icon: "speedIcon", currentLabel: selectedSpeedText),
            SettingsBottomSheetModel(title: "Субтитле", icon: "subtitleIcon", currentLabel: selectedSubtitle),
            SettingsBottomSheetModel(title: "Аудио", icon: "audioIcon", currentLabel: selectedAudioTrack)]
        self.present(vc, animated: false)
    }
    
    // settings bottom sheet tapped
    func onSettingsBottomSheetCellTapped(index: Int) {
        switch index {
        case 0:
            showQualityBottomSheet()
            break
        case 1:
            showSpeedBottomSheet()
            break
        case 2:
            showSubtitleBottomSheet()
            break
        case 3:
            showAudioTrackBottomSheet()
            break
        default:
            break
        }
    }
    
    //MARK: - Bottom Sheets Configurations
    // bottom sheet tapped
    func onBottomSheetCellTapped(index: Int, type : BottomSheetType) {
        switch type {
        case .quality:
            let resList = resolutions ?? ["480p":urlString!]
            debugPrint("onBottomSheetCellTapped  *resList*  \(resList)")
            let array = Array(resList.keys)
            debugPrint("onBottomSheetCellTapped  *array*  \(array)")
            self.qualityText = sortedResolutions[index]
            debugPrint("onBottomSheetCellTapped  *qualityText*  \(qualityText)")
            let url = resList[sortedResolutions[index]]
            debugPrint("onBottomSheetCellTapped  *url*  \(url ?? "")")
            guard let videoURL = URL(string: url ?? "") else {
                return
            }
            let currentTime = self.player.currentTime()
            let asset = AVURLAsset(url: videoURL)
            let playerItem = AVPlayerItem(asset: asset)
            self.player.replaceCurrentItem(with: playerItem)
            self.player.seek(to: currentTime)
            self.player.currentItem?.preferredForwardBufferDuration = TimeInterval(1)
            self.player.automaticallyWaitsToMinimizeStalling = true;
            break
        case .speed:
            self.playerRate =  Double(speedList[index])!
            self.selectedSpeedText = isRegular  ? "\(self.playerRate)x(Обычный)" : "\(self.playerRate)x"
            self.player.preroll(atRate: Float(self.playerRate), completionHandler: nil)
            self.player.rate = Float(self.playerRate)
            break
        case .subtitle:
            var subtitles = player.currentItem?.tracks(type: .subtitle) ?? ["None"]
            subtitles.insert("None", at: 0)
            let selectedSubtitleLabel = subtitles[index]
            if ((player.currentItem?.select(type: .subtitle, name: selectedSubtitleLabel)) != nil){
                selectedSubtitle = selectedSubtitleLabel
            }
            break
            
        case .audio:
            let audios = player.currentItem?.tracks(type: .audio) ?? ["None"]
            let selectedAudio = audios[index]
            if ((player.currentItem?.select(type: .audio, name: selectedAudio)) != nil){
                selectedAudioTrack = selectedAudio
            }
            break
        }
    }
    
    func showQualityBottomSheet(){
        let resList = resolutions ?? ["480p":urlString!]
        debugPrint("RESLIST \(resList)")
        let array = Array(resList.keys)
        debugPrint("ARRAY \(array)")
        var listOfQuality = [String]()
        listOfQuality = array.sorted().reversed()
        array.sorted().reversed().forEach { quality in
            if quality == "1080p"{
                listOfQuality.removeLast()
                listOfQuality.insert("1080p", at: 1)
            }
            //             listOfQuality.append(quality.replacingOccurrences(of: "AA", with: ""))
        }
        let bottomSheetVC = BottomSheetViewController()
        bottomSheetVC.modalPresentationStyle = .overCurrentContext
        bottomSheetVC.items = listOfQuality
        bottomSheetVC.labelText = qualityLabelText
        bottomSheetVC.cellDelegate = self
        bottomSheetVC.bottomSheetType = .quality
        bottomSheetVC.selectedIndex = listOfQuality.firstIndex(of: qualityText) ?? 0
        debugPrint("SELECTED INDEX \( bottomSheetVC.selectedIndex)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.present(bottomSheetVC, animated: false, completion:nil)
        }
    }
    
    func showSpeedBottomSheet(){
        let bottomSheetVC = BottomSheetViewController()
        bottomSheetVC.modalPresentationStyle = .custom
        bottomSheetVC.items = speedList
        bottomSheetVC.labelText = speedLabelText
        bottomSheetVC.cellDelegate = self
        bottomSheetVC.bottomSheetType = .speed
        bottomSheetVC.selectedIndex = speedList.firstIndex(of: "\(self.playerRate)") ?? 0
        speedButton.setTitle("Скорость (\(selectedSpeedText))", for: .normal)
        speedButton.titleLabel?.font = UIFont.systemFont(ofSize: 13,weight: .semibold)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.present(bottomSheetVC, animated: false, completion:nil)
        }
    }
    
    private func showAudioTrackBottomSheet(){
        var audios = player.currentItem?.tracks(type: .audio) ?? ["None"]
        if audios.isEmpty {
            audios = ["Auto"]
            selectedAudioTrack = "Auto"
        }
        let bottomSheetVC = BottomSheetViewController()
        bottomSheetVC.modalPresentationStyle = .overCurrentContext
        bottomSheetVC.items = audios
        bottomSheetVC.labelText = "Аудио"
        bottomSheetVC.bottomSheetType = .audio
        bottomSheetVC.cellDelegate = self
        bottomSheetVC.selectedIndex = audios.firstIndex(of: selectedAudioTrack) ?? 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.present(bottomSheetVC, animated: false, completion:nil)
        }
    }
    
    private func showSubtitleBottomSheet(){
        var subtitles = player.currentItem?.tracks(type: .subtitle) ?? ["None"]
        subtitles.insert("None", at: 0)
        let bottomSheetVC = BottomSheetViewController()
        bottomSheetVC.modalPresentationStyle = .overCurrentContext
        bottomSheetVC.items = subtitles
        bottomSheetVC.labelText = "Субтитле"
        bottomSheetVC.bottomSheetType = .subtitle
        bottomSheetVC.selectedIndex = subtitles.firstIndex(of: selectedSubtitle) ?? 0
        bottomSheetVC.cellDelegate = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.present(bottomSheetVC, animated: false, completion:nil)
        }
    }
}

extension VideoPlayerViewController: QualityDelegate, SpeedDelegate, EpisodeDelegate {
    
    func onEpisodeCellTapped(seasonIndex: Int, episodeIndex: Int) {
        
        var resolutions: [String:String] = [:]
        var startAt :Int64?
        seasons[seasonIndex].episodeList[episodeIndex].videos.forEach { video in
            print("quality: \(video.quality)\n fileName: \(video.fileName)")
            resolutions[video.quality] = video.fileName
            startAt = Int64(video.duration)
        }
        //        selectedSeason = seasonIndex + 1
        //        selectedSeason = seasonIndex + 1
        
        self.resolutions = resolutions
        
        let isFinded = resolutions.contains(where: { (key, value) in
            if key == self.qualityText {
                return true
            }
            return false
        })
        
        let title = seasons[seasonIndex].episodeList[episodeIndex].title
        if isFinded {
            let videoUrl = resolutions[self.qualityText]
            self.setupDataSource(title: "S\(seasonIndex + 1)" + ":" + "E\(episodeIndex + 1)" + " \u{22}\(title)\u{22}" , urlString: videoUrl, startAt: startAt)
        } else if !resolutions.isEmpty {
            let videoUrl = Array(resolutions.values)[0]
            self.setupDataSource(title: title, urlString: videoUrl, startAt: startAt)
        }
    }
    func speedBottomSheet() {
        showSpeedBottomSheet()
    }
    func qualityBottomSheet() {
        showQualityBottomSheet()
    }
}
