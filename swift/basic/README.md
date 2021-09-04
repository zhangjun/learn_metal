# xcode
xcode-select --print-path
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

xcodebuild -showsdks
xcodebuild -list

xcodebuild -target AddDemo
xcodebuild clean

https://www.cnblogs.com/zhou--fei/p/11371019.html

# compile
mkdir build && cd build
cmake .. -G Xcode

xcodebuild -project simd_sample.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 6s,OS=11.2' -configuration Release
xcodebuild -project simd_sample.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 6s,OS=11.2' -configuration Debug


```
xcrun -sdk macosx swiftc -o simd_sample simd_sample.swift
```
