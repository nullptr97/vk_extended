//
//  MessageViewCell.swift
//  VK Tosters
//
//  Created by programmist_np on 30/01/2020.
//  Copyright © 2020 programmist_np. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftyJSON
import MaterialComponents
import Material
import Lottie

protocol MessageViewCellDelegate: class {
    func didTapAvatar(cell: MessageViewCell, with peerId: Int)
}

class MessageViewCell: Material.TableViewCell {
    @IBOutlet weak var avatarInterlocutor: UIImageView! {
        didSet {
            avatarInterlocutor.isUserInteractionEnabled = true
            let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapAvatar))
            doubleTapRecognizer.numberOfTapsRequired = 2
            if #available(iOS 13.4, *) {
                doubleTapRecognizer.buttonMaskRequired = .primary
            }
            avatarInterlocutor.addGestureRecognizer(doubleTapRecognizer)
        }
    }
    @IBOutlet weak var nameInterlocutor: UILabel!
    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var lastMessageViw: UIView!
    @IBOutlet weak var unreadCountView: UIView!
    @IBOutlet weak var unreadLabel: UILabel!
    // MARK: Online
    @IBOutlet weak var onlineImageView: UIImageView!
    //
    @IBOutlet weak var messageTimeLabel: UILabel!
    @IBOutlet weak var typingView: UIView!
    @IBOutlet weak var typingLabel: UILabel!
    @IBOutlet weak var messageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var unreadInView: UIView!
    @IBOutlet weak var messageTextPaddingContraint: NSLayoutConstraint!
    @IBOutlet weak var nameInterlocutorPaddingConstraint: NSLayoutConstraint!
    @IBOutlet weak var animationTyping: AnimationView!
    var rippleTouchController: MDCRippleTouchController?
    var interlocutorText = NSAttributedString(string: "")
    var conversation: Conversation?
    weak var delegate: MessageViewCellDelegate?
    var nameButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        return button
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.avatarInterlocutor.drawBorder(28, width: 0.5, color: .adaptableDivider, isOnlyTopCorners: false)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameInterlocutor.text = nil
        nameInterlocutor.attributedText = nil
        messageText.text = nil
        messageText.attributedText = nil
        unreadLabel.text = nil
        avatarInterlocutor.image = nil
        onlineImageView.image = nil
    }
    
    func alternativeSetup(conversation: Conversation) {
        self.conversation = conversation
        setupLayer()
        switch conversation.type {
        case "user":
            setupUserInterlocutor(conversation)
        case "group":
            setupGroupInterlocutor(conversation)
        case "chat":
            setupChatInterlocutor(conversation)
        default:
            break
        }
        setupconversation(conversation)
        setupUnreadMessage(conversation)
    }
    
    // Настройка графики
    func setupLayer() {
        self.backgroundColor = .adaptableWhite
        self.typingView.isHidden = true
        self.avatarInterlocutor.setRounded()
        self.avatarInterlocutor.backgroundColor = .adaptablePostColor
        self.avatarInterlocutor.drawBorder(28, width: 0.5, color: .adaptableDivider, isOnlyTopCorners: false)
        self.unreadCountView.setRounded()
        self.unreadLabel.textColor = .systemBlue
        self.unreadLabel.font = GoogleSansFont.medium(with: 13)
        self.unreadInView.backgroundColor = .systemBlue
        self.unreadInView.setRounded()
        self.nameInterlocutor.textColor = .adaptableTextPrimaryColor
        self.nameInterlocutor.font = GoogleSansFont.bold(with: 18)
        self.messageText.font = GoogleSansFont.regular(with: 16)
        self.messageText.textColor = UIColor.color(from: 0x6D7885)
        self.messageTimeLabel.font = GoogleSansFont.regular(with: 14)
        self.messageTimeLabel.textColor = UIColor.color(from: 0x99A2AD)
        self.typingView.backgroundColor = .adaptableWhite
        self.typingView.backgroundColor = .clear
        self.typingLabel.font = GoogleSansFont.medium(with: 14)
        self.typingLabel.textColor = .adaptableDarkGrayVK
    }

    // Установка последнего сообщения
    func setupconversation(_ conversation: Conversation) {
        animationTyping.contentMode = .scaleAspectFit
        animationTyping.loopMode = .loop
        animationTyping.animationSpeed = 1
        animationTyping.animation = Lottie.Animation.named("typing")
        typingLabel.attributedText = NSAttributedString(string: "печатает")
        if conversation.isTyping {
            animationTyping.play()
            typingView.isHidden = false
            lastMessageViw.isHidden = true
        } else {
            animationTyping.stop()
            typingView.isHidden = true
            lastMessageViw.isHidden = false
        }
        if conversation.interlocutor?.isOnline ?? false {
            onlineImageView.isHidden = false
            if conversation.interlocutor?.isMobile ?? false {
                self.onlineImageView.image = UIImage(named: "Online Mobile")
//                switch ApplicationOnline.getApp(by: conversation.onlinePlatform) {
//                case .vkExtended:
//                    self.onlineImageView.image = UIImage(named: "Extended")
//                case .vkMe:
//                    self.onlineImageView.image = UIImage(named: "Extended")
//                case .android:
//                    self.onlineImageView.image = UIImage(named: "Android")
//                case .iPhone:
//                    self.onlineImageView.image = UIImage(named: "Apple")
//                case .unknown:
//                    self.onlineImageView.image = UIImage(named: "Online Mobile")
//                }
            } else {
                self.onlineImageView.image = UIImage(named: "Online")
            }
        } else {
            onlineImageView.isHidden = true
        }
        self.setupDifferenceTime(at: conversation.lastMessage?.dateInteger ?? 0)
        self.setRemoveAttrs(removingFlag: conversation.removingFlag)
        self.messageText.attributedText = self.setAttrText(with: conversation)
        messageText.sizeToFit()
    }
    
    func setupDifferenceTime(at messageTime: Int) {
        let currentTime = Date()
        let timeInterval = currentTime.timeIntervalSince1970
        let doubleTimeInterval = Double(timeInterval)
        let differenceTimes = doubleTimeInterval - Double(messageTime)
        let formatter = DateComponentsFormatter()
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ru_RU_POSIX")
        formatter.calendar = calendar
        let formattedString: String

        if differenceTimes < 60 {
            formatter.allowedUnits = []
            formatter.unitsStyle = .brief
            formattedString = formatter.string(from: TimeInterval(differenceTimes))!
            messageTimeLabel.text = ""
            messageTimeLabel.sizeToFit()
            return
        } else if differenceTimes > 60 && differenceTimes < 3600 {
            formatter.allowedUnits = [.minute]
            formatter.unitsStyle = .brief
            formattedString = formatter.string(from: TimeInterval(differenceTimes))!
            messageTimeLabel.text = "· \(formattedString)"
            messageTimeLabel.sizeToFit()
            return
        } else if differenceTimes > 3600 && differenceTimes < 86400 {
            formatter.allowedUnits = [.hour]
            formatter.unitsStyle = .brief
            formattedString = formatter.string(from: TimeInterval(differenceTimes))!
            messageTimeLabel.text = "· \(formattedString)"
            messageTimeLabel.sizeToFit()
            return
        } else if differenceTimes > 86400 && differenceTimes < 604800 {
            formatter.allowedUnits = [.day]
            formatter.unitsStyle = .short
            formattedString = formatter.string(from: TimeInterval(differenceTimes))!
            messageTimeLabel.text = "· \(formattedString)"
            messageTimeLabel.sizeToFit()
            return
        } else if differenceTimes > 604800 && differenceTimes < 2419200 {
            formatter.allowedUnits = [.weekOfMonth]
            formatter.unitsStyle = .brief
            formattedString = formatter.string(from: TimeInterval(differenceTimes))!
            messageTimeLabel.text = "· \(formattedString)"
            return
        } else if differenceTimes > 2419200 {
            formatter.allowedUnits = [.month]
            formatter.unitsStyle = .short
            formattedString = formatter.string(from: TimeInterval(differenceTimes))!
            messageTimeLabel.text = "· \(formattedString)"
            messageTimeLabel.sizeToFit()
            return
        } else {
            formatter.allowedUnits = [.month, .day, .year]
            formatter.unitsStyle = .short
            formattedString = formatter.string(from: TimeInterval(differenceTimes))!
            messageTimeLabel.text = "· \(formattedString)"
            messageTimeLabel.sizeToFit()
            return
        }
    }
    
    func setAttrText(with conversation: Conversation) -> NSAttributedString? {
        var senderText: NSAttributedString
        switch ConversationPeerType.get(by: conversation.type) {
        case .user, .group:
            senderText = NSAttributedString(string: conversation.isOutgoing ? "Вы: " : "", attributes: [.foregroundColor: UIColor.color(from: 0x99A2AD), .font: GoogleSansFont.regular(with: 16)])
            return setupLastMessage(by: conversation, with: senderText)
        case .chat:
            senderText = NSAttributedString(string: conversation.isOutgoing ? "Вы: " : "\(conversation.interlocutor?.senderName ?? ""): ", attributes: [.foregroundColor: UIColor.color(from: 0x99A2AD), .font: GoogleSansFont.regular(with: 16)])
            if conversation.lastMessage?.actionType != "" {
                return senderText + NSAttributedString(string: conversation.lastMessage?.actionType ?? MessageAction.unknown.rawValue)
            } else {
                return setupLastMessage(by: conversation, with: senderText)
            }
        }
    }
    
    func setupLastMessage(by conversation: Conversation, with sender: NSAttributedString) -> NSAttributedString {
        guard let lastMessage = conversation.lastMessage else { return NSAttributedString(string: "") }
        if lastMessage.hasForwardedMessages {
            let forwardedMessages = "\(lastMessage.forwardMessagesCount) \(getStringByDeclension(number: lastMessage.forwardMessagesCount, arrayWords: Localization.instance.forwardString))"
            let forwardedMessagesText = NSAttributedString(string: forwardedMessages, attributes: [.foregroundColor: UIColor.systemBlue, .font: GoogleSansFont.regular(with: 16)])
            return lastMessage.text != "" ? sender + NSAttributedString(string: "\(lastMessage.text) ") + forwardedMessagesText : sender + forwardedMessagesText
        } else if lastMessage.hasReplyMessage {
            let replyMessageText = NSAttributedString(string: "Ответ", attributes: [.foregroundColor: UIColor.systemBlue, .font: GoogleSansFont.regular(with: 16)])
            return lastMessage.text != "" ? sender + NSAttributedString(string: "\(lastMessage.text) ")  + replyMessageText : sender + replyMessageText
        } else if lastMessage.hasAttachments {
            let attachmentText = NSAttributedString(string: lastMessage.attachmentType, attributes: [.foregroundColor: UIColor.systemBlue, .font: GoogleSansFont.regular(with: 16)])
            return lastMessage.text != "" ? sender + NSAttributedString(string: "\(lastMessage.text) ")  + attachmentText : sender + attachmentText
        } else {
            return sender + NSAttributedString(string: lastMessage.text) + NSAttributedString(string: "")
        }
    }
    
    // Установка атрибутов удаления
    func setRemoveAttrs(removingFlag: Int) {
        if removingFlag > 0 {
            messageText.textColor = .extendedRed
        }
    }
    
    // Установка непрочитанного сообщения
    func setupUnreadMessage(_ conversation: Conversation) {
        if conversation.isMuted {
            self.unreadLabel.textColor = .adaptableWhite
            self.unreadInView.backgroundColor = .adaptableDarkGrayVK
            self.unreadCountView.backgroundColor = .adaptableDarkGrayVK
            self.unreadCountView.setBorder(self.unreadCountView.roundedSize, width: 0, color: .adaptableDarkGrayVK)
        } else {
            self.unreadLabel.textColor = .adaptableWhite
            self.unreadInView.backgroundColor = UIColor.systemBlue
            self.unreadCountView.backgroundColor = UIColor.systemBlue
            self.unreadCountView.setBorder(self.unreadCountView.roundedSize, width: 0, color: UIColor.systemBlue)
            self.nameInterlocutor.attributedText = nameInterlocutor.attributedText
        }
        // Установка состояния сообщения
        switch conversation.unreadStatus {
        case .markedUnread:
            messageTextPaddingContraint.constant = "\(conversation.unreadCount)".width(with: 24, font: GoogleSansFont.regular(with: 16)) + 48
            nameInterlocutorPaddingConstraint.constant = "\(conversation.unreadCount)".width(with: 24, font: GoogleSansFont.regular(with: 16)) + 48
            unreadCountView.isHidden = false
            unreadInView.isHidden = true
            unreadLabel.text = " "
            unreadLabel.sizeToFit()
        case .unreadIn:
            messageTextPaddingContraint.constant = "\(conversation.unreadCount)".width(with: 24, font: GoogleSansFont.regular(with: 16)) + 48
            nameInterlocutorPaddingConstraint.constant = "\(conversation.unreadCount)".width(with: 24, font: GoogleSansFont.regular(with: 16)) + 48
            unreadCountView.isHidden = false
            unreadInView.isHidden = true
            unreadLabel.text = "\(conversation.unreadCount.k)"
            unreadLabel.sizeToFit()
        case .unreadOut:
            unreadCountView.isHidden = true
            unreadInView.isHidden = false
            messageTextPaddingContraint.constant = 30
            nameInterlocutorPaddingConstraint.constant = 30
        case .read:
            unreadInView.isHidden = true
            unreadCountView.isHidden = true
            unreadLabel.text = ""
            messageTextPaddingContraint.constant = 16
            nameInterlocutorPaddingConstraint.constant = 16
        }
    }
    
    func setupUserInterlocutor(_ conversation: Conversation) {
        if conversation.isImportantDialog {
            nameInterlocutor.attributedText = setLabelImage(image: "favorite_24")! + NSAttributedString(string: "\(conversation.interlocutor?.name ?? "") ")
        } else {
            nameInterlocutor.attributedText = NSAttributedString(string: "\(conversation.interlocutor?.name ?? "") ")
        }
        if Constants.verifyingProfile(from: conversation.interlocutor?.id ?? 0) || conversation.interlocutor?.verified == 1 {
            nameInterlocutor.attributedText = nameInterlocutor.attributedText! + setLabelImage(image: "done_16")!
        } else {
            nameInterlocutor.attributedText = nameInterlocutor.attributedText
        }
        if conversation.isMuted {
            self.nameInterlocutor.attributedText = nameInterlocutor.attributedText! + setLabelImage(image: "muted_16")!
        } else {
            self.nameInterlocutor.attributedText = nameInterlocutor.attributedText
        }
        if conversation.aggressiveTypingType == "text" {
            self.nameInterlocutor.attributedText = setLabelImage(image: "write_24")! + NSAttributedString(string: " ") + self.nameInterlocutor.attributedText!
        } else if conversation.aggressiveTypingType == "audioMessage" {
            self.nameInterlocutor.attributedText = setLabelImage(image: "music_mic_24")! + NSAttributedString(string: " ") + self.nameInterlocutor.attributedText!
        }
        guard let photo100 = conversation.interlocutor?.photo100, photo100 != "" else { return }
        if photo100.contains("vk.com/images/camera_") {
            self.avatarInterlocutor.image = nil
            self.avatarInterlocutor.backgroundColor = .systemBlue
        } else {
            KingfisherManager.shared.retrieveImage(with: URL(string: conversation.interlocutor?.photo100 ?? "")!, options: nil, progressBlock: nil) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    DispatchQueue.main.async {
                        self.avatarInterlocutor.image = value.image
                    }
                case .failure(let error):
                    print(error.failureReason ?? error.localizedDescription)
                }
            }
        }
    }
    
    func setupGroupInterlocutor(_ conversation: Conversation) {
        if conversation.isImportantDialog {
            nameInterlocutor.attributedText = setLabelImage(image: "favorite_24")! + NSAttributedString(string: "\(conversation.interlocutor?.name ?? "") ")
        } else {
            nameInterlocutor.attributedText = NSAttributedString(string: "\(conversation.interlocutor?.name ?? "") ")
        }
        if Constants.verifyingProfile(from: conversation.interlocutor?.id ?? 0) || conversation.interlocutor?.verified == 1 {
            nameInterlocutor.attributedText = nameInterlocutor.attributedText! + setLabelImage(image: "done_16")!
        } else {
            nameInterlocutor.attributedText = nameInterlocutor.attributedText
        }
        if conversation.isMuted {
            self.nameInterlocutor.attributedText = nameInterlocutor.attributedText! + setLabelImage(image: "muted_16")!
        } else {
            self.nameInterlocutor.attributedText = nameInterlocutor.attributedText
        }
        if conversation.aggressiveTypingType == "text" {
            self.nameInterlocutor.attributedText = setLabelImage(image: "write_24")! + NSAttributedString(string: " ") + self.nameInterlocutor.attributedText!
        } else if conversation.aggressiveTypingType == "audioMessage" {
            self.nameInterlocutor.attributedText = setLabelImage(image: "music_mic_24")! + NSAttributedString(string: " ") + self.nameInterlocutor.attributedText!
        }
        guard let photo100 = conversation.interlocutor?.photo100, photo100 != "" else { return }
        if photo100.contains("vk.com/images/camera_") {
            let lastIndex: Int = Int(String("\(conversation.peerId)".last ?? "0")) ?? 0
            Conversation.getAvatarAcronymColor(at: lastIndex) { [weak self] (gradient) in
                guard let self = self else { return }
                self.avatarInterlocutor.image = nil
                self.avatarInterlocutor.backgroundColor = .systemBlue
            }
        } else {
            KingfisherManager.shared.retrieveImage(with: URL(string: conversation.interlocutor?.photo100 ?? "")!, options: nil, progressBlock: nil) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    DispatchQueue.main.async {
                        self.avatarInterlocutor.image = value.image
                    }
                case .failure(let error):
                    print(error.failureReason ?? error.localizedDescription)
                }
            }
        }
    }
    
    func setupChatInterlocutor(_ conversation: Conversation) {
        if conversation.isImportantDialog {
            nameInterlocutor.attributedText = setLabelImage(image: "favorite_24")! + NSAttributedString(string: "\(conversation.interlocutor?.name ?? "") ")
        } else {
            nameInterlocutor.attributedText = NSAttributedString(string: "\(conversation.interlocutor?.name ?? "") ")
        }
        if Constants.verifyingChat(from: conversation.interlocutor?.name ?? "") {
            nameInterlocutor.attributedText = nameInterlocutor.attributedText! + setLabelImage(image: "done_16")!
        } else {
            nameInterlocutor.attributedText = nameInterlocutor.attributedText
        }
        if conversation.isMuted {
            self.nameInterlocutor.attributedText = self.nameInterlocutor.attributedText! + setLabelImage(image: "muted_16")!
        } else {
            self.nameInterlocutor.attributedText = self.nameInterlocutor.attributedText
        }

        if conversation.aggressiveTypingType == "text" {
            self.nameInterlocutor.attributedText = setLabelImage(image: "write_24")! + NSAttributedString(string: " ") + self.nameInterlocutor.attributedText!
        } else if conversation.aggressiveTypingType == "audioMessage" {
            self.nameInterlocutor.attributedText = setLabelImage(image: "music_mic_24")! + NSAttributedString(string: " ") + self.nameInterlocutor.attributedText!
        }
        guard let photo100 = conversation.interlocutor?.photo100 else { return }
        if photo100 == "" {
            let lastIndex: Int = Int(String("\(conversation.peerId)".last ?? "0")) ?? 0
            Conversation.getAvatarAcronymColor(at: lastIndex) { [weak self] (gradient) in
                guard let self = self else { return }
                self.avatarInterlocutor.image = nil
                self.avatarInterlocutor.backgroundColor = .systemBlue
            }
        } else {
            KingfisherManager.shared.retrieveImage(with: URL(string: conversation.interlocutor?.photo100 ?? "")!, options: nil, progressBlock: nil) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    DispatchQueue.main.async {
                        self.avatarInterlocutor.image = value.image
                    }
                case .failure(let error):
                    print(error.failureReason ?? error.localizedDescription)
                }
            }
        }
    }
    
    @objc func onTapAvatar() {
        guard let conversation = conversation, conversation.type == "user" else { return }
        delegate?.didTapAvatar(cell: self, with: conversation.peerId)
    }
}
func setLabelImage(image: String) -> NSMutableAttributedString? {
    let imageAttachment = NSTextAttachment()
    if image == "online_mobile_composite_foreground_20" {
        imageAttachment.image = UIImage(named: image)?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableGrayVK)?.resize(toWidth: 9)?.resize(toHeight: 14)
    } else if image == "done_16" || image == "logo_vkme_16" {
        imageAttachment.image = UIImage(named: image)?.withRenderingMode(.alwaysTemplate).tint(with: .systemBlue)
    } else if image == "favorite_24" || image == "flash_16" {
        imageAttachment.image = UIImage(named: image)?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableOrange)?.resize(toWidth: 16)?.resize(toHeight: 16)
    } else {
        imageAttachment.image = UIImage(named: image)
    }
    // Set bound to reposition
    if image == "online_mobile_composite_foreground_20" {
        imageAttachment.bounds = CGRect(x: 0, y: 0, width: 7, height: 12)
    } else if image == "verified_16" {
        imageAttachment.bounds = CGRect(x: 0, y: -2, width: 16, height: 16)
    } else if image == "flash_16" {
        imageAttachment.bounds = CGRect(x: -5, y: -3, width: 16, height: 16)
    } else if image == "favorite_24" {
        imageAttachment.bounds = CGRect(x: -4, y: -2, width: 16, height: 16)
    } else if image == "download_outline_16" {
        imageAttachment.bounds = CGRect(x: 0, y: -3, width: 16, height: 16)
    } else {
        imageAttachment.bounds = CGRect(x: 0, y: 0, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
    }
    // Create string with attachment
    let attachmentString = NSAttributedString(attachment: imageAttachment)
    // Initialize mutable string
    let completeText = NSMutableAttributedString(string: " ")
    // Add image to mutable string
    completeText.append(attachmentString)
    
    return completeText
}
