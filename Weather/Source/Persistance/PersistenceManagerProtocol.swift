//
//  PersistenceManagerProtocol.swift
//  Weather
//
//  Created by jonathan saville on 28/06/2024.
//

import Foundation

public protocol PersistenceManagerProtocol {
    func deleteLocationFor(_ uuid: UUID, shouldSaveContext: Bool)
    func moveLocationFrom(_ from: Int, to: Int)
    var locations: [CDLocation] { get }
#if DEBUG
    func loadTestData()
#endif
}

extension PersistenceManagerProtocol {
    func deleteLocationFor(_ uuid: UUID)  { deleteLocationFor(uuid, shouldSaveContext: true) }
}
