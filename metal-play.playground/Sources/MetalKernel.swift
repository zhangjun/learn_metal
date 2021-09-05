import Foundation
import MetalKit

public class MetalKernel: NSObject {
    var pipeline: MTLComputePipelineState?
    var device: MTLDevice
    var library: MTLLibrary
    var commandQueue: MTLCommandQueue
    var commandBuffer: MTLCommandBuffer
    var encoder: MTLComputeCommandEncoder
    
    static let shared: MetalKernel = MetalKernel.init()
    
    override public init() {
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!
        library = device.makeDefaultLibrary()!

        commandBuffer = commandQueue.makeCommandBuffer()!
        
        encoder = commandBuffer.makeComputeCommandEncoder()!
        let funcName = "add"
        if let function = library.makeFunction(name: funcName) {
            pipeline = try? device.makeComputePipelineState(function: function)
        }
        
        encoder.setComputePipelineState(pipeline!)
        super.init()
    }
    
    public func Run() {
        self.RunKernel()
    }
    func InitKernel () {
    }
    
    func RunKernel() {

        let input: [Float] = [1.0, 2.0]
        encoder.setBuffer(device.makeBuffer(bytes: input as [Float], length: MemoryLayout<Float>.stride * input.count, options: []),
                          offset: 0, index: 0)
        let outputBuffer = device.makeBuffer(length: MemoryLayout<Float>.stride, options: [])!
        encoder.setBuffer(outputBuffer, offset: 0, index: 1)

        let numThreadgroups = MTLSize(width: 1, height: 1, depth: 1)
        let threadsPerThreadgroup = MTLSize(width: 1, height: 1, depth: 1)
        encoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        let result = outputBuffer.contents().load(as: Float.self)

        print(String(format: "%f + %f = %f", input[0], input[1], result))

    }
}
