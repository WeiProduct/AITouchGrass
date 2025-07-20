//
//  Publisher+Extensions.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import Combine
import Foundation

extension Publisher {
    /// Converts publisher to async/await
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = self.first()
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                    }
                )
        }
    }
    
    /// Assigns to a published property with weak self
    func assign<Root: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<Root, Output>,
        on object: Root
    ) -> AnyCancellable where Failure == Never {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
    
    /// Main thread assignment
    func assignOnMainThread<Root: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<Root, Output>,
        on object: Root
    ) -> AnyCancellable where Failure == Never {
        receive(on: DispatchQueue.main)
            .assign(to: keyPath, on: object)
    }
}