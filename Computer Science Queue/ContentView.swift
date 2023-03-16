import SwiftUI

struct ContentView: View {
    @State private var queue = [Queue]()
    @State private var showingAlert = false
    @State private var showingAddQueue = false
    @State private var position: Int = 0
    @State private var name: String = ""
    @State private var notes: String = ""
    @State private var colorPicker = ""
    @State private var isTimerRunning = false // added state variable for timer
        
        let timer = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
        
        // Start the timer
        func startTimer() {
            isTimerRunning = true
        }
        
        // Pause the timer
        func pauseTimer() {
            isTimerRunning = false
        }
        
        // Handler for timer tick
        func onTimerTick() {
            guard isTimerRunning else { return }
            Task { await getData() }
        }
    
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
                    //.onDelete() -> get whats deleted and assign it to rowId as a string
                    .onDelete { indexSet in
                        let rowId = queue[indexSet.first!].position
                        queue.remove(atOffsets: indexSet)
                        deleteRow(rowId: String(rowId))
                    }

                }
                
                
                .fullScreenCover(isPresented: $showingAddQueue, content: {
                    AddQueue()
                        .onDisappear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                Task {
                                    await getData()
                                    startTimer() // start timer when queue is updated
                                }
                            }
                        }
                })
                .navigationBarTitle("Virtual Queue", displayMode: .inline)
                .navigationBarItems(leading: EditButton().onTapGesture { pauseTimer() }) // pause timer when edit button is clicked
                .navigationBarItems(trailing: Button(action: {
                    showingAddQueue = true
                    pauseTimer() // pause timer when plus button is clicked
                }) {
                    Image(systemName: "plus")
                })
                .onAppear {
                    Task { await getData() }
                    startTimer() // start timer when content view is displayed
                }
                .onReceive(timer, perform: { _ in onTimerTick() })
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Loading Error"),
                      message: Text("There was a problem loading the Queue"),
                      dismissButton: .default(Text("OK")))
            }
        }
    
    func getData() async {
        let query = "https://script.google.com/macros/s/AKfycbxelvNYSJ8q7DuVDmN0IkoatGrtS9KCXr4QeMZONoFfODSXTjAPGEdURCINcelzJgjHGw/exec"
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
        let scriptURL = "https://script.google.com/macros/s/AKfycbxelvNYSJ8q7DuVDmN0IkoatGrtS9KCXr4QeMZONoFfODSXTjAPGEdURCINcelzJgjHGw/exec"
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
