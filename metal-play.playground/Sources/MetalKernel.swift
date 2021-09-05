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
        let funcName = "compare"
        if let function = library.makeFunction(name: funcName) {
            pipeline = try? device.makeComputePipelineState(function: function)
        }
        
        encoder.setComputePipelineState(pipeline!)
        super.init()
    }
    
    public func Run() {
        self.RunKernel1()
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
    
    func RunKernel1() {

        let inputX: [Float] = [1.0, 3.0, 7.0, 3.1]
        let inputY: [Float] = [1.0, 2.0, 5.0, 11.5]
        encoder.setBuffer(device.makeBuffer(bytes: inputX as [Float], length: MemoryLayout<Float>.stride * inputX.count, options: []), offset: 0, index: 0)
        encoder.setBuffer(device.makeBuffer(bytes: inputY as [Float], length: MemoryLayout<Float>.stride * inputY.count, options: []), offset: 0, index: 1)
        let outputBuffer = device.makeBuffer(length: MemoryLayout<Float>.stride * inputX.count, options: [])!
        encoder.setBuffer(outputBuffer, offset: 0, index: 2)

        let numThreadgroups = MTLSize(width: 1, height: 1, depth: 1)
        let threadsPerThreadgroup = MTLSize(width: 1, height: 1, depth: 1)
        encoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
//        let result = outputBuffer.contents().bindMemory(to: Float.self, capacity: inputX.count)
//        var data = [Float](repeating:0, count: inputX.count)
//        for i in 0 ..< inputX.count { data[i] = result[i] }

        let result = outputBuffer.contents().bindMemory(to: Float.self, capacity: inputX.count)

        print(String(format: "%f, %f, %f, %f", result[0], result[1], result[2], result[3]))

    }
}
