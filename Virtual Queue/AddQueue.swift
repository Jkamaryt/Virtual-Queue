//
//  AddQueue.swift
//  Virtual Queue
//
//  Created by Jack Kamaryt on 3/3/23.
//

import SwiftUI

struct AddQueue: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var position: Int = 0
    @State private var name: String = ""
    @State private var notes: String = ""
    @State private var colorPicker = ""
    static let colorPicker = ["Green", "Yellow", "Red"]
    
    var body: some View {
        NavigationView{
            VStack{
                Form{
                    VStack{
                        HStack{
                            Text("Name:")
                            TextField("name",text: $name)
                                .textFieldStyle(.roundedBorder)
                        }
                        Picker("Color:", selection: $colorPicker){
                            ForEach(Self.colorPicker, id: \.self) { color in
                                Text(color)
                            }
                        }
                        .pickerStyle(.segmented)
                        HStack{
                            Text("Notes:")
                            TextField("notes",text: $notes)
                                .textFieldStyle(.roundedBorder)
                        }
                        Button("Add") {
                            Task {
                                await postData()
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                        
                    }
                }
            }
            .navigationBarBackButtonHidden(false)
            .navigationBarTitle("Add Name", displayMode: .inline)
            .navigationBarItems(leading:  Button(action: {
                presentationMode.wrappedValue.dismiss()
            } ){
                Text("Back")
            }, trailing: Text(""))
            Spacer()
        }
    }
    
    func postData() async {
        let url = URL(string: "https://script.google.com/macros/s/AKfycbyR0eAE7VjpRUmJfdMEBewckStvgCDSWHsPwCYmi4CV-929oBerQdxn_VX6nFvHNX9mDA/exec")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = ["value2": "\(name)", "value3": "\(colorPicker)", "value4": "\(notes)"]
        let jsonData = try! JSONSerialization.data(withJSONObject: data, options: [])
        request.httpBody = jsonData
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                print("Server Error")
                return
            }
            guard let data = data,
                  let jsonString = String(data: data, encoding: .utf8) else {
                print("No Data")
                return
            }
            print(jsonString)
        }
        task.resume()
    }
}

struct AddQueue_Previews: PreviewProvider {
    static var previews: some View {
        AddQueue()
    }
}
