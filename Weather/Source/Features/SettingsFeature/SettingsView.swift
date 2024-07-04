//
//  SettingsView.swift
//  Weather
//
//  Created by jonathan saville on 06/06/2024.
//
import SwiftUI
import ComposableArchitecture

struct SettingsView: View {
    
    @Bindable var store: StoreOf<Settings>

    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    let rows: [SettingsRow] = [.notifications, .customise, .advertisements, .acknowledgements, .privacy, .email, .call, .contact, .footer]

    var body: some View {
 
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {

            ZStack {
                Color.black.ignoresSafeArea()
                
                 List(rows, id: \.self) { row in
                    switch row {

                    case .notifications:
                        NavigationLink(state: Settings.Path.State.notifications(Notifications.State())) {
                            SettingsRowView(row: row)
                        }
                        .settingsRowModifier()

                    case .customise:
                        NavigationLink(state: Settings.Path.State.customize(Customize.State())) {
                            SettingsRowView(row: row)
                        }
                        .settingsRowModifier()
                        
                    case .advertisements:
                        NavigationLink(state: Settings.Path.State.advertising(Advertising.State())) {
                            SettingsRowView(row: row)
                        }
                        .settingsRowModifier()
                        
                    case .acknowledgements:
                        NavigationLink(state: Settings.Path.State.acknowledgements(Acknowledgements.State())) {
                            SettingsRowView(row: row)
                        }
                        .settingsRowModifier()

                    case .privacy, .email, .call:
                        Button() { store.send(.notImplemented) } label: {
                            SettingsRowView(row: row)
                        }
                        .settingsRowModifier(foregroundColor: Color.accentColor)
                        
                    case .contact:
                        SettingsRowView(row: row)
                            .settingsRowModifier(separatorTint: .clear)

                    case .footer:
                        HStack {
                            Text("Version \(appVersion ?? "")")
                            Spacer()
                            Text(row.description)
                                .foregroundColor(Color.accentColor)
                                .overlay(
                                    NavigationLink(state: Settings.Path.State.privacyPolicy(PrivacyPolicy.State())) {
                                        EmptyView()
                                    }
                                    .settingsRowModifier()
                                )
                        }
                        .settingsRowModifier(font: .footnote, separatorTint: .clear)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.inset)
            }
            .alert( store: self.store.scope(state: \.$alert, action: \.alert))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Settings")
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { store.send(.closeButtonTapped) } label: { Text("Close") }
                }
            }
        }
        destination: { store in
            switch store.case {
            case let .customize(store): CustomizeView(store: store)
            case let .acknowledgements(store): AcknowledgementsView(store: store)
            case let .privacyPolicy(store): PrivacyPolicyView(store: store)
            case let .notifications(store): NotificationsView(store: store)
            case let .advertising(store): AdvertisingView(store: store)
            }
        }
    }
}

#Preview {
    SettingsView(
        store: Store(initialState: Settings.State()) { Settings() }
    )
}
