//
// Drink.swift
// GENERATED CONTENT. DO NOT EDIT.
//

import Foundation
import RealityKit
import simd
import Combine

public enum Drink {

    public enum LoadRealityFileError: Error {
        case fileNotFound(String)
    }

    private static var streams = [Combine.AnyCancellable]()

    public static func loadScene() throws -> Drink.Scene {
        guard let realityFileURL = Foundation.Bundle(for: Drink.Scene.self).url(forResource: "Drink", withExtension: "reality") else {
            throw Drink.LoadRealityFileError.fileNotFound("Drink.reality")
        }

        let realityFileSceneURL = realityFileURL.appendingPathComponent("Scene", isDirectory: false)
        let anchorEntity = try Drink.Scene.loadAnchor(contentsOf: realityFileSceneURL)
        return createScene(from: anchorEntity)
    }

    public static func loadSceneAsync(completion: @escaping (Swift.Result<Drink.Scene, Swift.Error>) -> Void) {
        guard let realityFileURL = Foundation.Bundle(for: Drink.Scene.self).url(forResource: "Drink", withExtension: "reality") else {
            completion(.failure(Drink.LoadRealityFileError.fileNotFound("Drink.reality")))
            return
        }

        var cancellable: Combine.AnyCancellable?
        let realityFileSceneURL = realityFileURL.appendingPathComponent("Scene", isDirectory: false)
        let loadRequest = Drink.Scene.loadAnchorAsync(contentsOf: realityFileSceneURL)
        cancellable = loadRequest.sink(receiveCompletion: { loadCompletion in
            if case let .failure(error) = loadCompletion {
                completion(.failure(error))
            }
            streams.removeAll { $0 === cancellable }
        }, receiveValue: { entity in
            completion(.success(Drink.createScene(from: entity)))
        })
        cancellable?.store(in: &streams)
    }

    private static func createScene(from anchorEntity: RealityKit.AnchorEntity) -> Drink.Scene {
        let scene = Drink.Scene()
        scene.anchoring = anchorEntity.anchoring
        scene.addChild(anchorEntity)
        return scene
    }

    public class Scene: RealityKit.Entity, RealityKit.HasAnchoring {

    }

}
