//
//  VehicleList.swift
//  MyVehicle
//
//  Created by Shilei Mao on 28/10/2021.
//

import SwiftUI
import CoreData

struct VehicleList: View {
    private static let VEHICLE_UPDATED = "VehicleListUpdated"
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Vehicle.vehicleID, ascending: true)], animation: nil)
    private var vehicles: FetchedResults<Vehicle>
    
    @State var isError: Bool = false
    @State var error: Error?

    var body: some View {
        NavigationView {
            List {
                ForEach(vehicles) { item in
                    NavigationLink {
                        VehicleDetailView(vehicle: .constant(item))
                            .environment(\.managedObjectContext, viewContext)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                item.name.map {
                                    Text($0)
                                }
                                
                                item.vehicleID.map(Text.init(_:))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(alignment: .trailing) {
                                item.customer.map(Text.init(_: ))?
                                .font(Font.system(size: 15))
                                
                                item.mobileNumber.map(Text.init(_: ))
                                    .font(Font.system(size: 15))
                            }
                            .frame(alignment: .trailing)
                        }
                    }

                }
                //.onDelete(perform: deleteItems)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .toolbar {
                Button("Reload Vehicles") {
                    UserDefaults.standard.removeObject(forKey: VehicleList.VEHICLE_UPDATED)
                    self.refreshVehicleInfo()
                }
                .accentColor(Color.blue)
            }
//            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
/** for iOS 15 only
        .alert("Error", isPresented: $isError, actions: {
            Button("OK") {
                self.isError = false
            }
        }, message: {
            Text("Error Occurred while refreshing vehicle details: \n\(error?.localizedDescription ?? "Unkown Error")")
        })
 */
        .modalView(isPresented: $isError, modalBody: {
            VStack {
                Text("Error")
                    .fontWeight(.bold)
                
                Text("Error Occurred while refreshing vehicle details: \n\(error?.localizedDescription ?? "Unkown Error")")
                    .foregroundColor(.gray)
                
                Button("OK") {
                    self.isError = false
                }
            }
            .frame(minWidth: 200, minHeight: 200)
        })
        .onAppear {
            refreshVehicleInfo()
        }
    }
    
    
    func refreshVehicleInfo() {
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: VehicleList.VEHICLE_UPDATED) {
            return
        }
        userDefaults.set(true, forKey: VehicleList.VEHICLE_UPDATED)
        
        let retrieveRequest = RetrieveVehilceInfo()
        retrieveRequest.refresVehiclesFromServer(viewContext: viewContext) { success, error in
            self.isError = !success
            self.error = error
        }
    }

}


struct VehicleList_Previews: PreviewProvider {
    static var previews: some View {
        VehicleList().environment(\.managedObjectContext, PersistenceController.previewVehicle.container.viewContext)
    }
}
