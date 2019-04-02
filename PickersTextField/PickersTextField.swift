//
//  PickersTextField.swift
//  TapNGo Driver
//
//  Created by Admin on 04/04/18.
//  Copyright © 2018 nPlus. All rights reserved.
//

import UIKit

public class PickersTextField: UITextField {

    public enum TextfieldType
    {
        case datePicker
        case pickerView
    }
    private var currentTextfieldType:TextfieldType = .datePicker
    private let datePicker = UIDatePicker()
    private let dateFormatter = DateFormatter()
    private let pickerView = UIPickerView()
    private var pickerTitle = "- Select -"
    public var itemList = [String]()


    init(_ type:TextfieldType) {
        super.init(frame: .zero)
        self.currentTextfieldType = type
        commonInit()
    }
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    @objc func textEdited(_ sender:PickersTextField)
    {
        if self.currentTextfieldType == .datePicker
        {
            self.text = dateFormatter.string(from: datePicker.date)
        }
        else
        {
            self.text = pickerView.selectedRow(inComponent: 0) == 0 ? "" : itemList[pickerView.selectedRow(inComponent: 0)-1]
        }
    }
    @objc func editingBegin(_ sender:PickersTextField)
    {
        if self.currentTextfieldType == .datePicker
        {
            if let date = dateFormatter.date(from: self.text!)
            {
                self.datePicker.date = date
            }
            else
            {
                self.datePicker.date = Date()
                self.text = dateFormatter.string(from: self.datePicker.date)
            }
        }
    }
    func commonInit() {
        let downBtn = UIButton(type: .custom)
        downBtn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 8)
        downBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let bundle = Bundle(for: type(of: self))
        downBtn.imageView?.contentMode = .scaleAspectFit
        downBtn.setImage(UIImage(named: "down", in: bundle, compatibleWith: nil), for: .normal)
        downBtn.addTarget(self, action: #selector(becomeFirstResponder), for: .touchUpInside)
        self.rightViewMode = .always
        self.rightView = downBtn
        
        self.inputAccessoryView = KeyboardToolBar({ [weak self] in
            self?.resignFirstResponder()
        })
        self.tintColor = UIColor.clear
        self.addTarget(self, action: #selector(textEdited(_:)), for: .editingChanged)
        self.addTarget(self, action: #selector(editingBegin(_:)), for: .editingDidBegin)
        if currentTextfieldType == .datePicker
        {
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
            self.inputView = datePicker
            dateFormatter.dateFormat = "yyyy-MM-dd"
        }
        else
        {
            pickerView.delegate = self
            pickerView.dataSource = self
            self.inputView = pickerView
        }
    }
    
    @objc func dateChanged(_ sender:UIDatePicker)
    {
        self.text = dateFormatter.string(from: sender.date)
    }
    public func changeTextFieldType(_ type:TextfieldType)
    {
        self.currentTextfieldType = type
        if currentTextfieldType == .datePicker
        {
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
            self.inputView = datePicker
            dateFormatter.dateFormat = "yyyy-MM-dd"
        }
        else
        {
            pickerView.delegate = self
            pickerView.dataSource = self
            self.inputView = pickerView
        }
    }
    func configureDatePicker(_ minDate:Date?,maxDate:Date?,dateFormat:String?)
    {
        if let minDate = minDate
        {
            self.datePicker.minimumDate = minDate
        }
        if let maxDate = maxDate
        {
            self.datePicker.maximumDate = maxDate
        }
        if let dateFormat = dateFormat
        {
            dateFormatter.dateFormat = dateFormat
        }
    }

}
extension PickersTextField:UIPickerViewDelegate,UIPickerViewDataSource
{
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return itemList.count + 1
    }
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = row == 0 ?  pickerTitle : itemList[row-1]
        return NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor:row == 0 ? UIColor.gray : UIColor.black])
    }
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.text = row == 0 ? "" : itemList[row-1]
    }
}
public class KeyboardToolBar: UIToolbar {
    let done = UIButton()
    var doneBtnAction:(() -> Void)?
    
    convenience init(_ doneBtnAction: @escaping () -> Void) {
        self.init()
        self.doneBtnAction = doneBtnAction
    }
    
    private init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.gray
        self.sizeToFit()
        let flexBarBtn = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        done.frame = CGRect(x: 0, y: 0, width: 50, height: 44)
        done.setTitle("Done", for: .normal)
        done.setTitleColor(.black, for: .normal)
        done.addTarget(self, action: #selector(callbackDoneButton(_:)), for: .touchUpInside)
        let doneBarBtn = UIBarButtonItem.init(customView: done)
        self.items = [flexBarBtn,doneBarBtn]
    }
    
    @objc func callbackDoneButton(_ id:Any) -> Void {
        if let doneBtnAction = self.doneBtnAction {
            doneBtnAction()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
