import UIKit

var greeting = "Hello, playground"

let metalKernl = MetalKernel.init()
var begin = mach_absolute_time()
metalKernl.Run()
var end = mach_absolute_time()
print("GPU cost: \(Double(end - begin) / Double(NSEC_PER_SEC))")
