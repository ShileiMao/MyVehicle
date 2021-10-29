//
//  ViewExtension.swift
//  MyVehicle
//
//  Created by Shilei Mao on 29/10/2021.
//

import SwiftUI

extension View {
    func modalView<ModalBody: View>(isPresented: Binding<Bool>, @ViewBuilder modalBody: () -> ModalBody) -> some View {
        ModalView(isPresented: isPresented, parent: self, content: modalBody)
    }
}

