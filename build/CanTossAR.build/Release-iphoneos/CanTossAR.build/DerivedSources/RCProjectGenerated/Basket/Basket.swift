//
// Basket.swift
// GENERATED CONTENT. DO NOT EDIT.
//

import Foundation
import RealityKit
import simd
import Combine

public enum Basket {

    public enum LoadRealityFileError: Error {
        case fileNotFound(String)
    }

    private static var streams = [Combine.AnyCancellable]()

    public static func loadScene() throws -> Basket.Scene {
        guard let realityFileURL = Foundation.Bundle(for: Basket.Scene.self).url(forResource: "Basket", withExtension: "reality") else {
            throw Basket.LoadRealityFileError.fileNotFound("Basket.reality")
        }

        let realityFileSceneURL = realityFileURL.appendingPathComponent("Scene", isDirectory: false)
        let anchorEntity = try Basket.Scene.loadAnchor(contentsOf: realityFileSceneURL)
        return createScene(from: anchorEntity)
    }

    public static func loadSceneAsync(completion: @escaping (Swift.Result<Basket.Scene, Swift.Error>) -> Void) {
        guard let realityFileURL = Foundation.Bundle(for: Basket.Scene.self).url(forResource: "Basket", withExtension: "reality") else {
            completion(.failure(Basket.LoadRealityFileError.fileNotFound("Basket.reality")))
            return
        }

        var cancellable: Combine.AnyCancellable?
        let realityFileSceneURL = realityFileURL.appendingPathComponent("Scene", isDirectory: false)
        let loadRequest = Basket.Scene.loadAnchorAsync(contentsOf: realityFileSceneURL)
        cancellable = loadRequest.sink(receiveCompletion: { loadCompletion in
            if case let .failure(error) = loadCompletion {
                completion(.failure(error))
            }
            streams.removeAll { $0 === cancellable }
        }, receiveValue: { entity in
            completion(.success(Basket.createScene(from: entity)))
        })
        cancellable?.store(in: &streams)
    }

    private static func createScene(from anchorEntity: RealityKit.AnchorEntity) -> Basket.Scene {
        let scene = Basket.Scene()
        scene.anchoring = anchorEntity.anchoring
        scene.addChild(anchorEntity)
        return scene
    }

    public class Scene: RealityKit.Entity, RealityKit.HasAnchoring {

    }

}
