//
//  ModalView.swift
//  MyVehicle
//
//  Created by Shilei Mao on 29/10/2021.
//

import SwiftUI

/// Crate and display a modal view, it overlaps on the parent view, when user tap outside the content view, it dismisses 
struct ModalView<ParentView: View, ContentView: View >: View {
    @Environment(\.modalViewStyle) var style: AnyModalViewStyle
    @Binding var isPresented: Bool
    
    var parentView: ParentView
    var contentView: ContentView
    
    var background: Rectangle = Rectangle()
    
    var body: some View {
        ZStack {
            parentView
            
            if isPresented {
                self.style.createBackground(backgroundView: background, isPresented: $isPresented)
                self.style.createModalView(modalView: AnyView(contentView), isPresented: $isPresented)
            }
        }
    }
    
    init(isPresented: Binding<Bool>, parent: ParentView, @ViewBuilder content: () -> ContentView) {
        self._isPresented = isPresented
        self.parentView = parent
        self.contentView = content()
    }
}
