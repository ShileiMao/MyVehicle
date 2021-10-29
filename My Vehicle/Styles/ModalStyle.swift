//
//  ModalStyle.swift
//  MyVehicle
//
//  Created by Shilei Mao on 29/10/2021.
//

import SwiftUI

struct ModalStyleKey: EnvironmentKey {
    public static let defaultValue: AnyModalViewStyle = AnyModalViewStyle(DefaultModalViewStyle())
}

extension EnvironmentValues {
    var modalViewStyle: AnyModalViewStyle {
        get {
            return self[ModalStyleKey.self]
        }
        set {
            self[ModalStyleKey.self] = newValue
        }
    }
}

protocol ModalViewStyle {
    associatedtype Background: View
    associatedtype Content: View
    
    var animation: Animation? { get }
    
    /// Create background view for modal view
    /// - Returns: Background view object
    func createBackground(backgroundView: Rectangle, isPresented: Binding<Bool>) -> Background
    
    /// Create the modal view based on the ontent view provided
    /// - Returns: the foreground view to show to the end user
    func createModalView(modalView: AnyView, isPresented: Binding<Bool>) -> Content
}

extension ModalViewStyle {
    func createBackgroundAny(backgroundView: Rectangle, isPresented: Binding<Bool>) -> AnyView {
        AnyView(
            createBackground(backgroundView: backgroundView, isPresented: isPresented)
        )
    }
    
    func createModalViewAny(modalView: AnyView, isPresented: Binding<Bool>) -> AnyView {
        AnyView(
            createModalView(modalView: modalView, isPresented: isPresented)
        )
    }
}


/// Default Modal view style object
struct DefaultModalViewStyle: ModalViewStyle {
    let animation: Animation? = .easeOut(duration: 0.4)
    
    func createBackground(backgroundView: Rectangle, isPresented: Binding<Bool>) -> some View {
        backgroundView.edgesIgnoringSafeArea(.all)
            .foregroundColor(.black)
            .opacity(0.5)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .zIndex(1_000)
            .onTapGesture {
                isPresented.wrappedValue = false
            }
    }
    
    func createModalView(modalView: AnyView, isPresented: Binding<Bool>) -> some View {
        modalView
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding()
            .zIndex(1_001)
    }
}


/// A wrapper to convert any modal view style object to `AnyModalViewStyle` object, it keeps all the behaviours of the custom modal view style
struct AnyModalViewStyle: ModalViewStyle {
    let animation: Animation?
    private let _createBackground: (Rectangle, Binding<Bool>) -> AnyView
    private let _createModalView: (AnyView, Binding<Bool>) -> AnyView
    
    init<Style: ModalViewStyle>(_ style: Style) {
        self.animation = style.animation
        self._createBackground = style.createBackgroundAny
        self._createModalView = style.createModalViewAny
    }
    
    func createBackground(backgroundView: Rectangle, isPresented: Binding<Bool>) -> some View {
        return self._createBackground(backgroundView, isPresented)
    }
    
    func createModalView(modalView: AnyView, isPresented: Binding<Bool>) -> some View {
        return self._createModalView(modalView, isPresented)
    }
}
