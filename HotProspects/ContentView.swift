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

struct ContentView: View {
    @StateObject private var user = User()
    @State private var selectedTab = "Env"
    var body: some View {
        TabView(selection: $selectedTab) {
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


            Text("Tab 2")
                .tabItem {
                    Label("Fire", systemImage: "flame")
                }
                .tag("Flame")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
