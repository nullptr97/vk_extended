//
//  TestingViewController.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 08.12.2020.
//

import UIKit
import MaterialComponents
import Alamofire
import SwiftyJSON
import Material

class TestingViewController: BaseViewController {

    @IBOutlet weak var methodCategoryTextField: MDCBaseTextField!
    @IBOutlet weak var methodTextField: MDCBaseTextField!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var resultTextView: TextView!
    
    var selectedCategory: String?
    var categoryList = ["account", "actionLinks", "ads", "adsint", "apps", "appWidgets", "articles", "audio", "auth", "board", "bugtracker", "catalog", "database", "docs", "donut", "execute", "fave", "friends", "gifts", "groups", "identity", "internal", "likes", "market", "masks", "messages", "money", "narratives", "newsfeed", "notes", "notifications", "orders", "photos", "places", "podcasts", "polls", "reports", "search", "settings", "shortVideo", "specials", "stats", "statEvents", "status", "storage", "store", "stories", "superApp", "tags", "textlives", "video", "users", "utils", "vkRun", "wall", "wishlists"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitle = "Для разработчиков"
        navigationSubtitle = "Тестовая проверка API"
        //setupStatusView()
        
        createPickerView()
        dismissPickerView()
        
        resultTextView.drawBorder(8, width: 0.5, color: .adaptableDivider)
        methodTextField.drawBorder(12, width: 0.5, color: .adaptableDivider)
        methodCategoryTextField.drawBorder(12, width: 0.5, color: .adaptableDivider)
        
        resultTextView.textColor = .getThemeableColor(fromNormalColor: .black)
        methodTextField.textColor = .getThemeableColor(fromNormalColor: .black)
        methodCategoryTextField.textColor = .getThemeableColor(fromNormalColor: .black)
        
        resultTextView.placeholderLabel.textColor = .adaptableDivider
        resultTextView.placeholderLabel.text = "Здесь будет выводиться результат запроса"
    }
    
    @IBAction func checkMethod(_ sender: Any) {
        guard let token = VK.sessions.default.accessToken?.token else {
            self.resultTextView.text = "User authorization failed: no access_token passed"
            return
        }
        guard !methodTextField.isEmpty else {
            self.resultTextView.text = "input method"
            return
        }
        var parameters: Alamofire.Parameters = [:]
        
        let request = Alamofire.request(apiUrl + methodCategoryTextField.text! + "." + methodTextField.text!, method: .get, parameters: Api.getParameters(method: methodTextField.text!, &parameters, token), encoding: URLEncoding.default, headers: userAgent)
        
        request.downloadProgress(queue: .main, closure: { (progress) in
            print("progess!", "\(progress.fractionCompleted * 100)% completed")
        })
        
        request.responseData().done { [weak self] data in
            guard let self = self else { return }
            if ApiError(JSON(data.data)) != nil {
                self.resultTextView.textColor = .extendedBackgroundRed
            } else {
                self.resultTextView.textColor = .getThemeableColor(fromNormalColor: .black)
            }
            self.resultTextView.text = data.data.prettyJson
        }.catch { [weak self] error in
            guard let self = self else { return }
            self.resultTextView.text = error.localizedDescription
        }
        methodTextField.resignFirstResponder()
    }
    
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        methodCategoryTextField.inputView = pickerView
    }

    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Выбрать", style: .plain, target: self, action: #selector(self.action))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        methodCategoryTextField.inputAccessoryView = toolBar
    }

    @objc func action() {
        view.endEditing(true)
    }
}
extension TestingViewController: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        createPickerView()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryList.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var categoty = categoryList[row]
        categoty.firstCharacterUppercased()
        return categoty
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categoryList[row]
        methodCategoryTextField.text = selectedCategory
    }
}
extension Data {
    var prettyJson: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding:.utf8) else { return nil }

        return prettyPrintedString
    }
}
