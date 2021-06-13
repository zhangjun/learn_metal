import simd
import Metal

func stat() {

    let stride = MemoryLayout<simd_float4>.stride
    let align = MemoryLayout<simd_packed_float4>.alignment
    
    print("float4 stride: ", stride, ", align: ", align)
    
    let capacity = 8
    let buffer = UnsafeMutableBufferPointer<Float>.allocate(capacity: capacity)
    
    for i in 0..<capacity {
    	buffer[i] = Float(i)
    }
    
    let rawBuffer = UnsafeMutableRawBufferPointer.init(buffer)
    let readAligned = rawBuffer.load(fromByteOffset: MemoryLayout<Float>.stride * 4, as: simd_packed_float4.self)
    print(readAligned)
    
     
    let devices = MTLCopyAllDevices()
    		 
    for device in devices {
        print(device.name)
    	print("Is device low power? \(device.isLowPower).")
    	print("Is device external? \(device.isRemovable).")
    	print("Maximum threads per group: \(device.maxThreadsPerThreadgroup).")
    	print("Maximum buffer length: \(Float(device.maxBufferLength) / 1024 / 1024 / 1024) GB.")
    }
}
