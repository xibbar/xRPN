//
//  RPNData.swift
//  xRPN
//
//  Created by 藤岡岳之 on 2022/01/27.
//

import SwiftUI


struct RPNData_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class RPNData: ObservableObject {
    @Published var enterringString: String = ""
    @Published var stackNumbers: [Decimal] = []
    @Published var newEnterring: Bool = false
    let generator = UINotificationFeedbackGenerator()
    let formatter = NumberFormatter()
    
    init () {
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.maximumFractionDigits = 7
        
    }
    func toggleEditMode(mode:EditMode){
        print(mode.isEditing)
    }
    var enterringNumber: Decimal {
        get {
            Decimal(string: enterringString)!
        }
    }
    var formatEnterringString: String {
        get {
            enterringString
        }
    }
    func fourOperatable() ->Bool {
        if enterringString == "" {
            return stackNumbers.count > 1
        } else {
            return stackNumbers.count > 0
        }
    }
    func fourOperate(_ operateType: String) {
        if fourOperatable() {
            let tmp1:Decimal
            let tmp2:Decimal
            if enterringString == "" {
                tmp1 = stackNumbers[0]
                tmp2 = stackNumbers[1]
                stackNumbers.remove(at: 0)
            } else {
                tmp1 = enterringNumber
                tmp2 = stackNumbers[0]
            }
            switch operateType {
            case "+" :
                stackNumbers[0] = tmp2 + tmp1
            case "-" :
                stackNumbers[0] = tmp2 - tmp1
            case "/" :
                stackNumbers[0] = tmp2 / tmp1
            case "*" :
                stackNumbers[0] = tmp2 * tmp1
            default:
                break
            }
            enterringString = ""

        } else {
            self.generator.notificationOccurred(.warning)
        }

    }
    func addStack() {
        stackNumbers.insert(enterringNumber, at: 0)
    }
    func reset() {
        enterringString = ""
        stackNumbers.removeAll()
    }
    func enterringStringWithDelimiter() -> String {
        let num = enterringString
        let range = num.range(of: ".")
        if range != nil {
            let prefix = num[num.startIndex..<range!.lowerBound]
            let suffix = num[range!.upperBound...]
            return formatter.string(from: Int(prefix)! as NSNumber)!+"."+suffix
        } else {
            return formatter.string(from: Int(num)! as NSNumber)!
        }
    }
    // AC all clear
    func allClear() {
        if stackNumbers.count == 0 && enterringString == ""  {
            self.generator.notificationOccurred(.warning)
        }
        self.reset()
    }

    // 坪
    func tsubo() {
        if newEnterring {
            newEnterring = false
            enterringString = "3.305"
        }else if !enterringString.isEmpty {
            addStack()
            enterringString = "3.305"
        }else {
            enterringString = "3.305"
        }
    }
    // 税
    func tax() {
        if newEnterring {
            newEnterring = false
            enterringString = "1.1"
        }else if !enterringString.isEmpty {
            addStack()
            enterringString = "1.1"
        }else {
            enterringString = "1.1"
        }
    }
    
    // X ⇔ Y 1行目と2行目を入れ替え
    func xy_trade() {
        if enterringString != "" {
            addStack()
        }
        let tmp = stackNumbers[0]
        stackNumbers[0] = stackNumbers[1]
        stackNumbers[1] = tmp
        newEnterring = false
        enterringString = ""
    }
    
    // ドット.
    func dot() {
        if newEnterring {
            newEnterring = false
            enterringString = "0."
        }
        else if enterringString == "" {
            enterringString = "0."
        }else if (enterringString.contains(".")){
            self.generator.notificationOccurred(.warning)
        }else {
            let n = Decimal(string: enterringString)
            let s = formatter.string(from: n! as NSDecimalNumber)
            enterringString.append(".")
            print(s!)
        }
        
    }
    // エンター Enter
    func enter() {
        let enterringNumber = Decimal(string: enterringString)
        if enterringString.isEmpty && stackNumbers.count > 0{
            stackNumbers.insert(stackNumbers[0], at: 0)
            enterringString=""
            //enterringString = "\(stackNumbers[0])"
            return
        }
            
        // 入力がおかしい時
        if enterringNumber == nil {
            self.generator.notificationOccurred(.warning)
        } else {
            self.addStack()
        }
        newEnterring = true
    }
    // 数値入力
    func number(_ num:String) ->Void {
        // 入力文字が0が連続するのは避ける
        if enterringString == "0" {
            if num == "0" || num == "00" {
                self.generator.notificationOccurred(.warning)
            } else {
                enterringString = num
            }
        } else {
            if newEnterring {
                newEnterring = false
                enterringString = num
            } else {
                enterringString = enterringString + num
            }
            
        }
    }
    // １文字削除
    func deleteLeft() {
        if enterringString == "" {
            self.generator.notificationOccurred(.warning)
        } else {
            enterringString = String(enterringString.dropLast())
        }
    }
    // Drop
    func drop() {
        if enterringString != "" {
            enterringString = ""
        } else {
            if stackNumbers.count > 0 {
                stackNumbers.removeFirst()
            } else {
                enterringString = ""
                self.generator.notificationOccurred(.warning)
            }
        }
    }
}
