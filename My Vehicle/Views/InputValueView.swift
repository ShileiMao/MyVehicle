//
//  InputValueView.swift
//  MyVehicle
//
//  Created by Shilei Mao on 29/10/2021.
//

import SwiftUI

struct InputValueView: View {
    
    @Binding var isPresented: Bool
    @State var inputString: String = ""
    
    private var title: String
    private var message: String
    private var initialValue: String
    private var callback: (_ value: String) -> Void
    
    
    init(isPresented: Binding<Bool>, title: String, message: String, initialValue: String, callback: @escaping (_ value: String) -> Void) {
        self._isPresented = isPresented
        self.title = title
        self.message = message
        self.initialValue = initialValue
        self.inputString = initialValue
        self.callback = callback
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(Font.body.bold())
                
                TextField(message, text: $inputString) { _ in
                    print("Text changed: \(inputString)")
                }
                .textFieldStyle(.roundedBorder)
            }
            
            HStack(spacing: 20) {
                Button.init("OK") {
                    self.isPresented = false
                    self.callback(inputString)
                }
                
                Button("Cancel") {
                    self.isPresented = false
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
