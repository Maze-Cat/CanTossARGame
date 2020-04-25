//
// MovingBasket.swift
// GENERATED CONTENT. DO NOT EDIT.
//

import Foundation
import RealityKit
import simd
import Combine

public enum MovingBasket {

    public enum LoadRealityFileError: Error {
        case fileNotFound(String)
    }

    private static var streams = [Combine.AnyCancellable]()

    public static func loadScene() throws -> MovingBasket.Scene {
        guard let realityFileURL = Foundation.Bundle(for: MovingBasket.Scene.self).url(forResource: "MovingBasket", withExtension: "reality") else {
            throw MovingBasket.LoadRealityFileError.fileNotFound("MovingBasket.reality")
        }

        let realityFileSceneURL = realityFileURL.appendingPathComponent("Scene", isDirectory: false)
        let anchorEntity = try MovingBasket.Scene.loadAnchor(contentsOf: realityFileSceneURL)
        return createScene(from: anchorEntity)
    }

    public static func loadSceneAsync(completion: @escaping (Swift.Result<MovingBasket.Scene, Swift.Error>) -> Void) {
        guard let realityFileURL = Foundation.Bundle(for: MovingBasket.Scene.self).url(forResource: "MovingBasket", withExtension: "reality") else {
            completion(.failure(MovingBasket.LoadRealityFileError.fileNotFound("MovingBasket.reality")))
            return
        }

        var cancellable: Combine.AnyCancellable?
        let realityFileSceneURL = realityFileURL.appendingPathComponent("Scene", isDirectory: false)
        let loadRequest = MovingBasket.Scene.loadAnchorAsync(contentsOf: realityFileSceneURL)
        cancellable = loadRequest.sink(receiveCompletion: { loadCompletion in
            if case let .failure(error) = loadCompletion {
                completion(.failure(error))
            }
            streams.removeAll { $0 === cancellable }
        }, receiveValue: { entity in
            completion(.success(MovingBasket.createScene(from: entity)))
        })
        cancellable?.store(in: &streams)
    }

    private static func createScene(from anchorEntity: RealityKit.AnchorEntity) -> MovingBasket.Scene {
        let scene = MovingBasket.Scene()
        scene.anchoring = anchorEntity.anchoring
        scene.addChild(anchorEntity)
        return scene
    }

    public class Scene: RealityKit.Entity, RealityKit.HasAnchoring {

    }

}
