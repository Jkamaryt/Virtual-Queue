//
//  AddView.swift
//  Computer Science Queue
//
//  Created by Jack Kamaryt on 3/3/23.
//

import SwiftUI

struct AddView: View {
    @State private var name: String = ""
    @State private var notes: String = ""
    @State private var colorPicker = ""
    static let colorPicker = ["Green", "Yellow", "Red"]
    var body: some View {
        NavigationView{
            VStack{
                Text("Add Name")
                    .padding()
                
                Form{
                    VStack{
                        HStack{
                            Text("Name:")
                            TextField("(name)",text: $name)
                        }
                        Picker("Color:", selection: $colorPicker){
                            ForEach(Self.colorPicker, id: \.self) { color in
                                Text(color)
                            }
                        }
                        .pickerStyle(.segmented)
                        TextField("(notes:)",text: $notes)
                       // Button("Add")
                    }
                }
                Spacer()
            }
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView()
    }
}
