//
//  NetworkService.swift
//  ArchitectureExample
//
//  Created by Owen Thomas on 6/12/24.
//

import Foundation

protocol NetworkProtocol {
    func fetch<NetworkResponse: Codable>(url: URL, completion: @escaping (Result<NetworkResponse, Error>) -> Void)
}

class NetworkService: NetworkProtocol {
    enum NetworkError: Error {
        case missingData
    }

    func fetch<NetworkResponse>(url: URL, completion: @escaping (Result<NetworkResponse, any Error>) -> Void) where NetworkResponse : Decodable, NetworkResponse : Encodable {
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let data else {
                completion(.failure(NetworkError.missingData))
                return
            }
            do {
                let model = try JSONDecoder().decode(NetworkResponse.self, from: data)
                completion(.success(model))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
