//
//  FeatureDomain.swift
//  ArchitectureExample
//
//  Created by Owen Thomas on 6/12/24.
//

import Combine
import Foundation

protocol FeatureViewProtocol {
    func buttonTapped()
}

class FeatureDomain: FeatureViewProtocol {
    let networkService: NetworkProtocol
    let viewStatePublisher: AnyPublisher<FeatureViewState, Never>
    private let viewStateSubject: PassthroughSubject<FeatureViewState, Never> = .init()

    init(networkService: NetworkProtocol) {
        self.networkService = networkService
        viewStatePublisher = viewStateSubject.eraseToAnyPublisher()
    }

    func buttonTapped() {
        networkService.fetch(url: URL(string: "https://swapi.dev/api/people/1")!) { [weak self] (result: Result<PeopleModel, Error>) in
            guard let self else { return }
            switch result {
            case .success(let value):
                self.viewStateSubject.send(.fetched(.init(name: value.name)))
            case .failure(let error):
                self.viewStateSubject.send(.failed(.init(error: error.localizedDescription)))
            }
        }
    }
}

enum FeatureViewState: Equatable {
    case fetched(Fetched)
    case fetching(Fetching)
    case failed(Failed)

    struct Fetched: Equatable {
        let name: String
    }
    struct Fetching: Equatable {}
    struct Failed: Equatable {
        let error: String
    }
}

struct PeopleModel: Codable {
    let name: String
}
