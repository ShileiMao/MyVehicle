//
//  SensorDetailRow.swift
//  MyVehicle
//
//  Created by Shilei Mao on 29/10/2021.
//

import SwiftUI

struct SensorDetailRow<T: Any, Content: View>: View {
    private var editCallback: ((_ item: T) -> Void)?
    private var item: T
    private var content: Content

    init(item: T, @ViewBuilder content: (_ item: T) -> Content, editCallback: ((_ item: T) -> Void)?) {
        self.item = item
        self.editCallback = editCallback
        self.content = content(item)
    }
    
    var body: some View {
        HStack {
            content
            
            Spacer()
            
            Button("Edit") {
                editCallback?(item)
            }
        }
    }
}
