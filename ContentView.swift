//
//  ContentView.swift
//  MyRPN
//
//  Created by fujioka on 2021/12/27.
//

import SwiftUI
let generator = UINotificationFeedbackGenerator()


struct ContentView: View {
//    @Environment(\.editMode) var editMode

    @ObservedObject var rpnData = RPNData()




    var body: some View {
        VStack {
            HStack {
                Spacer()
//                Text("\(rpnData.enterringString):\(rpnData.stackNumbers.debugDescription):\(rpnData.newEnterring.description)")
                MyEditButton().environmentObject(rpnData)
                    .padding()
            }
            Spacer()
            DisplayView().environmentObject(rpnData)
            //常にeditMode
            //.environment(\.editMode, .constant(EditMode.active))
            KeyboardView().environmentObject(rpnData)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDevice("iPhone 11")
        }
    }
}
