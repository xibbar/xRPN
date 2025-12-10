//
//  DisplayView.swift
//  MyRPN
//
//  Created by 藤岡岳之 on 2022/01/27.
//

import SwiftUI

struct DisplayView: View {
    let generator = UINotificationFeedbackGenerator()
    let formatter = NumberFormatter()
    @EnvironmentObject private var rpnData: RPNData
    @Environment(\.editMode) var editMode
    init () {
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.maximumFractionDigits = 7
    }
    var body: some View {
        List {
            if rpnData.stackNumbers.count == 0 && rpnData.enterringString == "" {
                Text("0")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundColor(.blue)
                    .rotationEffect(Angle(degrees: 180))

                

            } else if rpnData.enterringString != "" {
                Text(rpnData.enterringStringWithDelimiter()).font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundColor(Color.orange)
                    .rotationEffect(Angle(degrees: 180))
            }
            ForEach(Array(rpnData.stackNumbers.enumerated()), id: \.offset) { index, number in
                self.buildView(stackNumbers: rpnData.stackNumbers, index: index)
            }
            .onMove(perform: move)
            .onDelete(perform: delete)
            .rotationEffect(Angle(degrees: 180))
//            .onLongPressGesture{
//                print("Long Tapped.")
//                toggleEditMode()
//            }
        }
        .onTapGesture(count: 2){
            print("Long Tapped.")
            toggleEditMode()
        }
        .rotationEffect(Angle(degrees: 180))

    }
    func toggleEditMode(){
        if editMode?.wrappedValue.isEditing == true {
            editMode?.wrappedValue = .inactive
            self.generator.notificationOccurred(.success)
            print("inactive")
        } else {
            if rpnData.stackNumbers.count < 1 {
                self.generator.notificationOccurred(.warning)
            } else if rpnData.stackNumbers.count == 1 && rpnData.enterringString == "" {
                self.generator.notificationOccurred(.warning)
            } else {
                if rpnData.enterringString != "" {
                    rpnData.addStack()
                    rpnData.enterringString = ""
                }
                editMode?.wrappedValue = .active
                print("active")
                self.generator.notificationOccurred(.success)
            }
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
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundColor(color)
        )
    }
    func decimalDisplayString(number: Decimal) -> String {
        return formatter.string(from: number as NSDecimalNumber)!
    }
}

struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
