//
//  ImagePopup.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 09.12.2020.
//

import Foundation
import SwiftyJSON

struct ImagePopup {
    let popup: Popup
    let profiles: [ProfileResponse]
    
    init(imagePopup: JSON) {
        self.popup = Popup(popup: imagePopup["popup"])
        self.profiles = imagePopup["profiles"].arrayValue.compactMap { ProfileResponse(from: $0) }
    }
}

struct Popup {
    let title: String
    let text: String
    let photo: PopupPhoto
    let background: Background
    
    init(popup: JSON) {
        self.title = popup["title"].stringValue
        self.text = popup["text"].stringValue
        self.photo = PopupPhoto(photo: popup["photo"])
        self.background = Background(background: popup["background"])
    }
}

struct PopupPhoto {
    let type: String
    let images: [StatusImageData]
    
    init(photo: JSON) {
        self.type = photo["type"].stringValue
        self.images = photo["images"].arrayValue.compactMap { StatusImageData(statusImageData: $0) }
    }
}

struct Background {
    let light, dark: ColorType

    init(background: JSON) {
        self.light = ColorType(colorType: background["light"])
        self.dark = ColorType(colorType: background["dark"])
    }
}

// MARK: - ColorType
struct ColorType {
    let color: String
    let images: [StatusImageData]

    init(colorType: JSON) {
        self.color = colorType["color"].stringValue
        self.images = colorType["images"].arrayValue.compactMap { StatusImageData(statusImageData: $0) }
    }
}
