//
//  KeyboardView.swift
//  MyRPN
//
//  Created by fujioka on 2022/02/11.
//

import SwiftUI

struct KeyboardView: View {
    @EnvironmentObject private var rpnData: RPNData
    @Environment(\.editMode) var editMode

    func move(from source: IndexSet, to destination: Int) {
        rpnData.stackNumbers.move(fromOffsets: source, toOffset: destination)
    }
    func delete(from source: IndexSet?) {
        rpnData.stackNumbers.remove(atOffsets: source!)
    }

    var body: some View {
        VStack {
            HStack {
                VStack {
                    MySymbol(systemName: "questionmark", height: 27, color: Color.gray, cornerRadius: 5, handler: {
                        
                    })
                    .padding(.bottom, 3)
                    MySymbol(systemName: "airplane", height: 27, color: Color.gray,
                             cornerRadius: 5, handler: {
                        
                    })
                        .padding(.bottom, 3)
                    MySymbol(systemName: "building.2", height: 27, color: Color.gray,
                             cornerRadius: 5, handler: {
                        rpnData.tsubo()
                    })
                    .padding(.bottom, 3)
                    MySymbol(systemName: "yensign.square", height: 27, color: Color.gray,
                             cornerRadius: 5, handler: {
                        rpnData.tax()
                    })
                        .padding(.bottom, 3)
                    MySymbol(systemName: "arrow.turn.right.up", height: 140, color: Color.green, handler: {
                        rpnData.enter()
                    })
                        .padding(.bottom, 3)
                }
                VStack {
                    HStack {
                        MyButton(title: "7", handler: {
                            rpnData.number("7")})
                            .padding(.bottom, 3)
                        MyButton(title: "8", handler: {
                            rpnData.number("8")})
                            .padding(.bottom, 3)
                        MyButton(title: "9", handler: {
                            rpnData.number("9")})
                            .padding(.bottom, 3)
                    }
                    HStack {
                        MyButton(title: "4", handler: {
                            rpnData.number("4")})
                            .padding(.bottom, 3)
                        MyButton(title: "5", handler: {
                            rpnData.number("5")})
                            .padding(.bottom, 3)
                        MyButton(title: "6", handler: {
                            rpnData.number("6")})
                            .padding(.bottom, 3)
                    }
                    HStack {
                        MyButton(title: "1", handler: {
                            rpnData.number("1")})
                            .padding(.bottom, 3)
                        MyButton(title: "2", handler: {
                            rpnData.number("2")})
                            .padding(.bottom, 3)
                        MyButton(title: "3", handler: {
                            rpnData.number("3")})
                            .padding(.bottom, 3)
                    }
                    HStack {
                        MyButton(title: "0", handler: {
                            rpnData.number("0")})
                            .padding(.bottom, 3)
                        MyButton(title: "00", handler: {
                            rpnData.number("00")})
                            .padding(.bottom, 3)
                        MyButton(title: ".", handler: {
                            rpnData.dot()
                        })
                            .padding(.bottom, 3)

                    }
                }
                VStack {
                    MyButton(title: "÷", color: Color.orange, handler: {
                        rpnData.fourOperate("/")
                    })
                        .padding(.bottom, 3)
                    MyButton(title: "×", color: Color.orange, handler: {
                        rpnData.fourOperate("*")
                    })
                        .padding(.bottom, 3)
                    MyButton(title: "-", color: Color.orange, handler: {
                        rpnData.fourOperate("-")
                    })
                        .padding(.bottom, 3)
                    MyButton(title: "+", color: Color.orange, handler: {
                        rpnData.fourOperate("+")
                    })
                        .padding(.bottom, 3)
                }
            }
            HStack {
                MySymbol(systemName: "arrow.left.and.right", color: Color.gray, handler: {
                    rpnData.xy_trade()
                })
                    .padding(.bottom, 3)
                MySymbol(systemName: "delete.left", color: Color.gray, handler: {
                    rpnData.deleteLeft()

                })
                    .padding(.bottom, 3)
                MySymbol(systemName: "arrowtriangle.down", color: Color.gray, handler: {
                    rpnData.drop()
                })
                    .padding(.bottom, 3)
                MySymbol(label: "AC", systemName: "clear", width: 140, color: Color.pink, handler: {
                    rpnData.allClear()
                })
                    .padding(.bottom, 3)
            }
        }
    }
}
struct MyButton: View {
    var title: String
    var width: CGFloat = 65
    var height: CGFloat = 65
    var color: Color = Color("DarkGray")
    var pressedColor: Color = .white
    var cornerRadius: CGFloat = 10
    var handler: () -> Void
        
    var body: some View {
        Button(title) {
            self.handler()
        }
        .buttonStyle(CustomButtonStyle(height: height, width: width, color: color, pressedColor: pressedColor, cornerRadius: cornerRadius))
    }
}
struct MySymbol: View {
    var label: String?
    var systemName: String
    var width: CGFloat = 65
    var height: CGFloat = 65
    var color: Color = Color("DarkGray")
    var pressedColor: Color = .white
    var cornerRadius: CGFloat = 10
    var handler: () -> Void
        
    var body: some View {
        Button(action: handler){
            if label != nil {
                Label(label!, systemImage: systemName)
//                Image(systemName: systemName)
//                Text(label!)
            } else {
            Image(systemName: systemName)
                
            }
        }
        .buttonStyle(CustomButtonStyle(height: height, width: width, color: color, pressedColor: pressedColor, cornerRadius: cornerRadius))
    }
}
struct CustomButtonStyle: ButtonStyle {
    var height: CGFloat = 65
    var width: CGFloat = 65
    var color: Color = Color("DarkGray")
    var pressedColor: Color = .white
    var cornerRadius: CGFloat = 10
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .frame(width: width, height: height)
            .foregroundColor(Color.white)
            .background(configuration.isPressed ? pressedColor : color )
            .cornerRadius(cornerRadius)
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
            if editMode?.wrappedValue.isEditing == true {
                editMode?.wrappedValue = .inactive
            } else {
                editMode?.wrappedValue = .active
            }
            if rpnData.stackNumbers.count == 0 {
                generator.notificationOccurred(.warning)
            }
        }) {
            if editMode?.wrappedValue.isEditing == true {
                Image(systemName: "checkmark")
            } else {
                Image(systemName: "pencil")
            }
        }
    }
}

struct KeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
