//
//  SensorDetailsView.swift
//  MyVehicle
//
//  Created by Shilei Mao on 29/10/2021.
//

import SwiftUI
import CoreData

struct SensorDetailsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isPresented: Bool
    
    // state varaibles for updating sensor values
    @State private var isModifing: Bool = false
    @State private var propertyName: String = ""
    @State private var userInputValue: String = ""
    @State private var allowEmpty: Bool = false
    @State private var updateValue: ((_ sensor: Sensor, _ value: String) -> Void)?
    
    // selecting sensor type view
    @State private var isShowingSelection: Bool = false
    
    // error message to display if there is something went wrong
    @State private var isErrorHappend: Bool = false
    @State private var errorMessage: String = ""
    
    // cached sensor informations
    @State private var sensorName: String?
    @State private var sensorType: SensorType?
    @State private var serialNumber: String?
    @State private var macAddress: String?
    @State private var sensorLocation: Int64
    @State private var sensorZone: Int64
    
    // show save button to allow user to apply changes
    @State private var showSave: Bool = false
    
    var sensor: Sensor
    
    init(sensor: Sensor, isPresented: Binding<Bool>) {
        self.sensor = sensor
        
        // initialise the sensor details cache
        self.sensorName = sensor.sensorName
        self.sensorType = SensorType(rawValue: sensor.sensorType)
        self.serialNumber = sensor.serialNumber
        self.macAddress = sensor.macAddress
        self.sensorLocation = sensor.sensorLocation
        self.sensorZone = sensor.sensorZone
        
        self._isPresented = isPresented
    }
    
    var body: some View {
        List {
            Group {
                SensorDetailRow(item: sensor) { item in
                    VStack(alignment: .leading) {
                        Text("Name:")
                        sensorName.map(Text.init(_: ))
                    }
                } editCallback: { item in
                    
                    self.propertyName = getPropertyName(keypath: \Sensor.sensorName)
                    self.userInputValue = sensorName ?? ""
                    self.allowEmpty = false
                    self.updateValue = { sensor, value in
                        self.sensorName = value
                    }
                    self.isModifing = true
                }

                
                SensorDetailRow(item: sensor) { item in
                    VStack(alignment: .leading) {
                        Text("Sensor Type:")
                        self.sensorType.map {
                            Text($0.toReadableString())
                        }
                    }
                } editCallback: { item in
                    self.isShowingSelection = true
                }

                
                SensorDetailRow(item: sensor) { item in
                    Text("Serial Number:")
                    self.serialNumber.map(Text.init(_: ))
                } editCallback: { item in
                    self.propertyName = getPropertyName(keypath: \Sensor.serialNumber)
                    self.userInputValue = serialNumber ?? ""
                    self.allowEmpty = false
                    self.updateValue = { sensor, value in
                        self.serialNumber = value
                    }
                    self.isModifing = true
                }
                
                SensorDetailRow(item: sensor, content: { item in
                    VStack(alignment: .leading) {
                        Text("MAC Address:")
                        self.macAddress.map(Text.init(_: ))
                    }
                }, editCallback: { item in
                    self.propertyName = getPropertyName(keypath: \Sensor.macAddress)
                    self.userInputValue = macAddress ?? ""
                    self.allowEmpty = false
                    self.updateValue = { sensor, value in
                        self.macAddress = value
                    }
                    self.isModifing = true
                })
                
                SensorDetailRow(item: sensor) { item in
                    VStack(alignment: .leading) {
                        Text("Sensor Location:")
                        Text("\(sensorLocation)")
                    }
                } editCallback: { item in
                    self.propertyName = getPropertyName(keypath: \Sensor.sensorLocation)
                    self.userInputValue = "\(sensorLocation)"
                    self.allowEmpty = false
                    self.updateValue = { sensor, value in
                        guard let location = Int64(value) else {
                            self.isErrorHappend = true
                            self.errorMessage = "Error, the value is not valid integer string: \(value)"
                            return
                        }
                        self.sensorLocation = location
                    }
                    
                    self.isModifing = true
                }
                
                SensorDetailRow(item: sensor) { item in
                    VStack(alignment: .leading) {
                        Text("Sensor Zone:")
                        Text("\(sensorZone)")
                    }
                } editCallback: { item in
                    self.propertyName = getPropertyName(keypath: \Sensor.sensorZone)
                    self.userInputValue = "\(sensorZone)"
                    self.allowEmpty = false
                    self.updateValue = { sensor, value in
                        guard let zone = Int64(value) else {
                            self.isErrorHappend = true
                            self.errorMessage = "Error, the value is not valid integer string: \(value)"
                            return
                        }
                        self.sensorZone = zone
                    }
                    
                    self.isModifing = true
                }

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .toolbar {
            if showSave {
                Button("Save") {
                    saveDetails()
                }
                .accentColor(Color.blue)
            }
        }
        // show error dialog if there is something went wrong
        .modalView(isPresented: $isErrorHappend, modalBody: {
            VStack(spacing: 10) {
                Text("Error")
                    .font(Font.body.bold())
                
                Text(errorMessage)
                
                Button.init("OK") {
                    self.isErrorHappend = false
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        })
        // show a modal view to handle user input, then update the value into core data
        .modalView(isPresented: $isModifing) {
            InputValueView(isPresented: $isModifing,
                           title: "Enter Your value for : \(propertyName)",
                           message: "Enter Your Value",
                           initialValue: userInputValue) { value in
                defer {
                    self.userInputValue = ""
                    self.updateValue = nil
                }

                if !self.allowEmpty, value.trimmingCharacters(in: .whitespaces).isEmpty {
                    self.isErrorHappend = true
                    self.errorMessage = "Error, the value should not be empty: "
                    return
                }
                self.updateValue?(sensor, value)

                // show save option
                self.showSave = true
            }
            
            /*
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Enter Your value for : \(propertyName)")
                        .font(Font.body.bold())
                    
                    TextField("Enter Your Value", text: $userInputValue) { _ in
                        print("Text changed: \(userInputValue)")
                    }
                    .textFieldStyle(.roundedBorder)
                }
                
                Button.init("OK") {
                    defer {
                        self.isModifing = false
                        self.userInputValue = ""
                        self.updateValue = nil
                    }
                    
                    // look for empty input
                    if !self.allowEmpty, userInputValue.trimmingCharacters(in: .whitespaces).isEmpty {
                        self.isErrorHappend = true
                        self.errorMessage = "Error, the value should not be empty: "
                        return
                    }
                    self.updateValue?(sensor, userInputValue)
                    
                    // show save option
                    self.showSave = true
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            */
        }
        // show drop down selection
        .modalView(isPresented: $isShowingSelection) {
            DropdownSelectionView(isPresenting: self.$isShowingSelection, value: $sensorType, data: SensorType.allCases) { item in
                Text(item.toReadableString())
            } selectionEvent: { value in
                self.sensorType = value
                
                // show save option
                self.showSave = true
            }
            .frame(height: 200, alignment: .center)
        }
    }
    
    func getPropertyName<Root, Value>(keypath: KeyPath<Root, Value>) -> String {
        let propertyName = NSExpression(forKeyPath: keypath).keyPath
        return propertyName
    }
    
    func saveDetails() {
        do {
            // store the sensor cache into database
            sensor.sensorName = self.sensorName
            
            if let sensorType = self.sensorType {
                sensor.sensorType = sensorType.rawValue
            }
            sensor.serialNumber = self.serialNumber
            sensor.macAddress = self.macAddress
            sensor.sensorLocation = self.sensorLocation
            sensor.sensorZone = self.sensorZone
            
            try self.viewContext.save()
            
            self.isPresented = false
            self.showSave = false
        } catch let error {
            self.isErrorHappend = true
            self.errorMessage = error.localizedDescription
        }
    }
}
