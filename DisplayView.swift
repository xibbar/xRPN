//
//  DisplayView.swift
//  xRPN
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
    private let rowHeight: CGFloat = 56
    private var estimatedListHeight: CGFloat {
        let visibleRowCount: Int
        if rpnData.stackNumbers.isEmpty && rpnData.enterringString == "" {
            visibleRowCount = 1
        } else {
            visibleRowCount = rpnData.stackNumbers.count + (rpnData.enterringString.isEmpty ? 0 : 1)
        }

        let idealHeight = CGFloat(visibleRowCount) * rowHeight
        let minimumHeight = rowHeight
        let maximumHeight: CGFloat = 320
        return min(max(idealHeight, minimumHeight), maximumHeight)
    }
    var body: some View {
        ScrollViewReader { proxy in
            List {
                if rpnData.stackNumbers.count == 0 && rpnData.enterringString == "" {
                    Text("0")
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundColor(.blue)
                } else if rpnData.enterringString != "" {
                    Text(rpnData.enterringStringWithDelimiter()).font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundColor(Color.orange)
                }
                ForEach(Array(rpnData.stackNumbers.enumerated()), id: \.offset) { index, number in
                    self.buildView(stackNumbers: rpnData.stackNumbers, index: index)
                }
                .onMove(perform: move)
                .onDelete(perform: delete)
                Color.clear
                    .frame(height: 0)
                    .id("bottom")
            }
            .listStyle(.plain)
            .frame(height: estimatedListHeight, alignment: .bottom)
            .onAppear {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: rpnData.stackNumbers) { _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: rpnData.enterringString) { _ in
                scrollToBottom(proxy: proxy)
            }
            .onTapGesture(count: 2){
                print("Long Tapped.")
                toggleEditMode()
            }
        }
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
        color = Color("DisplayLetter")
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

    private func scrollToBottom(proxy: ScrollViewProxy) {
        DispatchQueue.main.async {
            withAnimation {
                proxy.scrollTo("bottom", anchor: .bottom)
            }
        }
    }
}

struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
