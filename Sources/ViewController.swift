//
//  ViewController.swift
//  SwiftTracer-iOS
//
//  Created by Hugo Tunius on 30/01/16.
//  Copyright © 2016 Hugo Tunius. All rights reserved.
//

import UIKit
import SwiftTracer_Core

class ViewController: UIViewController {
    @IBOutlet weak var renderView: PixelRenderView!
    private var renderer: Renderer!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        updateAndRender()
    }

    override func viewDidLayoutSubviews() {
        updateAndRender()
    }

    private func updateAndRender() {
        guard let scale = self.view.window?.screen.scale else {
            return
        }

        let width = Int(self.renderView.bounds.size.width) * Int(scale)
        let height = Int(self.renderView.bounds.size.height) * Int(scale)
        let camera = Camera(fov: 0.785398163, width: width, height: height)
        self.renderer = Renderer(scene: buildScene(), camera: camera, maxDepth: 20)
        self.renderer.delegate = self
        self.renderer.render()
    }

    private func buildScene() -> Scene {
        let wallMaterial = Material(color: Color(r: 1.0, g: 1.0, b: 1.0),
            ambientCoefficient: 0.6,
            diffuseCoefficient: 0.3)
        let floor = Plane(position: Vector(x: 0.0, y: -1.0, z: 0.0), normal: Vector(x: 0.0, y: 1.0, z: 0.0), material: wallMaterial.copy())
        let frontWall = Plane(position: Vector(x: 0.0, y: 0.0, z: 50.0), normal: Vector(x: 0.0, y: 0.0, z: -1.0), material: wallMaterial.copy())
        let roof = Plane(position: Vector(x: 0.0, y: 15.0, z: 0.0), normal: Vector(x: 0.0, y: -1.0, z: 0.0), material: wallMaterial.copy())

        // rgb(7%, 32%, 57%)
        let leftWallMaterial = Material(color: Color(r: 0.07, g: 0.32, b: 0.57),
            ambientCoefficient: 0.6,
            diffuseCoefficient: 0.3)
        let leftWall = Plane(position: Vector(x: -7.0, y: 0.0, z: 0.0), normal: Vector(x: 1.0, y: 0.0, z: 0.0), material: leftWallMaterial)

        let backWallMaterial = Material(color: Color.Black,
            ambientCoefficient: 0.0,
            diffuseCoefficient: 0.0)
        let backWall = Plane(position: Vector(x: 0.0, y: 0.0, z: -1), normal: Vector(x: 0.0, y: 0.0, z: 1.0), material: backWallMaterial)

        // rgb(57%, 7%, 7%)
        let rightWallMaterial = Material(color: Color(r: 0.7, g: 0.32, b: 0.57),
            ambientCoefficient: 0.6,
            diffuseCoefficient: 0.3)
        let rightWall = Plane(position: Vector(x: 7.0, y: 0.0, z: 0.0), normal: Vector(x: -1.0, y: 0.0, z: 0.0), material: rightWallMaterial)

        let reflectiveMaterial = Material(color: Color.Black,
            ambientCoefficient: 0.6,
            diffuseCoefficient: 0.3,
            specularCoefficient: 0.4,
            reflectionCoefficient: 0.6,
            refractionCoefficient: nil)
        let s1 = Sphere(radius: 0.5, center: Vector(x: -1.5, y: 0.0, z: 10.0), material: reflectiveMaterial)

        let refractiveMaterial = Material(color: Color(r: 1.0, g: 1.0, b: 1.0),
            ambientCoefficient: 0.0,
            diffuseCoefficient: 0.4,
            specularCoefficient: 0.4,
            reflectionCoefficient: 0.0,
            refractionCoefficient: 1.5)
        let s2 = Sphere(radius: 0.5, center: Vector(x: -0.6, y: 0.6, z: 8.0), material: refractiveMaterial)

        let greenMaterial = Material(color: Color(r: 0.1, g: 0.74, b: 0.23), ambientCoefficient: 0.5, diffuseCoefficient: 0.3, specularCoefficient: 0.0, reflectionCoefficient: 0.0, refractionCoefficient: nil)
        let s3 = Sphere(radius: 0.5, center: Vector(x: 0.0, y: 1.2, z: 12.0), material: greenMaterial)

        let light = PointLight(color: Color(r: 1.0, g: 1.0, b: 1.0), position: Vector(x: 0, y: 10, z: 8), intensity: 0.6)

        return Scene(objects: [floor, roof, frontWall, leftWall, rightWall, backWall, s1, s2, s3], lights: [light], clearColor: Color.Black)
    }
}

extension ViewController: RendererDelegate {
    func didFinishRendering(pixels: [Color], duration: NSTimeInterval) {
        self.renderView.pixels = pixels
        self.renderView.setNeedsDisplay()
    }
}

