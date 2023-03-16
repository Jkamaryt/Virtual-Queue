import SwiftUI

struct ContentView: View {
    @State private var queue = [Queue]()
    @State private var showingAlert = false
    @State private var showingAddQueue = false
    @State private var position: Int = 0
    @State private var name: String = ""
    @State private var notes: String = ""
    @State private var colorPicker = ""
    
    static let colorPicker = ["Green", "Yellow", "Red"]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(queue) { element in
                    NavigationLink {
                        Text("Notes:")
                            .font(.title)
                            .bold()
                            .position(x: 50, y: 10)
                        Text(element.notes)
                            .position(x: 200, y: -300)
                    } label: {
                        Text("\(element.position).")
                        Text(element.name)
                            .font(.none)
                            .bold()
                        Image(element.color)
                            .resizable()
                            .frame(width: 15, height: 15)
                    }
                }
                .onDelete { indexSet in
                    let rowId = queue[indexSet.first!].position
                    queue.remove(atOffsets: indexSet)
                    deleteRow(rowId: String(rowId))
                }
                
            }
            .refreshable {
                await getData()
            }
            .fullScreenCover(isPresented: $showingAddQueue, content: {
                AddQueue()
                    .onDisappear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            Task {
                                await getData()
                            }
                        }
                    }
            })
            .navigationBarTitle("Virtual Queue", displayMode: .inline)
            .navigationBarItems(leading: EditButton())
            .navigationBarItems(trailing: Button(action: {
                showingAddQueue = true
            }) {
                Image(systemName: "plus")
            })
            .onAppear {
                Task { await getData() }
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Loading Error"),
                  message: Text("There was a problem loading the Queue"),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    func getData() async {
        let query = "https://script.google.com/macros/s/AKfycbz1LYYtPmDHB8HIxcRp68QyK-POYoC58ZZe52q4AoJJrmRp2LTL0zTAiwagNET72Pbeew/exec"
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
    
    func deleteRow(rowId: String) {
        let scriptURL = "https://script.google.com/macros/s/AKfycbz1LYYtPmDHB8HIxcRp68QyK-POYoC58ZZe52q4AoJJrmRp2LTL0zTAiwagNET72Pbeew/exec"
        guard let url = URL(string: scriptURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let json = ["position": rowId]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else { return }
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error:", error.localizedDescription)
                return
            }
            guard let data = data else { return }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any], let success = responseJSON["success"] as? Bool, success {
                print("Row deleted successfully")
            }
        }
        task.resume()
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
