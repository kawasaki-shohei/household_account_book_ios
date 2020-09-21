//
//  ViewController.swift
//  household_account_book_ios
//
//  Created by Shohei Kawasaki on 2020/09/08.
//  Copyright © 2020 Shohei Kawasaki. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var memoTextField: UITextField!
    @IBOutlet weak var submitUIButton: UIButton!
    
    //    let pairmoneyApiURL = "http://localhost:3000/"
    let pairmoneyApiURL = "https://staging-pairmoney.herokuapp.com/"
    var pickerView = UIPickerView()
    var categories = JSON()
    var categoryList = [String]()
    var datePicker: UIDatePicker = UIDatePicker()
    var submitDate = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        amountTextField.frame = CGRect(x: 20, y: view.frame.size.height - 450, width: view.frame.size.width - 50, height: view.frame.size.height * 0.05)
        
        categoryTextField.frame = CGRect(x: 20, y: view.frame.size.height - 358, width: view.frame.size.width - 50, height: view.frame.size.height * 0.05)
        
        dateTextField.frame = CGRect(x: 20, y: view.frame.size.height - 260, width: view.frame.size.width - 50, height: view.frame.size.height * 0.05)
        
        memoTextField.frame = CGRect(x: 20, y: view.frame.size.height - 165, width: view.frame.size.width - 50, height: view.frame.size.height * 0.05)
        
        submitUIButton.frame = CGRect(x: 20, y: view.frame.size.height - 100, width: view.frame.size.width - 50, height: view.frame.size.height * 0.07)
        
        amountTextField.delegate = self
        memoTextField.delegate = self
        
        //Category Picker View 設定
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        
        //カテゴリーをAPIで取得
        getCategories()
        
        // 決定バーの生成
        let categoryToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let categorySpacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cateogoryDoneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(categoryPickerDone))
        categoryToolbar.setItems([categorySpacelItem, cateogoryDoneItem], animated: true)
        
        // インプットビュー設定
        categoryTextField.inputView = pickerView
        categoryTextField.inputAccessoryView = categoryToolbar
        
        // dateTextFieldの初期値を設定
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        formatter.locale = Locale(identifier: "ja_JP")
        let now = Date()
        dateTextField.text = formatter.string(from: now)
        formatter.dateFormat = "yyyy-MM-dd"
        submitDate = formatter.string(from: now)
        
        // Date Pickerの設定
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.timeZone = NSTimeZone.local
        datePicker.locale = Locale.current
        dateTextField.inputView = datePicker
        
        // 決定バーの生成
        let DateOoolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let DateSpacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let DateDoneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(datePickerDone))
        DateOoolbar.setItems([DateSpacelItem, DateDoneItem], animated: true)
        
        // インプットビュー設定
        dateTextField.inputView = datePicker
        dateTextField.inputAccessoryView = DateOoolbar
    }
    
    func getCategories() {
        let url = pairmoneyApiURL + "api/v1/categories"
        let headers: HTTPHeaders = ["Accept": "application/json"]
        // Alamofireを使ってhttpリクエストを送る
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch(response.result){
            case .success:
                self.categories = JSON(response.data as Any)
                self.categoryTextField.text = self.categories[0]["name"].string
                print(JSON(response.data as Any))
                for i in 0...self.categories.count - 1 {
                    self.categoryList.append(self.categories[i]["name"].string!)
                }
                print(self.categoryList)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryList[row]
    }
    
    // 決定ボタン押下
    @objc func categoryPickerDone() {
        categoryTextField.endEditing(true)
        categoryTextField.text = "\(categoryList[pickerView.selectedRow(inComponent: 0)])"
    }
    
    // 決定ボタン押下
    @objc func datePickerDone() {
        dateTextField.endEditing(true)
        
        // 日付のフォーマット
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年MM月dd日"
        dateTextField.text = "\(formatter.string(from: datePicker.date))"
        

        formatter.dateFormat = "yyyy-MM-dd"
        submitDate = "\(formatter.string(from: datePicker.date))"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // returnキー押したときにキーボードを閉じる
        textField.resignFirstResponder()
        //スクロールを戻す
        view.frame.origin.y = 0
        self.view.endEditing(true)
        return true
    }
    
    func getCategoryId(categoryName: String) -> String {
        var result = String()
        for i in 0...categories.count - 1 {
            if categoryName == categories[i]["name"].string {
                result = String(categories[i]["id"].int!)
                break
            }
        }
        return result
    }
    
    //textField入力前
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //memoTextFiledの時のみ上にスクロールする
        if textField.frame.maxY > 530 {
            view.frame.origin.y -= 260
        }
        return true
    }
    
    //textField入力後
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        //スクロールを戻す
        view.frame.origin.y = 0
        return true
    }

    @IBAction func submit(_ sender: Any) {
        let url = pairmoneyApiURL + "api/v1/expenses"
        let parameters: [String: String?] = [
            "amount": amountTextField.text,
            "category_id": getCategoryId(categoryName: categoryTextField.text!),
            "date": submitDate,
            "memo": memoTextField.text!
        ]
        let headers: HTTPHeaders = ["Accept": "application/json"]
        
        AF.request(url, method: .post, parameters: parameters, headers: headers).responseJSON { (response) in
            switch(response.result){
            case .success:
                let json = JSON(response.data as Any)
                let succeeded = json["succeeded"].bool!
                let message = json["message"].string!
                if succeeded {
                    self.resultLabel.textColor = .green
                } else {
                    self.resultLabel.textColor = .red
                }
                self.resultLabel.text = message
                print(message)
            case .failure(let error):
                print(error)
            }
        }
    }
}

