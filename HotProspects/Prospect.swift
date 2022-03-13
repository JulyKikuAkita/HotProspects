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
    @Published var people: [Prospect]

    init() {
        self.people = []
    }

    // alert UI to update
    // call objectWillChange.send() before changing your property, to ensure SwiftUI gets its animations correct.
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
    }
}
