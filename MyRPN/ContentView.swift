//
//  ContentView.swift
//  MyRPN
//
//  Created by fujioka on 2021/12/27.
//

import SwiftUI
let generator = UINotificationFeedbackGenerator()

class RPNData: ObservableObject {
    @Published var enterringString: String = ""
    @Published var stackNumbers: [Decimal] = []
    @Published var newEnterring: Bool = false
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
    func fourOperate(operateType: String) {
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

    }
    func addStack() {
        stackNumbers.insert(enterringNumber, at: 0)
    }
    func reset() {
        enterringString = ""
        stackNumbers.removeAll()
    }
    let generator = UINotificationFeedbackGenerator()
    let formatter = NumberFormatter()
    init () {
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.maximumFractionDigits = 18
        
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
}

struct ContentView: View {
    @ObservedObject var rpnData = RPNData()

    let generator = UINotificationFeedbackGenerator()
    let formatter = NumberFormatter()
    init () {
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.maximumFractionDigits = 18
        
    }
    
    func decimalDisplayString(number: Decimal) -> String {
        return formatter.string(from: number as NSDecimalNumber)!
    }

    // 数値入力
    func tapNumber(num:String) ->Void {
        // 入力文字が0が連続するのは避ける
        if rpnData.enterringString == "0" {
            if num == "0" || num == "00" {
                self.generator.notificationOccurred(.warning)
            } else {
                rpnData.enterringString = num
            }
        } else {
            if rpnData.newEnterring {
                rpnData.newEnterring = false
                rpnData.enterringString = num
            } else {
                rpnData.enterringString = rpnData.enterringString + num
            }
            
        }
    }
    // 四則演算
    func fourOperation(_ operateType: String) {
        if rpnData.fourOperatable() {
            rpnData.fourOperate(operateType: operateType)
        } else {
            self.generator.notificationOccurred(.warning)
        }
    }
    // エンター Enter
    func otherOperation(_ operateType: String) {
        switch operateType {
        case "Enter" :
            let enterringNumber = Decimal(string: rpnData.enterringString)
            // 入力がおかしい時
            if enterringNumber == nil {
                self.generator.notificationOccurred(.warning)
            } else {
                rpnData.addStack()
            }
            rpnData.newEnterring = true
        default: break
            
        }
    }
    func move(from source: IndexSet, to destination: Int) {
        rpnData.stackNumbers.move(fromOffsets: source, toOffset: destination)
    }
    func delete(from source: IndexSet?) {
        rpnData.stackNumbers.remove(atOffsets: source!)
    }
    func buildView(stackNumbers: [Decimal], index: Int) -> AnyView {
        let color:Color
        let numberString:String
        color = Color.black
        numberString = decimalDisplayString(number: stackNumbers[index])

        return AnyView(Text(numberString)
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .scaleEffect(x: 1, y: -1)
                        .foregroundColor(color)
        )
    }
    

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("\(rpnData.enterringString):\(rpnData.stackNumbers.debugDescription):\(rpnData.newEnterring.description)")
                MyEditButton().environmentObject(rpnData)
                    .padding()
            }
            Spacer()
            List {
                if rpnData.stackNumbers.count == 0 && rpnData.enterringString == "" {
                    Text("0").font(.title)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .scaleEffect(x: 1, y: -1)
                        .foregroundColor(.blue)

                } else if rpnData.enterringString != "" {
                    Text(rpnData.enterringStringWithDelimiter()).font(.title)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .scaleEffect(x: 1, y: -1)
                        .foregroundColor(Color.orange)
                }
                ForEach(Array(rpnData.stackNumbers.enumerated()), id: \.offset) { index, number in
                    self.buildView(stackNumbers: rpnData.stackNumbers, index: index)
                }.onMove(perform: move)
                .onDelete(perform: delete)

            }
            .scaleEffect(x: 1, y: -1)
            //常にeditMode
            //.environment(\.editMode, .constant(EditMode.active))
        
            HStack {
                VStack {
                    MyButton(title: "#1", color: Color.gray, handler: {
                        rpnData.stackNumbers.removeAll()
                        rpnData.enterringString = ""
                    })
                    .padding(.bottom, 3)
                    MyButton(title: "#2", color: Color.gray, handler: {
                        rpnData.enterringString = "123"
                    })
                        .padding(.bottom, 3)
                    MyButton(title: "Enter", height: 140, color: Color.green, handler: {
                        otherOperation("Enter")
                    })
                        .padding(.bottom, 3)
                }
                VStack {
                    HStack {
                        MyButton(title: "7", handler: {tapNumber(num: "7")})
                            .padding(.bottom, 3)
                        MyButton(title: "8", handler: {tapNumber(num: "8")})
                            .padding(.bottom, 3)
                        MyButton(title: "9", handler: {tapNumber(num: "9")})
                            .padding(.bottom, 3)
                    }
                    HStack {
                        MyButton(title: "4", handler: {tapNumber(num: "4")})
                            .padding(.bottom, 3)
                        MyButton(title: "5", handler: {tapNumber(num: "5")})
                            .padding(.bottom, 3)
                        MyButton(title: "6", handler: {tapNumber(num: "6")})
                            .padding(.bottom, 3)
                    }
                    HStack {
                        MyButton(title: "1", handler: {tapNumber(num: "1")})
                            .padding(.bottom, 3)
                        MyButton(title: "2", handler: {tapNumber(num: "2")})
                            .padding(.bottom, 3)
                        MyButton(title: "3", handler: {tapNumber(num: "3")})
                            .padding(.bottom, 3)
                    }
                    HStack {
                        MyButton(title: "00", handler: {tapNumber(num: "00")})
                            .padding(.bottom, 3)
                        MyButton(title: "0", handler: {tapNumber(num: "0")})
                            .padding(.bottom, 3)
                        MyButton(title: ".", handler: {
                            if rpnData.enterringString == "0" {
                                rpnData.enterringString = "0."
                            }else if (rpnData.enterringString.contains(".")){
                            }else {
                                let n = Decimal(string: rpnData.enterringString)
                                let s = formatter.string(from: n! as NSDecimalNumber)
                                rpnData.enterringString.append(".")
                                print(s!)
                            }
                            
                        })
                            .padding(.bottom, 3)

                    }
                }
                VStack {
                    MyButton(title: "÷", color: Color.orange, handler: {
                        fourOperation("/")
                    })
                        .padding(.bottom, 3)
                    MyButton(title: "×", color: Color.orange, handler: {
                        fourOperation("*")
                    })
                        .padding(.bottom, 3)
                    MyButton(title: "-", color: Color.orange, handler: {
                        fourOperation("-")
                    })
                        .padding(.bottom, 3)
                    MyButton(title: "+", color: Color.orange, handler: {
                        fourOperation("+")
                    })
                        .padding(.bottom, 3)
                }
            }
            HStack {
                MyButton(title: "X⇔Y", color: Color.gray, handler: {
                    if rpnData.enterringString != "" {
                        rpnData.addStack()
                        rpnData.enterringString = ""
                    }
                    if rpnData.stackNumbers.count > 1 {
                        let tmpNumber = rpnData.stackNumbers[0]
                        rpnData.stackNumbers[0] = rpnData.stackNumbers[1]
                        rpnData.stackNumbers[1] = tmpNumber
                    } else {
                        self.generator.notificationOccurred(.warning)
                    }
                    
                })
                    .padding(.bottom, 3)
                MyButton(title: "←", color: Color.gray, handler: {
                    if rpnData.enterringString == "" {
                        self.generator.notificationOccurred(.warning)
                    } else {
                        rpnData.enterringString = String(rpnData.enterringString.dropLast())
                    }

                })
                    .padding(.bottom, 3)
                MyButton(title: "Drop", color: Color.gray, handler: {
                    if rpnData.enterringString != "" {
                        rpnData.enterringString = ""
                    } else {
                        if rpnData.stackNumbers.count > 0 {
                            rpnData.stackNumbers.removeFirst()
                        } else {
                            rpnData.enterringString = ""
                            self.generator.notificationOccurred(.warning)
                        }
                    }
                })
                    .padding(.bottom, 3)
                MyButton(title: "AC", width: 140, color: Color.pink, handler: {
                    if rpnData.stackNumbers.count == 0 && rpnData.enterringString == "0"  {
                        self.generator.notificationOccurred(.warning)
                    }
                    rpnData.reset()
                })
                    .padding(.bottom, 3)
            }
        }
    }
}
struct MyButton: View {
    var title: String
    var width: CGFloat?
    var height: CGFloat?
    var color: Color?
    var pressedColor: Color?
    var handler: () -> Void
        
    var body: some View {
        Button(title) {
            self.handler()
        }
        .buttonStyle(CustomButtonStyle(height: height, width: width, color: color, pressedColor: pressedColor))
    }
}
struct CustomButtonStyle: ButtonStyle {
    var height: CGFloat?
    var width: CGFloat?
    var color: Color?
    var pressedColor: Color?
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(/*@START_MENU_TOKEN@*/.title2/*@END_MENU_TOKEN@*/)
            .frame(width: width ?? 65, height: height ?? 65)
            .foregroundColor(Color.white)
            .background(configuration.isPressed ? pressedColor ?? Color.white :
                            color ?? Color("DarkGray")
            )
            .cornerRadius(10)
    }
}
/// オリジナルEditButton
struct MyEditButton: View {
    @Environment(\.editMode) var editMode
    @EnvironmentObject private var rpnData: RPNData

    
    var body: some View {
        Button(action: {
            if rpnData.enterringString != "" {
                rpnData.stackNumbers.insert(Decimal(string: rpnData.enterringString)!, at: 0)
                rpnData.enterringString = ""
            }
            
            withAnimation() {
                if editMode?.wrappedValue.isEditing == true {
                    editMode?.wrappedValue = .inactive
                } else {
                    editMode?.wrappedValue = .active
                }
            }
        }) {
            if editMode?.wrappedValue.isEditing == true {
                Text("終了")
            } else {
                Text("編集")
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDevice("iPhone Xs")
        }
    }
}
