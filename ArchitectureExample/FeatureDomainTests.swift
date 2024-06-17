//
//  FeatureDomainTests.swift
//  ArchitectureExample
//
//  Created by Owen Thomas on 6/12/24.
//

import Combine
import XCTest

final class FeatureDomainTests: XCTestCase {
    var cancellable: AnyCancellable?
    enum TestError: Error {
        case networkFailed
    }
    func testSuccessfulNetworkResponse() throws {
        // given
        let networkService = MockNetworkService()
        let featureDomain = FeatureDomain.init(networkService: networkService)
        var viewStates: [FeatureViewState] = []
        cancellable = featureDomain.viewStatePublisher.sink { viewState in
            viewStates.append(viewState)
        }
        networkService.response = PeopleModel(name: "Owen Thomas")

        // when
        featureDomain.buttonTapped()

        //then
        XCTAssertEqual(viewStates.count, 1)
        XCTAssertEqual(viewStates.first, .fetched(.init(name: "Owen Thomas")))
    }

    func testFailedNetworkResponse() throws {
        // given
        let networkService = MockNetworkService()
        let featureDomain = FeatureDomain.init(networkService: networkService)
        var viewStates: [FeatureViewState] = []
        cancellable = featureDomain.viewStatePublisher.sink { viewState in
            viewStates.append(viewState)
        }
        networkService.error = TestError.networkFailed

        // when
        featureDomain.buttonTapped()

        //then
        XCTAssertEqual(viewStates.count, 1)
        XCTAssertEqual(viewStates.first, .failed(.init(error: "The operation couldn’t be completed. (ArchitectureExampleTests.FeatureDomainTests.TestError error 0.)")))
    }
}

class MockNetworkService: NetworkProtocol {
    var response: Any?
    var error: Error?

    func fetch<NetworkResponse>(url: URL, completion: @escaping (Result<NetworkResponse, any Error>) -> Void) where NetworkResponse : Decodable, NetworkResponse : Encodable {
        if let response {
            completion(.success(response as! NetworkResponse))
        } else if let error {
            completion(.failure(error))
        }
    }
}
