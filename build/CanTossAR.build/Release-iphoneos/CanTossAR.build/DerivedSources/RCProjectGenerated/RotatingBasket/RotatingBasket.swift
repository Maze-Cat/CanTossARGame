//
// RotatingBasket.swift
// GENERATED CONTENT. DO NOT EDIT.
//

import Foundation
import RealityKit
import simd
import Combine

public enum RotatingBasket {

    public enum LoadRealityFileError: Error {
        case fileNotFound(String)
    }

    private static var streams = [Combine.AnyCancellable]()

    public static func loadScene() throws -> RotatingBasket.Scene {
        guard let realityFileURL = Foundation.Bundle(for: RotatingBasket.Scene.self).url(forResource: "RotatingBasket", withExtension: "reality") else {
            throw RotatingBasket.LoadRealityFileError.fileNotFound("RotatingBasket.reality")
        }

        let realityFileSceneURL = realityFileURL.appendingPathComponent("Scene", isDirectory: false)
        let anchorEntity = try RotatingBasket.Scene.loadAnchor(contentsOf: realityFileSceneURL)
        return createScene(from: anchorEntity)
    }

    public static func loadSceneAsync(completion: @escaping (Swift.Result<RotatingBasket.Scene, Swift.Error>) -> Void) {
        guard let realityFileURL = Foundation.Bundle(for: RotatingBasket.Scene.self).url(forResource: "RotatingBasket", withExtension: "reality") else {
            completion(.failure(RotatingBasket.LoadRealityFileError.fileNotFound("RotatingBasket.reality")))
            return
        }

        var cancellable: Combine.AnyCancellable?
        let realityFileSceneURL = realityFileURL.appendingPathComponent("Scene", isDirectory: false)
        let loadRequest = RotatingBasket.Scene.loadAnchorAsync(contentsOf: realityFileSceneURL)
        cancellable = loadRequest.sink(receiveCompletion: { loadCompletion in
            if case let .failure(error) = loadCompletion {
                completion(.failure(error))
            }
            streams.removeAll { $0 === cancellable }
        }, receiveValue: { entity in
            completion(.success(RotatingBasket.createScene(from: entity)))
        })
        cancellable?.store(in: &streams)
    }

    private static func createScene(from anchorEntity: RealityKit.AnchorEntity) -> RotatingBasket.Scene {
        let scene = RotatingBasket.Scene()
        scene.anchoring = anchorEntity.anchoring
        scene.addChild(anchorEntity)
        return scene
    }

    public class Scene: RealityKit.Entity, RealityKit.HasAnchoring {

    }

}
