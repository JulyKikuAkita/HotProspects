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
    var isContacted = false
}


@MainActor class Prospects: ObservableObject {
    @Published var people: [Prospect]

    init() {
        self.people = []
    }
}
