//
//  ContentView.swift
//  Computer Science Queue
//
//  Created by Jack Kamaryt on 3/3/23.
//

import SwiftUI

struct ContentView: View {
    @State private var queue = [Queue]()
    @State private var showingAlert = false
    
    @State private var showingAddView = false
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            List(queue){ element in
                NavigationLink{
                    Text("Notes:")
                        .font(.title).bold()
                        .position(x:50, y:10)
                    Text(element.notes)
                        .position(x:200, y:-300)
                    
                } label: {
                    Text("\(element.position).")
                    Text(element.name)
                        .font(.none).bold()
                    Image(element.color)
                        .resizable()
                        .frame(width:15, height:15)
                }
            }
            .sheet(isPresented: $showingAddView, content: {
                AddView()})
            .navigationBarTitle("Virtual Queue", displayMode: .inline)
        }
        .task {await getData()}
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Loading Error"),
                  message: Text("There was a problem loading the Queue"),
                  dismissButton: .default(Text("OK")))
        }
    }
    func getData() async {
        let query = "https://script.google.com/macros/s/AKfycbwb77J6271EkJPKhfLk7z9r1lurnVNExbXRM6UaQ-GzX0uH1BPOcXsTZCuAvweMYu6OWQ/exec"
        if let url = URL(string: query) {
            if let (data, _) = try? await URLSession.shared.data(from: url) {
                if let decodedResponse = try? JSONDecoder().decode(Info.self, from: data) {
                    queue = decodedResponse.main
                    return
                }
            }
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Queue: Identifiable, Codable {
    var id = UUID()
    var position: Int
    var name: String
    var color: String
    var notes: String
   
    enum CodingKeys: String, CodingKey {
        case position = "Position"
        case name = "Name"
        case color = "Color"
        case notes = "Notes"
    }
}

struct Info: Codable {
    var main: [Queue]
}
