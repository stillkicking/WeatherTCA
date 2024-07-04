//
//  SettingsRow.swift
//  Weather
//
//  Created by jonathan saville on 14/06/2024.
//

enum SettingsRow: Int {
    case notifications
    case customise
    case advertisements
    case acknowledgements
    case privacy
    case email
    case call
    case contact
    case footer
    
    var description: String {
        switch self {
        case .notifications: return "Notifications"
        case .customise: return "Customize your view"
        case .advertisements: return "Remove ads"
        case .acknowledgements: return "Acknowledgements"
        case .privacy: return "Manage your privacy settings"
        case .email: return "Email us"
        case .call: return "Call us"
        case .contact: return "Weather is not supported by a 24-hour helpline. If you would like to let us know about any issues you are experiencing with the app, or provide us with feedback, please do not contact us."
        case .footer: return "Privacy policy"
        }
    }

    var imageName: String? {
        switch self {
        case .notifications: return "bell.fill"
        case .customise: return "thermometer.medium"
        case .advertisements: return "star.circle"
        case .privacy: return "slider.horizontal.3"
        case .email: return "envelope.fill"
        case .call: return "phone.fill"
        case .acknowledgements, .contact, .footer: return nil
        }
    }
}
