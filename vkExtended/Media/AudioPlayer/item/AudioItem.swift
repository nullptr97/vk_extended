//
//  AudioItem.swift
//  AudioPlayer
//
//  Created by Kevin DELANNOY on 12/03/16.
//  Copyright © 2016 Kevin Delannoy. All rights reserved.
//

import AVFoundation
import Kingfisher

#if os(iOS) || os(tvOS)
    import UIKit
    import MediaPlayer

    public typealias Image = UIImage
#else
    import Cocoa

    public typealias Image = NSImage

#endif

@objc protocol CachingPlayerItemDelegate {
    
    /// Is called when the media file is fully downloaded.
    @objc optional func playerItem(_ playerItem: AudioItem)
    
    /// Is called every time a new portion of data is received.
    @objc optional func playerItem(_ playerItem: AudioItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int)
    
    /// Is called after initial prebuffering is finished, means
    /// we are ready to play.
    @objc optional func playerItemReadyToPlay(_ playerItem: AudioItem)
    
    /// Is called when the data being downloaded did not arrive in time to
    /// continue playback.
    @objc optional func playerItemPlaybackStalled(_ playerItem: AudioItem)
    
    /// Is called on downloading error.
    @objc optional func playerItem(_ playerItem: AudioItem, downloadingFailedWith error: Error)
    
}

// MARK: - AudioQuality

/// `AudioQuality` differentiates qualities for audio.
///
/// - low: The lowest quality.
/// - medium: The quality between highest and lowest.
/// - high: The highest quality.
public enum AudioQuality: Int {
    case low = 0
    case medium = 1
    case high = 2
}

// MARK: - AudioItemURL

/// `AudioItemURL` contains information about an Item URL such as its quality.
public struct AudioItemURL {
    /// The quality of the stream.
    public let quality: AudioQuality

    /// The url of the stream.
    public let url: URL

    /// Initializes an AudioItemURL.
    ///
    /// - Parameters:
    ///   - quality: The quality of the stream.
    ///   - url: The url of the stream.
    public init?(quality: AudioQuality, url: URL?) {
        guard let url = url else { return nil }

        self.quality = quality
        self.url = url
    }
}

// MARK: - AudioItem

/// An `AudioItem` instance contains every piece of information needed for an `AudioPlayer` to play.
///
/// URLs can be remote or local.
open class AudioItem: NSObject {

    class ResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate, URLSessionDelegate, URLSessionDataDelegate, URLSessionTaskDelegate, URLSessionDownloadDelegate {
        
        var playingFromData = false
        var mimeType: String? // is required when playing from Data
        var session: URLSession?
        var mediaData: Data?
        var response: URLResponse?
        var pendingRequests = Set<AVAssetResourceLoadingRequest>()
        weak var owner: AudioItem?
        
        func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
            
            if session == nil {
                guard let initialUrl = owner?.soundURLs[.high] else {
                    fatalError("internal inconsistency")
                }
                
                startDataRequest(with: initialUrl)
            }
            
            pendingRequests.insert(loadingRequest)
            processPendingRequests()
            return true
        }
        
        func startDataRequest(with url: URL) {
            let configuration = URLSessionConfiguration.default
            configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
            session?.downloadTask(with: url).resume()
        }
        
        func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
            pendingRequests.remove(loadingRequest)
        }
        
        // MARK: URLSession delegate
        
        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            mediaData?.append(data)
            processPendingRequests()
            owner?.delegate?.playerItem?(owner!, didDownloadBytesSoFar: mediaData!.count, outOf: Int(dataTask.countOfBytesExpectedToReceive))
        }
        
        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
            completionHandler(Foundation.URLSession.ResponseDisposition.allow)
            mediaData = Data()
            self.response = response
            processPendingRequests()
        }
        
        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            if let errorUnwrapped = error {
                owner?.delegate?.playerItem?(owner!, downloadingFailedWith: errorUnwrapped)
                return
            }

            processPendingRequests()
            owner?.delegate?.playerItem?(owner!)
        }
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
            guard let url = owner?.soundURLs[.high] else { return }
            let destinationUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(url.lastPathComponent)
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
            } else {
                do {
                    // after downloading your file you need to move it to your destination url
                    try FileManager.default.moveItem(at: location, to: destinationUrl)
                    print("File moved to \(destinationUrl)")
                } catch {
                    print(error)
                }
            }
        }
        
        // MARK: -
        
        func processPendingRequests() {
            
            // get all fullfilled requests
            let requestsFulfilled = Set<AVAssetResourceLoadingRequest>(pendingRequests.compactMap {
                self.fillInContentInformationRequest($0.contentInformationRequest)
                if self.haveEnoughDataToFulfillRequest($0.dataRequest!) {
                    $0.finishLoading()
                    return $0
                }
                return nil
            })
            
            // remove fulfilled requests from pending requests
            _ = requestsFulfilled.map { self.pendingRequests.remove($0) }
            
        }
        
        func fillInContentInformationRequest(_ contentInformationRequest: AVAssetResourceLoadingContentInformationRequest?) {
            
            // if we play from Data we make no url requests, therefore we have no responses, so we need to fill in contentInformationRequest manually
            if playingFromData {
                contentInformationRequest?.contentType = self.mimeType
                contentInformationRequest?.contentLength = Int64(mediaData!.count)
                contentInformationRequest?.isByteRangeAccessSupported = true
                return
            }
            
            guard let responseUnwrapped = response else {
                // have no response from the server yet
                return
            }
            
            contentInformationRequest?.contentType = responseUnwrapped.mimeType
            contentInformationRequest?.contentLength = responseUnwrapped.expectedContentLength
            contentInformationRequest?.isByteRangeAccessSupported = true
            
        }
        
        func haveEnoughDataToFulfillRequest(_ dataRequest: AVAssetResourceLoadingDataRequest) -> Bool {
            
            let requestedOffset = Int(dataRequest.requestedOffset)
            let requestedLength = dataRequest.requestedLength
            let currentOffset = Int(dataRequest.currentOffset)
            
            guard let songDataUnwrapped = mediaData,
                  songDataUnwrapped.count > currentOffset else {
                // Don't have any data at all for this request.
                return false
            }
            
            let bytesToRespond = min(songDataUnwrapped.count - currentOffset, requestedLength)
            let dataToRespond = songDataUnwrapped.subdata(in: Range(uncheckedBounds: (currentOffset, currentOffset + bytesToRespond)))
            dataRequest.respond(with: dataToRespond)
            
            return songDataUnwrapped.count >= requestedLength + requestedOffset
            
        }
        
        deinit {
            session?.invalidateAndCancel()
        }
    }
    
    fileprivate let docsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    fileprivate let resourceLoaderDelegate = ResourceLoaderDelegate()
    fileprivate var initialScheme: String?
    var localURL: URL? {
        guard let url = soundURLs[.high] else { return nil }
        if FileManager.default.fileExists(atPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(url.lastPathComponent).path) {
            return docsPath.appendingPathComponent(url.lastPathComponent)
        } else {
            return nil
        }
    }

    var isLoaded: Bool {
        return localURL != nil
    }
    
    weak var delegate: CachingPlayerItemDelegate?
    
    open func download() {
        guard let url = soundURLs[.high], let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let scheme = components.scheme,
              let urlWithCustomScheme = url.withScheme(cachingPlayerItemScheme) else {
            fatalError("Urls without a scheme are not supported")
        }
        
        self.initialScheme = scheme
        
        let asset = AVURLAsset(url: urlWithCustomScheme)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: .main)

        resourceLoaderDelegate.owner = self

        NotificationCenter.default.addObserver(self, selector: #selector(playbackStalledHandler), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: self)
        
        if resourceLoaderDelegate.session == nil {
            resourceLoaderDelegate.startDataRequest(with: url)
        }
    }
    
    private let cachingPlayerItemScheme = "cachingPlayerItemScheme"
    
    // MARK: KVO
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        delegate?.playerItemReadyToPlay?(self)
    }
    
    // MARK: Notification hanlers
    
    @objc func playbackStalledHandler() {
        delegate?.playerItemPlaybackStalled?(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        resourceLoaderDelegate.session?.invalidateAndCancel()
    }
    
    /// Returns the available qualities.
    public let soundURLs: [AudioQuality: URL]
    public let itemId: Int
    public let model: AudioViewModel

    // MARK: Initialization

    /// Initializes an AudioItem. Fails if every urls are nil.
    ///
    /// - Parameters:
    ///   - highQualitySoundURL: The URL for the high quality sound.
    ///   - mediumQualitySoundURL: The URL for the medium quality sound.
    ///   - lowQualitySoundURL: The URL for the low quality sound.
    public convenience init?(highQualitySoundURL: URL? = nil,
                             mediumQualitySoundURL: URL? = nil,
                             lowQualitySoundURL: URL? = nil,
                             itemId: Int,
                             model: AudioViewModel) {
        var URLs = [AudioQuality: URL]()
        if let highURL = highQualitySoundURL {
            URLs[.high] = highURL
        }
        if let mediumURL = mediumQualitySoundURL {
            URLs[.medium] = mediumURL
        }
        if let lowURL = lowQualitySoundURL {
            URLs[.low] = lowURL
        }
        self.init(soundURLs: URLs, itemId: itemId, model: model)
    }

    /// Initializes an `AudioItem`.
    ///
    /// - Parameter soundURLs: The URLs of the sound associated with its quality wrapped in a `Dictionary`.
    public init?(soundURLs: [AudioQuality: URL], itemId: Int, model: AudioViewModel) {
        self.soundURLs = soundURLs
        self.itemId = itemId
        self.model = model
        super.init()

        if soundURLs.isEmpty {
            return nil
        }
    }

    // MARK: Quality selection

    /// Returns the highest quality URL found or nil if no URLs are available
    open var highestQualityURL: AudioItemURL {
        //swiftlint:disable force_unwrapping
        return (AudioItemURL(quality: .high, url: soundURLs[.high]) ??
            AudioItemURL(quality: .medium, url: soundURLs[.medium]) ??
            AudioItemURL(quality: .low, url: soundURLs[.low]))!
    }

    /// Returns the medium quality URL found or nil if no URLs are available
    open var mediumQualityURL: AudioItemURL {
        //swiftlint:disable force_unwrapping
        return (AudioItemURL(quality: .medium, url: soundURLs[.medium]) ??
            AudioItemURL(quality: .low, url: soundURLs[.low]) ??
            AudioItemURL(quality: .high, url: soundURLs[.high]))!
    }

    /// Returns the lowest quality URL found or nil if no URLs are available
    open var lowestQualityURL: AudioItemURL {
        //swiftlint:disable force_unwrapping
        return (AudioItemURL(quality: .low, url: soundURLs[.low]) ??
            AudioItemURL(quality: .medium, url: soundURLs[.medium]) ??
            AudioItemURL(quality: .high, url: soundURLs[.high]))!
    }

    /// Returns an URL that best fits a given quality.
    ///
    /// - Parameter quality: The quality for the requested URL.
    /// - Returns: The URL that best fits the given quality.
    func url(for quality: AudioQuality) -> AudioItemURL {
        switch quality {
        case .high:
            return highestQualityURL
        case .medium:
            return mediumQualityURL
        default:
            return lowestQualityURL
        }
    }

    // MARK: Additional properties

    /// The artist of the item.
    ///
    /// This can change over time which is why the property is dynamic. It enables KVO on the property.
    @objc open dynamic var artist: String?

    /// The title of the item.
    ///
    /// This can change over time which is why the property is dynamic. It enables KVO on the property.
    @objc open dynamic var title: String?

    /// The album of the item.
    ///
    /// This can change over time which is why the property is dynamic. It enables KVO on the property.
    @objc open dynamic var album: String?

    ///The track count of the item's album.
    ///
    /// This can change over time which is why the property is dynamic. It enables KVO on the property.
    @objc open dynamic var trackCount: NSNumber?

    /// The track number of the item in its album.
    ///
    /// This can change over time which is why the property is dynamic. It enables KVO on the property.
    @objc open dynamic var trackNumber: NSNumber?

    /// The artwork image of the item.
    open var artworkImage: Image? {
        get {
            #if os(OSX)
                return artwork
            #else
                return artwork?.image(at: imageSize ?? CGSize(width: 512, height: 512))
            #endif
        }
        set {
            #if os(OSX)
                artwork = newValue
            #else
                imageSize = newValue?.size
                artwork = newValue.map { image in
                    if #available(iOS 10.0, tvOS 10.0, *) {
                        return MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                    }
                    return MPMediaItemArtwork(image: image)
                }
            #endif
        }
    }

    /// The artwork image of the item.
    ///
    /// This can change over time which is why the property is dynamic. It enables KVO on the property.
    #if os(OSX)
    @objc open dynamic var artwork: Image?
    #else
    @objc open dynamic var artwork: MPMediaItemArtwork?

    /// The image size.
    private var imageSize: CGSize?
    #endif

    // MARK: Metadata

    /// Parses the metadata coming from the stream/file specified in the URL's. The default behavior is to set values
    /// for every property that is nil. Customization is available through subclassing.
    ///
    /// - Parameter items: The metadata items.
    open func parseMetadata() {
        title = model.title
        artist = model.artist
        album = model.album.title
        if let url = URL(string: model.album.imageUrl) {
            KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    self.artworkImage = value.image
                case .failure(let error):
                    print(error.errorDescription ?? "")
                }
            }
        }
    }
}

fileprivate extension URL {
    func withScheme(_ scheme: String) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.scheme = scheme
        return components?.url
    }
}
