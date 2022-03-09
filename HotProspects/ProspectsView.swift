//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Ifang Lee on 3/8/22.
//

import SwiftUI

struct ProspectsView: View {
    enum FilterType {
        case none, contacted, noncontacted
    }
    @EnvironmentObject var prospects: Prospects
    let filter: FilterType

    var body: some View {
        NavigationView {
            Text("People: \(prospects.people.count)")
                .navigationTitle(title)
                .toolbar {
                    Button {
                        let prospect = Prospect()
                        prospect.name = "Nanachi"
                        prospect.emailAddress = "nanachi@madeInAbyss.com"
                        prospects.people.append(prospect)
                    } label: {
                        Label("Scan", systemImage: "qrcode.viewfinder")
                    }
                }
            }
    }

    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted people"
        case .noncontacted:
            return "Uncontacted people"
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
            .environmentObject(Prospects())
    }
}
