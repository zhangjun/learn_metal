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
    //var device: MTLDevice
    public let device: MTLDevice
    var queue: MTLCommandQueue
    public let useMPS: Bool
    
    init?() {
        self.device = MTLCreateSystemDefaultDevice()!
        self.library = device.makeDefaultLibrary()!
        self.queue = device.makeCommandQueue()!
        self.useMPS = self.device.supportsFeatureSet(.iOS_GPUFamily2_v2)
        guard self.device != nil else {
            print("Metal is not supported on this device")
            return
        }
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
    
    // https://github.com/a1252425/VideoEditor/blob/master/ZSVideoEditor/Metal/MetalInstance.swift
    private func getTextureDesc(width: Int, height: Int, depth: Int, textureType: MTLTextureType = .type2D, pixelFormat: MTLPixelFormat = .rgba32Float, usage: MTLTextureUsage = [.shaderWrite, .shaderRead], mipmapped: Bool = false) -> MTLTextureDescriptor {
        let textureDes = MTLTextureDescriptor.init()
        textureDes.textureType = textureType
        textureDes.width = width
        textureDes.height = height
        textureDes.depth = depth
        textureDes.pixelFormat = pixelFormat
        textureDes.usage = [.shaderWrite, .shaderRead]
        textureDes.storageMode = .shared
        return textureDes
    }
    
    func makeTexture() -> MTLTexture? {
        let desc = getTextureDesc(width: 300, height: 300, depth: 4, textureType: .type2DArray, pixelFormat: .rgba32Float)
        return device.makeTexture(descriptor: desc)!
    }
    
    func makeBuffer(size: Int, option: MTLResourceOptions = []) -> MTLBuffer {
        return device.makeBuffer(length: size, options: option)!
    }
    
    func makeTexture(size: MTLSize,
                         buffer: UnsafeMutablePointer<UInt32>? = nil,
                         usage: MTLTextureUsage = [.shaderRead]) -> MTLTexture? {
            
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: MTLPixelFormat.rgba8Unorm,
            width: size.width,
            height: size.height,
            mipmapped: false)
        descriptor.usage = usage
        
        let texture = device.makeTexture(descriptor: descriptor)
        texture?.replace(size: size, buffer: buffer)
        return texture
    }
        
    func makeTexture(w: Int, h: Int,
                     buffer: UnsafeMutablePointer<UInt32>? = nil,
                     usage: MTLTextureUsage = [.shaderRead]) -> MTLTexture? {
            
        let size = MTLSizeMake(w, h, 0)
        return makeTexture(size: size, buffer: buffer, usage: usage)
    }
}

extension MTLTexture {
    
    func replace(region: MTLRegion, buffer: UnsafeMutablePointer<UInt32>?) {
        
        if buffer != nil {
            let bpr = 4 * region.size.width
            replace(region: region, mipmapLevel: 0, withBytes: buffer!, bytesPerRow: bpr)
        }
    }
    
    func replace(size: MTLSize, buffer: UnsafeMutablePointer<UInt32>?) {
        
        let region = MTLRegionMake2D(0, 0, size.width, size.height)
        replace(region: region, buffer: buffer)
    }
    
    func replace(w: Int, h: Int, buffer: UnsafeMutablePointer<UInt32>?) {
        
        let region = MTLRegionMake2D(0, 0, w, h)
        replace(region: region, buffer: buffer)
    }
}
