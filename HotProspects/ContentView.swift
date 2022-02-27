//
//  ContentView.swift
//  HotProspects
//
//  Created by Ifang Lee on 2/23/22.
//

import SwiftUI

// TabView should be the parent view, with the tabs inside it having a NavigationView as necessary, rather than the other way around.
@MainActor class User: ObservableObject {
    @Published var name = "Nanachi"
}

// app crash if cannot find the EnvironmentObject
struct EditView: View {
    @EnvironmentObject var user: User

    var body: some View {
        TextField("Name", text: $user.name)
            .background(Color.gray)
    }
}

struct DisplayView: View {
    @EnvironmentObject var user: User

    var body: some View {
        Text(user.name)
    }
}

@MainActor class DelayedUpdater: ObservableObject {
    // @Published var value = 0
    var value = 0 {
        willSet {
            objectWillChange.send() //manual update UI // same as @Published
        }
    }
    init() {
        for i in 1...10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                self.value += 1
            }
        }
    }
}
struct ContentView: View {
    @StateObject private var user = User()
    @State private var selectedTab = "Env"
    @ObservedObject var updater = DelayedUpdater()
    @State private var output = ""

    var body: some View {
        TabView(selection: $selectedTab) {

            Text(output)
                .task {
                    await fetchReadings()
                }
                .tabItem {
                    Label("API", systemImage: "icloud.and.arrow.down")
                }
                .tag("Download")

            VStack {
                EditView()
                DisplayView()
            }
            .onTapGesture {
                selectedTab = "Flame"
            }
            .environmentObject(user)
            .tabItem {
                Label("env", systemImage: "house")
            }
            .tag("Env")


            Text("Value is: \(updater.value)")
                .tabItem {
                    Label("Fire", systemImage: "flame")
                }
                .tag("Flame")
        }
    }

    /**
     fetchReadingsNotFlexible() doesn’t give us a lot of flexibility –
     what if we want to stash the work away somewhere and do something else while it’s running?
     What if we want to read its result at some point in the future, perhaps handling any errors somewhere else entirely?
     what if just want to cancel the work because it’s no longer needed?
     -> use Result<String, Error>
     */
    func fetchReadingsNotFlexible() async {
        do {
            let url = URL(string: "https://hws.dev/readings.json")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let readings = try JSONDecoder().decode([Double].self, from: data)
            output = "Found \(readings.count) readings"
        } catch {
            print("Download error")
        }
    }

    // Assign API result to fetchTask for flexibility: pass the object, cancel it, etc
    func fetchReadings() async {
        let fetchTask = Task { () -> String in
            let url = URL(string: "https://hws.dev/readings.json")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let readings = try JSONDecoder().decode([Double].self, from: data)
            return "Found \(readings.count) readings"
        }

        let result = await fetchTask.result
        //optino 1
//        do {
//            output = try result.get()
//        } catch {
//            output =  "Error: \(error.localizedDescription)"
//        }

        //option 2
        switch result {
        case .success(let str):
            output = str
        case .failure(let error):
            output = "Error: \(error.localizedDescription)"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
