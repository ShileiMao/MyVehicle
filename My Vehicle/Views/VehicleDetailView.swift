//
//  VehicleDetailView.swift
//  MyVehicle
//
//  Created by Shilei Mao on 28/10/2021.
//

import SwiftUI

struct VehicleDetailView: View {
    @Binding var vehicle: Vehicle
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var sensors: [Sensor] = []
    
    // error alert temp
    @State private var isErrorHappend: Bool = false
    @State private var error: Error?
    
    // confirmation alert temp
    @State private var isShowingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var alertCallback: ((_ confirmed: Bool) -> Void)?
    
    @State private var isShowingSensorDetails: Bool = false
    
    var body: some View {
        List {
            Group {
                VStack(alignment: .leading) {
                    Text("Name:")
                    vehicle.name.map(Text.init(_: ))
                }
                
                VStack(alignment: .leading) {
                    Text("ID:")
                    vehicle.vehicleID.map(Text.init(_: ))
                }
                
                VStack(alignment: .leading) {
                    Text("Reefer Serial:")
                    vehicle.reeferSerial.map(Text.init(_: ))
                }
                
                VStack(alignment: .leading) {
                    Text("Mobile Number:")
                    vehicle.mobileNumber.map(Text.init(_: ))
                }
                
                VStack(alignment: .leading) {
                    Text("Customer:")
                    vehicle.customer.map(Text.init(_: ))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
                .frame(height: 20)

            ForEach(sensors, id: \.self) { sensor in  
                NavigationLink {
                    SensorDetailsView(sensor: sensor, isPresented: $isShowingSensorDetails)
                        .environment(\.managedObjectContext, viewContext)
                } label: {
                    VStack(alignment: .leading) {
                        sensor.sensorName.map(Text.init(_: ))

                        SensorType(rawValue: sensor.sensorType).map {
                            Text($0.toReadableString())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .onDelete(perform: deleteSensor(offsets:))
        }
        .onAppear {
            loadSensors()
        }
        .modalView(isPresented: $isShowingAlert) {
            VStack(spacing: 10) {
                Text("Info")
                    .font(Font.body.bold())
                
                Text(alertMessage)
                
                HStack(spacing: 10) {
                    Button.init("OK") {
                        self.isShowingAlert = false
                        self.alertCallback?(true)
                    }
                    
                    Button.init("Cancel") {
                        self.isShowingAlert = false
                        self.alertCallback?(false)
                    }
                }
                
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .modalView(isPresented: $isErrorHappend) {
            VStack(spacing: 10) {
                Text("Error")
                    .font(Font.body.bold())
                
                if let string = self.error?.localizedDescription {
                    Text(string)
                }
                
                Button.init("OK") {
                    self.isErrorHappend = false
                }
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    /// Load sensors associated to that vehicle
    func loadSensors() {
        if let sensors = vehicle.vehicleSensors as? Set<Sensor> {
            self.sensors = Array.init(sensors).sorted(by: { sensor1, sensor2 in
                guard let name1 = sensor1.sensorName, let name2 = sensor2.sensorName else {
                    return false
                }
                return name1 > name2
            })
        }
    }
    
    private func deleteSensor(offsets: IndexSet) {
        self.isShowingAlert = true
        self.alertMessage = "Are you sure want to delete the sensor?"
        self.alertCallback = { confirmed in
            if confirmed {
                withAnimation {
                    offsets.map { index -> Sensor in
                        let sensor = sensors[index]
                        sensors.remove(at: index)
                        return sensor
                    }
                    .forEach(viewContext.delete)
                    
                    do {
                        try viewContext.save()
                    } catch let error {
                        self.isErrorHappend = true
                        self.error = error
                    }
                }
            }
        }
    }
}
