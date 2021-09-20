//
//  MTLHelper.swift
//  metal-app
//
//  Created by Apple on 2021/9/20.
//

import Foundation
import Metal
import MetalPerformanceShaders
import simd

class MTLHelper {
    var library: MTLLibrary
    var device: MTLDevice
    var queue: MTLCommandQueue
    
    init?() {
        self.device = MTLCreateSystemDefaultDevice()!
        self.library = device.makeDefaultLibrary()!
        self.queue = device.makeCommandQueue()!
    }
    
    func makeFunction(name: String) -> MTLComputePipelineState {
        do {
          guard let kernelFunction = library.makeFunction(name: name) else {
            fatalError("Could not load compute function '\(name)'")
          }
          return try library.device.makeComputePipelineState(function: kernelFunction)
        } catch {
          fatalError("Could not create compute pipeline for function '\(name)'")
        }
    }
    
    private func getTextureDesc(width: Int, heigt: Int, depth: Int, textureType: MTLTextureType, pixelFormat: MTLPixelFormat) -> MTLTextureDescriptor {
        let textureDes = MTLTextureDescriptor.init()
        textureDes.textureType = .type2D
        textureDes.width = 658
        textureDes.height = 987
        textureDes.depth = 1
        textureDes.pixelFormat = .rgba32Float
        textureDes.usage = [.shaderWrite, .shaderRead]
        textureDes.storageMode = .shared
        return textureDes
    }
    
    func makeTexture() -> MTLTexture {
        let desc = getTextureDesc(width: 300, heigt: 300, depth: 4, textureType: .type2DArray, pixelFormat: .rgba32Float)
        return device.makeTexture(descriptor: desc)!
    }
    
    func makeBuffer(size: Int, option: MTLResourceOptions = []) -> MTLBuffer {
        return device.makeBuffer(length: size, options: option)!
    }
}
