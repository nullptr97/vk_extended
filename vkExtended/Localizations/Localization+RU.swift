//
//  Localization+RU.swift
//  VKExt
//
//  Created by programmist_NA on 22.05.2020.
//

import Foundation
import UIKit

class Localization: NSObject {
    static let instance: Localization = Localization()
    
    let freindsString: [String?] = ["друг", "друга", "друзей", nil]
    let followersString: [String?] = ["подписчик", "подписчика", "подписчиков", nil]
    let membersString: [String?] = ["участник", "участника", "участников", nil]
    let pagesString: [String?] = ["интересная страница", "интересных страницы", "интересных страницы", nil]
    let attachmentsString: [String?] = ["вложение", "вложения", "вложений", nil]
    let docsString: [String?] = ["документ", "документа", "документов", nil]
    let forwardString: [String?] = ["пересланное сообщение", "пересланных сообщения", "пересланных сообщений", nil]
    
    let wallsCount: [String?] = ["запись", "записи", "записей", nil]
    let commentsCount: [String?] = ["комментарий", "комментария", "комментариев", nil]
    let friendsCount: [String?] = ["друг", "друга", "друзей", nil]
    let searchedCount: [String?] = ["человек найден", "человека найдено", "человек найден", nil]
    let photosCount: [String?] = ["фотография", "фотографии", "фотографий", nil]
    let messagesCount: [String?] = ["cообщение", "cообщения", "cообщений", nil]
    let newMessagesCount: [String?] = ["новое cообщение", "новых cообщения", "новых cообщений", nil]
    let privateConversationsCount: [String?] = ["приватный чат", "приватных чата", "приватных чатов", nil]
}

enum ErrorLocalize: String {
    /// Auth Error
    case authorizationDenied = "Вы не авторизованы"
    /// URL Request error
    case urlRequestError = "Ошибка соединения"
    /// Common errors
    case error1 = "Произошла неизвестная ошибка"
    case error2 = "Приложение выключено"
    case error3 = "Передан неизвестный метод"
    case error4 = "Неверная подпись"
    case error5 = "Авторизация пользователя не удалась"
    case error6 = "Слишком много запросов в секунду"
    case error7 = "Нет прав для выполнения этого действия"
    case error8 = "Неверный запрос"
    case error9 = "Слишком много однотипных действий"
    case error10 = "Произошла внутренняя ошибка сервера"
    case error11 = "В тестовом режиме приложение должно быть выключено или пользователь должен быть залогинен"
    case error14 = "Требуется ввод кода с картинки (Captcha)"
    case error15 = "Доступ запрещён"
    case error16 = "Требуется выполнение запросов по протоколу HTTPS"
    case error17 = "Требуется валидация пользователя"
    case error18 = "Страница удалена или заблокирован"
    case error20 = "Данное действие запрещено для не Standalone приложений"
    case error21 = "Данное действие разрешено только для Standalone и Open API приложений"
    case error23 = "Метод был выключен"
    case error24 = "Требуется подтверждение со стороны пользователя"
    case error27 = "Ключ доступа сообщества недействителен"
    case error28 = "Ключ доступа приложения недействителен"
    case error29 = "Достигнут количественный лимит на вызов метода"
    case error30 = "Профиль является приватным"
    case error33 = "Еще не реализовано"
    case error100 = "Один из необходимых параметров был не передан или неверен"
    case error101 = "Неверный API ID приложения"
    case error113 = "Неверный идентификатор пользователя"
    case error150 = "Неверная отметка времени"
    case error200 = "Доступ к альбому запрещён"
    case error201 = "Доступ к аудио запрещён"
    case error203 = "Доступ к группе запрещён"
    case error300 = "Альбом переполнен"
    case error500 = "Действие запрещено. Вы должны включить переводы голосов в настройках приложения"
    case error600 = "Нет прав на выполнение данных операций с рекламным кабинетом"
    case error603 = "Произошла ошибка при работе с рекламным кабинетом"
    case error3300 = "Требуется рекапча"
    case error3301 = "Требуется подтверждение телефона"
    case error3302 = "Требуется подтверждение пароля"
    case error3303 = "Требуется проверка приложения Otp"
    case error3304 = "Требуется подтверждение по электронной почте"
    case error3305 = "Утвердить голоса"
    case error3609 = "Требуется расширение токена"
    /// Conctere Api errors
    case error900 = "Нельзя отправлять сообщение пользователю из черного списка"
    case error901 = "Пользователь запретил отправку сообщений от имени сообщества"
    case error902 = "Нельзя отправлять сообщения этому пользователю в связи с настройками приватности"
    case error911 = "Неверный формат клавиатуры"
    case error912 = "Это функция чат-бота, измените этот статус в настройках"
    case error913 = "Слишком много пересланных сообщений"
    case error914 = "Сообщение слишком длинное"
    case error917 = "У вас нет доступа к этому чату"
    case error921 = "Невозможно переслать выбранные сообщения"
    case error936 = "Слишком много постов в сообщениях"
    case error940 = "Контакт не найден"
    case error943 = "Не могу использовать это намерение"
    case error944 = "Ограничение переполнения для этого намерения"
    case error10000 = "Некорректный JSON"
}
struct Errors {
    static func getError(at errorCode: Int) -> ErrorLocalize {
        switch errorCode {
        case -1:
            return .authorizationDenied
        case 0:
            return .urlRequestError
        case 1:
            return .error1
        case 2:
            return .error2
        case 3:
            return .error3
        case 4:
            return .error4
        case 5:
            return .error5
        case 6:
            return .error6
        case 7:
            return .error7
        case 8:
            return .error8
        case 9:
            return .error9
        case 10:
            return .error10
        case 11:
            return .error11
        case 14:
            return .error14
        case 15:
            return .error15
        case 16:
            return .error16
        case 17:
            return .error17
        case 18:
            return .error18
        case 20:
            return .error20
        case 21:
            return .error21
        case 23:
            return .error23
        case 24:
            return .error24
        case 27:
            return .error27
        case 28:
            return .error28
        case 29:
            return .error29
        case 30:
            return .error30
        case 33:
            return .error33
        case 100:
            return .error100
        case 101:
            return .error101
        case 113:
            return .error113
        case 150:
            return .error150
        case 200:
            return .error200
        case 201:
            return .error201
        case 203:
            return .error203
        case 300:
            return .error300
        case 500:
            return .error500
        case 600:
            return .error600
        case 603:
            return .error603
        case 3300:
            return .error3300
        case 3301:
            return .error3301
        case 3302:
            return .error3302
        case 3303:
            return .error3303
        case 3304:
            return .error3304
        case 3305:
            return .error3305
        case 3609:
            return .error3609
        case 900:
            return .error900
        case 901:
            return .error901
        case 902:
            return .error902
        case 911:
            return .error911
        case 912:
            return .error912
        case 913:
            return .error913
        case 914:
            return .error914
        case 917:
            return .error917
        case 921:
            return .error921
        case 936:
            return .error936
        case 940:
            return .error940
        case 943:
            return .error943
        case 944:
            return .error944
        default:
            return .error1
        }
    }
}
