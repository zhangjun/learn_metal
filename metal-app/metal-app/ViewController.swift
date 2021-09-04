//
//  ViewController.swift
//  metal-app
//
//  Created by Apple on 2021/9/4.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var ResultArea: UITextView!
    let metalHelper: MetalHelper = MetalHelper.shared
    var inputTexture: MTLTexture!
    var outputTexture: MTLTexture!
    var pipeline: MTLComputePipelineState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let lib = metalHelper.device.makeDefaultLibrary()
        if let function = lib?.makeFunction(name: "add") {
            pipeline = try? metalHelper.device.makeComputePipelineState(function: function)
        }
    }

    @IBAction func StartRun(_ sender: UIButton) {
        guard let inPipline = pipeline else {
            print(" pipline not ready")
            return
        }
        if (true) {
            let commandBuffer = metalHelper.queue.makeCommandBuffer()
            let encoder = commandBuffer?.makeComputeCommandEncoder()
            
            // prepare data
            let count = 1024
            var data = Array<Float>(repeating: 0, count: count)
            for (i, _) in data.enumerated() {
                data[i] = Float(i)
            }
            let size = count * MemoryLayout<Float>.size
            let options : MTLResourceOptions = [] // MTLResourceOptions.CPUCacheModeDefaultCache
            var input = metalHelper.device.makeBuffer(bytes:&data, length: size, options: options)
            var output = metalHelper.device.makeBuffer(length: size, options: options)
            
            encoder?.setBuffer(input, offset: 0, index: 0)
            encoder?.setBuffer(output, offset: 0, index: 1)
//            encoder?.setTexture(inputTexture, index: 0)
//            encoder?.setTexture(outputTexture, index: 1)
//            encoder?.setBytes(&input, length: MemoryLayout<Int>.size, index: 0)
//            encoder?.setBytes(&output, length: MemoryLayout<Float>.size, index: 1)
            
            // setup runtime
            encoder?.setComputePipelineState(inPipline)
            
//            let width = inPipline.threadExecutionWidth
//            let height = inPipline.maxTotalThreadsPerThreadgroup / width
//            let threadsPerGroup = MTLSize.init(width: width, height: height, depth: 1)
            
            let width = inPipline.threadExecutionWidth
            let height = (count + width - 1)/width
            let threadsPerGroup = MTLSize.init(width: width, height: 1, depth: 1)
            let groups = MTLSize(width: height, height: 1, depth: 1)
            
//            let slices = (outputTexture!.arrayLength * 4 + 3)/4
//            let groupWidth = (outputTexture!.width + width - 1)/width
//            let groupHeight = (outputTexture!.height + height - 1)/height
//            let groups = MTLSize.init(width: groupWidth, height: groupHeight, depth: slices)
            
            encoder?.setComputePipelineState(inPipline)
            encoder?.dispatchThreadgroups(groups, threadsPerThreadgroup: threadsPerGroup)
            encoder?.endEncoding()
            
            commandBuffer?.addCompletedHandler({(buffer) in
                self.ResultArea.text = "input"
            })
            commandBuffer?.commit()
            commandBuffer?.waitUntilCompleted()
            
            let result = output?.contents().load(as: Float.self)
            //print(String(format: "%f + %f = %f", data[0], data[1], result as! CVarArg))
            
        }
        self.ResultArea.text = "input"
    }
}

