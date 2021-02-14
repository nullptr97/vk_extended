//
//  ConversationTableViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 09.01.2021.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarInterlocutor: UIImageView!
    @IBOutlet weak var nameInterlocutor: UILabel!
    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var unreadCountView: UIView!
    @IBOutlet weak var unreadLabel: UILabel!
    // MARK: Online
    @IBOutlet weak var onlineImageView: UIImageView!
    //
    @IBOutlet weak var messageTimeLabel: UILabel!
    @IBOutlet weak var unreadInView: UIView!
    @IBOutlet weak var messagePaddingConstraint: NSLayoutConstraint!
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        avatarInterlocutor.drawBorder(26, width: 0.5, color: .getThemeableColor(fromNormalColor: .lightGray))
    }
    
    func alternativeSetup(conversation: Conversation) {
        setupLayer()
        setupInterlocutor(conversation)
        setupConversation(conversation)
        setupUnreadMessage(conversation)
    }
    
    // Настройка графики
    func setupLayer() {
        backgroundColor = .getThemeableColor(fromNormalColor: .white)
        avatarInterlocutor.setRounded()
        avatarInterlocutor.backgroundColor = .adaptablePostColor
        avatarInterlocutor.drawBorder(26, width: 0.5, color: .getThemeableColor(fromNormalColor: .lightGray))
        unreadCountView.setRounded()
        unreadLabel.textColor = .white
        unreadLabel.font = GoogleSansFont.medium(with: 12)
        unreadInView.backgroundColor = .getAccentColor(fromType: .common)
        unreadInView.setRounded()
        nameInterlocutor.textColor = .adaptableTextPrimaryColor
        nameInterlocutor.font = GoogleSansFont.bold(with: 17)
        messageText.font = GoogleSansFont.regular(with: 16)
        messageText.textColor = UIColor.color(from: 0x6D7885)
        messageTimeLabel.font = GoogleSansFont.regular(with: 12)
        messageTimeLabel.textColor = UIColor.color(from: 0x99A2AD)
    }

    // Установка последнего сообщения
    func setupConversation(_ conversation: Conversation) {
        if conversation.isTyping {
            nameInterlocutor.attributedText = nameInterlocutor.attributedText! + attributedSpace + setLabelImage(image: "write_24")!
        } else {
            nameInterlocutor.attributedText = nameInterlocutor.attributedText
        }
        if conversation.interlocutor?.isOnline ?? false {
            onlineImageView.isHidden = false
            if conversation.interlocutor?.isMobile ?? false {
                onlineImageView.image = UIImage(named: "Online Mobile")
            } else {
                onlineImageView.image = UIImage(named: "Online")
            }
        } else {
            onlineImageView.isHidden = true
        }
        configureLastMessage(with: conversation.removingFlag, from: conversation.lastMessage?.text)
        messageText.attributedText = setAttrText(with: conversation)
        setupDifferenceTime(at: conversation.lastMessage?.dateInteger ?? 0)
    }
    
    func setupDifferenceTime(at messageTime: Int) {
        let messageDate = StdService.instance.messageDate(with: Date(timeIntervalSince1970: messageTime.double))
        messageTimeLabel.text = messageDate.string(from: Date(timeIntervalSince1970: messageTime.double))
        messageTimeLabel.sizeToFit()
    }
    
    func setAttrText(with conversation: Conversation) -> NSAttributedString? {
        var senderText: NSAttributedString
        switch conversation.conversationType {
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
        guard conversation.removingFlag == 0 else { return NSAttributedString(string: "Сообщение удалено") }

        let text = (lastMessage.text.isEmpty && !lastMessage.hasForwardedMessages && !lastMessage.hasReplyMessage && !lastMessage.hasAttachments) ? "Пустое сообщение" : lastMessage.text.replacingOccurrences(of: " \n", with: " ")
        if lastMessage.hasForwardedMessages {
            let forwardedMessages = "\(lastMessage.forwardMessagesCount) \(getStringByDeclension(number: lastMessage.forwardMessagesCount, arrayWords: Localization.forwardString))"
            let forwardedMessagesText = NSAttributedString(string: forwardedMessages, attributes: [.foregroundColor: UIColor.getAccentColor(fromType: .common), .font: GoogleSansFont.regular(with: 16)])
            return text != "" ? sender + NSAttributedString(string: "\(text) ") + forwardedMessagesText : sender + forwardedMessagesText
        } else if lastMessage.hasReplyMessage {
            let replyMessageText = NSAttributedString(string: "Ответ", attributes: [.foregroundColor: UIColor.getAccentColor(fromType: .common), .font: GoogleSansFont.regular(with: 16)])
            return text != "" ? sender + NSAttributedString(string: "\(text) ") + replyMessageText : sender + replyMessageText
        } else if lastMessage.hasAttachments {
            let attachmentText = NSAttributedString(string: lastMessage.attachmentType, attributes: [.foregroundColor: UIColor.getAccentColor(fromType: .common), .font: GoogleSansFont.regular(with: 16)])
            return text != "" ? sender + NSAttributedString(string: "\(text) ") + attachmentText : sender + attachmentText
        } else {
            return sender + NSAttributedString(string: text) + NSAttributedString(string: "")
        }
    }
    
    // Замена последнего удаленого сообщения
    func configureLastMessage(with removedFlag: Int = 0, from text: String?) {
        messageText.font = removedFlag > 0 ? GoogleSansFont.italic(with: 16) : GoogleSansFont.regular(with: 16)
    }
    
    // Установка атрибутов удаления
    @available(iOS, deprecated: 12, renamed: "configureLastMessage")
    func setRemoveAttrs(removingFlag: Int) {
        if removingFlag > 0 {
            messageText.textColor = .extendedBackgroundRed
        }
    }
    
    // Установка непрочитанного сообщения
    func setupUnreadMessage(_ conversation: Conversation) {
        if conversation.isMuted {
            unreadInView.backgroundColor = .getThemeableColor(fromNormalColor: .darkGray)
            unreadCountView.backgroundColor = .getThemeableColor(fromNormalColor: .darkGray)
            unreadCountView.setBorder(unreadCountView.roundedSize, width: 0, color: .adaptableDarkGrayVK)
        } else {
            unreadInView.backgroundColor = .getAccentColor(fromType: .common)
            unreadCountView.backgroundColor = .getAccentColor(fromType: .common)
            unreadCountView.setBorder(unreadCountView.roundedSize, width: 0, color: UIColor.getAccentColor(fromType: .common))
            nameInterlocutor.attributedText = nameInterlocutor.attributedText
        }
        // Установка состояния сообщения
        switch conversation.unreadStatus {
        case .markedUnread:
            avatarInterlocutor.removeWrapper()
            unreadCountView.isHidden = false
            unreadInView.isHidden = true
            unreadLabel.text = " "
            unreadLabel.sizeToFit()
            messagePaddingConstraint.constant = "\(conversation.unreadCount)".width(with: 24, font: GoogleSansFont.regular(with: 16)) + 48
        case .unreadIn:
            avatarInterlocutor.addWrapper(from: 2.5)
            unreadCountView.isHidden = false
            unreadInView.isHidden = true
            unreadLabel.text = "\(conversation.unreadCount.k)"
            unreadLabel.sizeToFit()
            messagePaddingConstraint.constant = "\(conversation.unreadCount)".width(with: 24, font: GoogleSansFont.regular(with: 16)) + 48
        case .unreadOut:
            avatarInterlocutor.removeWrapper()
            unreadCountView.isHidden = true
            unreadInView.isHidden = false
            messagePaddingConstraint.constant = 30
        case .read:
            avatarInterlocutor.removeWrapper()
            unreadInView.isHidden = true
            unreadCountView.isHidden = true
            unreadLabel.text = ""
            messagePaddingConstraint.constant = 16
        }
    }
    
    func setupInterlocutor(_ conversation: Conversation) {
        var originPadding: CGFloat = 0
        nameInterlocutor.attributedText = NSAttributedString(string: "\(conversation.interlocutor?.name ?? "") ")
        if Constants.verifyingProfile(from: conversation.interlocutor?.id ?? 0) || conversation.interlocutor?.verified == 1 {
            originPadding = 8
            nameInterlocutor.attributedText = getAttributedStringWithImage(string: nameInterlocutor.attributedText, rect: nameInterlocutor.frame.size, font: GoogleSansFont.bold(with: 17), imageName: "verified_16", imageOrigin: CGPoint(x: originPadding, y: 0))
        } else {
            originPadding = 0
            nameInterlocutor.attributedText = nameInterlocutor.attributedText
        }
        nameInterlocutor.sizeToFit()
        if conversation.isMuted {
            originPadding = 12
            nameInterlocutor.attributedText = getAttributedStringWithImage(string: nameInterlocutor.attributedText, rect: nameInterlocutor.frame.size, font: GoogleSansFont.bold(with: 17), imageName: "muted_16", imageOrigin: CGPoint(x: originPadding, y: 0))
        } else {
            originPadding = 0
            nameInterlocutor.attributedText = nameInterlocutor.attributedText
        }
        nameInterlocutor.sizeToFit()
        if conversation.isImportantDialog {
            nameInterlocutor.attributedText = setLabelImage(image: "favorite_24")! + nameInterlocutor.attributedText!
        } else {
            nameInterlocutor.attributedText = nameInterlocutor.attributedText
        }
        nameInterlocutor.sizeToFit()
        guard let photo100 = conversation.interlocutor?.photo100, let url = URL(string: photo100) else { return }
        avatarInterlocutor.kf.setImage(with: url)
    }

    private func getAttributedStringWithImage(string: NSAttributedString?, rect: CGSize, font: UIFont, imageName: String, imageOrigin: CGPoint) -> NSAttributedString {
        
        // creating image to append at the end of the string
        let icon = NSTextAttachment()
        
        if imageName == "verified_16" {
            icon.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common))
        } else if imageName == "write_24" {
            icon.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate).tint(with: .getThemeableColor(fromNormalColor: .darkGray))?.resize(toWidth: 12)?.resize(toHeight: 12)
        } else {
            icon.image = UIImage(named: imageName)
        }
        
        if imageName == "verified_16" {
            icon.bounds = CGRect(x: 0, y: -2, width: 16, height: 16)
        } else if imageName == "write_24" {
            icon.bounds = CGRect(x: -4, y: 0, width: 10, height: 10)
        }
        
        let iconString = NSAttributedString(attachment: icon)
        
        // we will calculate the "attributed string length with image at the end" to deside whether we need to truncate
        // the string to append the image or not by looping the string
        var newStr = ""
        guard let attrString = string else {
            return NSMutableAttributedString(string: newStr, attributes: [.font: font])
        }
        let mutableAttrString = NSMutableAttributedString(attributedString: attrString)
        for char in mutableAttrString.string {
            newStr += String(char)
            
            let attStr = NSMutableAttributedString(string: (newStr), attributes: [.font: font])
            let stringRect = attStr.boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: rect.height), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)

            if stringRect.width.rounded() + icon.bounds.width.rounded() + imageOrigin.x - 12 > rect.width.rounded() {
                newStr += "... "
                break
            }
        }
        
        let titleString = NSMutableAttributedString(string: newStr, attributes: [.font: font])
        
        for imageAttach in mutableAttrString.getParts() {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = imageAttach
            
            if imageAttach.width == 16 && imageAttach.height == 16 {
                imageAttachment.bounds = CGRect(x: 0, y: -2, width: 16, height: 16)
            }
            
            titleString.append(NSAttributedString(attachment: imageAttachment))
        }
        
        titleString.append(iconString)
        
        return titleString
    }
}
extension NSMutableAttributedString {
    func getParts() -> [UIImage] {
        var parts = [UIImage]()

        let range = NSMakeRange(0, length)
        enumerateAttributes(in: range, options: NSAttributedString.EnumerationOptions(rawValue: 0)) { (object, range, stop) in
            if object.keys.contains(.attachment) {
                if let attachment = object[.attachment] as? NSTextAttachment {
                    if let image = attachment.image, image != UIImage(named: "favorite_24") {
                        parts.append(image)
                    } else if let image = attachment.image(forBounds: attachment.bounds, textContainer: nil, characterIndex: range.location) {
                        parts.append(image)
                    }
                }
            }
        }
        return parts
    }
}
