//
//  ArchitectureExampleApp.swift
//  ArchitectureExample
//
//  Created by Owen Thomas on 6/12/24.
//

import Combine
import SwiftUI

@main
struct ArchitectureExampleApp: App {
    let networkService: NetworkProtocol
    let featureDomain: FeatureDomain
    init() {
        networkService = NetworkService()
        featureDomain = FeatureDomain(networkService: networkService)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewStatePublisher: featureDomain.viewStatePublisher,
                        viewModel: featureDomain)
        }
    }
}
