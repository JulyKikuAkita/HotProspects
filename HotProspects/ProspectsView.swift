//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Ifang Lee on 3/8/22.
//

import SwiftUI
import CodeScanner
import UserNotifications

struct ProspectsView: View {
    enum FilterType {
        case none, contacted, noncontacted
    }

    enum SortBy {
        case uuid, name, date
    }
    
    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    @State private var isShowingSortConfirmationDialog = false
    @State private var sortBy: SortBy = .uuid
    let filter: FilterType



    var body: some View {
        NavigationView {
            List {
                ForEach(filteredProspects) { prosepct in
                    HStack {
                        prosepct.isContacted ?
                            Image(systemName: "person.crop.circle.badge.xmark") :
                            Image(systemName: "person.crop.circle.fill.badge.checkmark")
                        VStack(alignment: .leading) {
                                Text(prosepct.name)
                                    .font(.headline)
                                Text(prosepct.emailAddress)
                                    .foregroundColor(.secondary)
                                Text(prosepct.createdTimeString)
                                    .foregroundColor(.green)
                            }
                    }
                    .swipeActions {
                        if prosepct.isContacted {
                            Button {
                                prospects.toggle(prosepct)
                            } label: {
                                Label("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark")
                            }
                            .tint(.blue)
                        } else {
                            Button {
                                prospects.toggle(prosepct)
                            } label: {
                                Label("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark")
                            }
                            .tint(.green)

                            Button {
                                addNotification(for: prosepct)
                            } label: {
                                Label("Remind me", systemImage: "bell")
                            }
                            .tint(.orange)
                        }
                    }
                }
            }
                .navigationTitle(title)
            
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {
                            isShowingScanner = true
                        } label: {
                            Label("Scan", systemImage: "qrcode.viewfinder")
                        }

                        Button {
                            isShowingSortConfirmationDialog = true
                        } label: {
                            Label("Sort", systemImage: "arrow.up.arrow.down.square")
                        }
                    }
                }
                .confirmationDialog("Sort by", isPresented: $isShowingSortConfirmationDialog) {
                    Button("Sory by date") {
                        sortBy = .date
                        prospects.sortByDate()
                    }

                    Button("Sort by name") {
                        sortBy = .name
                        prospects.sortByName()
                    }
                }
                .sheet(isPresented: $isShowingScanner) {
                    CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com",  completion: handleScan)
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

    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter { $0.isContacted }
        case .noncontacted:
            return prospects.people.filter { !$0.isContacted }
        }
    }

    /**
     For codeScanner view:
     An array of the types of codes we want to scan. We’re only scanning QR codes in this app so [.qr] is fine, but iOS supports lots of other types too.
     A string to use as simulated data. Xcode’s simulator doesn’t support using the camera to scan codes, so CodeScannerView automatically presents a replacement UI so we can still test that things work. This replacement UI will automatically send back whatever we pass in as simulated data.
     A completion function to use. This could be a closure, but we just wrote the handleScan() method so we’ll use that.
     */
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false

        switch result {
        case .success( let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }

            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            prospects.add(person) // should use encapsulation, getter/setter

        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }

    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()

        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default

            var dateComponents = DateComponents()
            dateComponents.hour = 9
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false) // for app
            // for testing trigger
            let testingTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: testingTrigger)
            center.add(request)
        }

        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("D'oh")
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
            .environmentObject(Prospects())
    }
}
