//
//  Prospect.swift
//  HotProspects
//
//  Created by Ifang Lee on 3/8/22.
//

import SwiftUI

class Prospect: Identifiable, Codable {
    var id = UUID()
    var name = "Nanachi"
    var emailAddress = ""
    // note: we don't want value to be toggled directly as it won't alert UI to change. Use toggle() at Prospects class instead
    fileprivate(set) var isContacted = false  //read no restriciton but write only from the current file
}


@MainActor class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]
    let saveKey = "SavedData"

    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
                self.people = decoded
                return
            }
        }
        self.people = []
    }

    // alert UI to update
    // call objectWillChange.send() before changing your property, to ensure SwiftUI gets its animations correct.
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(people) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
}
