//
//  ViewController.swift
//  metal-app
//
//  Created by Apple on 2021/9/4.
//

import UIKit
import Vision
//import CoreMedia
import AVFoundation
import os.log

// https://github.com/hollance/MobileNet-CoreML/

class ViewController: UIViewController {
    @IBOutlet weak var ResultArea: UITextView!
    @IBOutlet weak var cameraView: UIView!
    var videoCapture: VideoCapture!
    let semaphore = DispatchSemaphore(value: 1)


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
        setUpCamera()
    }

    @IBAction func StartRun(_ sender: UIButton) {
        guard let inPipline = pipeline else {
            print(" pipline not ready")
            return
        }
        if (true) {
            var start, end : UInt64
            start = mach_absolute_time()
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
            
//            commandBuffer?.addCompletedHandler({(buffer) in
//                self.ResultArea.text = "input"
//            })
            commandBuffer?.addCompletedHandler({(cb) in
                if #available(iOS 10.3, *) {
                    let executionDuration = cb.gpuEndTime - cb.gpuStartTime
                    os_log("gpuTime: %f s.", log: .default, type: .info, executionDuration)
                } else {
                    print("gpuTime not supported.")
                }
                
            })
            commandBuffer?.commit()
            commandBuffer?.waitUntilCompleted()
            end = mach_absolute_time()
            print("GPU cost: \(Double(end - start) / Double(NSEC_PER_SEC))")
            
            let result = output?.contents().load(as: Float.self)
            print(String(format: "%f + %f = %f", data[0], data[1], result as! CVarArg))
            
        }
        self.ResultArea.text = "input"
    }
    
    func getTextureDesc(width: Int, heigt: Int, depth: Int, textureType: MTLTextureType, pixelFormat: MTLPixelFormat) -> MTLTextureDescriptor {
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
    
    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = cameraView.bounds
    }
    
    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.desiredFrameRate = 240
        videoCapture.setUp(sessionPreset: AVCaptureSession.Preset.hd1280x720) { success in
          if success {
            // Add the video preview into the UI.
            if let previewLayer = self.videoCapture.previewLayer {
              self.cameraView.layer.addSublayer(previewLayer)
              self.resizePreviewLayer()
            }

            // Once everything is set up, we can start capturing live video.
            self.videoCapture.start()
          }
        }
    }
    
    func predict(pixelBuffer: CVPixelBuffer) {
    }
    
    func runSample() {
        let mtlHelper = MTLHelper()
        let commandQueue = mtlHelper?.queue
        guard let commandBuffer = commandQueue?.makeCommandBuffer() else {
            return
        }
        commandBuffer.commit()
    }
}

extension ViewController: VideoCaptureDelegate {
  func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
    if let pixelBuffer = pixelBuffer {
      // The semaphore will block the capture queue and drop frames when
      // Core ML can't keep up with the camera.
      semaphore.wait()

      DispatchQueue.global().async {
        self.predict(pixelBuffer: pixelBuffer)
      }
    }
  }
}

