//
//  DropdownSelectionView.swift
//  MyVehicle
//
//  Created by Shilei Mao on 29/10/2021.
//

import SwiftUI

/// Display as a dropdown view with options provided, when user selected a value, update the binding variable with the value selected
struct DropdownSelectionView<RowContent: View, T: Identifiable>: View {
    @Binding var selectedValue: T?
    @Binding var isPresenting: Bool
    
    private var data: [T]
    private var rowBuilder: (_ item: T) -> RowContent
    private var selectionEvent: ((_ value: T) -> Void)?
    
    init(isPresenting: Binding<Bool>, value: Binding<T?>, data: [T], @ViewBuilder row: @escaping (_ item: T) -> RowContent, selectionEvent: ((_ value: T) -> Void)? = nil) {
        self._isPresenting = isPresenting
        self._selectedValue = value
        self.data = data
        self.rowBuilder = row
        self.selectionEvent = selectionEvent
    }
    
    var body: some View {
        List {
            ForEach(data) { item in
                ZStack(alignment: .leading) {
                    rowBuilder(item)
                        .onTapGesture {
                            self.selectedValue = item
                            self.isPresenting = false
                            self.selectionEvent?(item)
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .background(self.selectedValue?.id == item.id ? Color(UIColor.lightGray) : Color.clear)
            }
        }
    }
}

struct DropdownSelectionView_Previews: PreviewProvider {
    struct Friends: Identifiable {
        var id: String
        var name: String
        
        static var bob = Friends.init(id: "1", name: "Bob")
        static var alice = Friends(id: "2", name: "Alice")
        static var tom = Friends(id: "3", name: "Tom")
        static var jerry = Friends(id: "4", name: "Jerry")
        
        static var allFriends: [Friends] {
            return [.bob, .alice, .tom, .jerry]
        }
    }
    static var previews: some View {
        let values = Friends.allFriends
        let value = Friends.bob
        
        DropdownSelectionView(isPresenting: .constant(true), value: .constant(value), data: values) { item in
            Text(item.name)
        }
    }
}
