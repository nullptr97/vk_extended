//
//  Attachments.swift
//  VK Tosters
//
//  Created by programmist_np on 31/01/2020.
//  Copyright © 2020 programmist_np. All rights reserved.
//

import Foundation
import SwiftyJSON
import Kingfisher
import RealmSwift

enum MessageAttachmentType: String {
    case photo = "Фото"
    case video = "Видео"
    case audio = "Аудио"
    case audio_message = "Голосовое сообщение"
    case doc = "Документ"
    case link = "Ссылка"
    case market = "Товар"
    case market_album = "Подборка товаров"
    case wall = "Запись"
    case wall_reply = "Комментарий"
    case sticker = "Стикер"
    case gift = "Подарок"
    case graffity = "Граффити"
    case call = "Звонок"
    case unknown = "Неизвестное вложение"
    case none = ""
}
