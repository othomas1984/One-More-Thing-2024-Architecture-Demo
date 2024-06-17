//
//  ContentView.swift
//  ArchitectureExample
//
//  Created by Owen Thomas on 6/12/24.
//

import Combine
import SwiftUI

@Observable
class FeatureViewSource {
    private let viewStatePublisher: AnyPublisher<FeatureViewState, Never>
    private var cancellable: AnyCancellable?

    var viewState: FeatureViewState = .fetching(.init())

    init(viewStatePublisher: AnyPublisher<FeatureViewState, Never>) {
        self.viewStatePublisher = viewStatePublisher
        cancellable = viewStatePublisher.sink { [weak self] viewState in
            self?.viewState = viewState
        }
    }
}

struct ContentView: View {
    let viewModel: FeatureViewProtocol
    @State var featureSource: FeatureViewSource

    init(viewStatePublisher: AnyPublisher<FeatureViewState, Never>, viewModel: FeatureViewProtocol) {
        self.viewModel = viewModel
        self.featureSource = .init(viewStatePublisher: viewStatePublisher)
    }

    var body: some View {
        VStack {
            Button("Fetch Data") {
                viewModel.buttonTapped()
            }
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            switch featureSource.viewState {
            case .fetched(let fetched):
                Text(fetched.name)
            case .fetching:
                Text("Fetching")
            case .failed(let failed):
                Text("Error: \(failed.error)")
            }
        }
        .padding()
    }
}

#Preview {
    class TestViewProtocol: FeatureViewProtocol {
        func buttonTapped() {

        }
    }
    let publisher = Just<FeatureViewState>.init(.fetched(.init(name: "James"))).eraseToAnyPublisher()
    return ContentView(viewStatePublisher: publisher, viewModel: TestViewProtocol())
}

