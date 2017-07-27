//: Playground - noun: a place where people can play

import UIKit

struct Filter {
    var rgbImage: RGBAImage
    var uiImage: UIImage
    var avgRed: Int! = nil
    var avgGreen: Int! = nil
    var avgBlue: Int! = nil
    
    init(uiImage: UIImage){
        self.rgbImage = RGBAImage(image: uiImage)!
        self.uiImage = uiImage
        let AvgValues = self.getAvgValues()
        self.avgRed = AvgValues.0
        self.avgGreen = AvgValues.1
        self.avgBlue = AvgValues.2
    }
    
    func getAvgValues() -> (Int, Int, Int){
        var totalRed = 0
        var totalGreen = 0
        var totalBlue = 0
        // Looping through each pixel
        for y in 0..<rgbImage.height{
            for x in 0..<rgbImage.width{
                let index = y*rgbImage.width + x
                var pixel = rgbImage.pixels[index]
                totalRed += Int(pixel.red)
                totalGreen += Int(pixel.green)
                totalBlue += Int(pixel.blue)
            }
        }
        
        let count = rgbImage.width*rgbImage.height
        let avgRed = totalRed/count //118
        let avgGreen = totalGreen/count //98
        let avgBlue = totalBlue/count // 83
        return (avgRed, avgGreen, avgBlue)
    }
    
    func warmer(intensity: Int) -> RGBAImage {
        var newImage: RGBAImage = rgbImage
        for y in 0..<rgbImage.height{
            for x in 0..<rgbImage.width{
                let index = y*rgbImage.width+x
                var pixel = rgbImage.pixels[index]
                let redDiff = Int(pixel.red) - avgRed
                if (redDiff > 0){
                    pixel.red = UInt8(max(0, min(255, avgRed + redDiff * intensity)))
                    pixel.blue = UInt8(max(0, min(255, avgBlue + redDiff / intensity)))
                    newImage.pixels[index] = pixel
                }
            }
        }
        return newImage
    }

    func cooler(intensity: Int) -> RGBAImage {
        var newImage: RGBAImage = rgbImage
        for y in 0..<rgbImage.height{
            for x in 0..<rgbImage.width{
                let index = y*rgbImage.width+x
                var pixel = rgbImage.pixels[index]
                let redDiff = Int(pixel.red) - avgRed
                if (redDiff > 0){
                    pixel.red = UInt8(max(0, min(255, avgRed + redDiff / intensity)))
                    pixel.blue = UInt8(max(0, min(255, avgBlue + redDiff * intensity)))
                    newImage.pixels[index] = pixel
                }
            }
        }
        return newImage
    }
    
    func brightness(intensity: Double) -> RGBAImage {
        func brighter(intensity: Double) -> RGBAImage {
            var newImage: RGBAImage = rgbImage
            for y in 0..<rgbImage.height{
                for x in 0..<rgbImage.width{
                    let index = y*rgbImage.width+x
                    var pixel = rgbImage.pixels[index]
                    
                    let red = Double(pixel.red) + Double(255 - Double(pixel.red)) * intensity / 100.0
                    let blue = Double(pixel.blue) + Double(255 - Double(pixel.blue)) * intensity / 100.0
                    let green = Double(pixel.green) + Double(255 - Double(pixel.green)) * intensity / 100.0
                    
                    pixel.red = UInt8(max(0, min(255, red)))
                    pixel.blue = UInt8(max(0, min(255, blue)))
                    pixel.green = UInt8(max(0, min(255, green)))
                    newImage.pixels[index] = pixel
                }
            }
            return newImage
        }
        
        func darker(intensity: Double) -> RGBAImage {
            var newImage: RGBAImage = rgbImage
            for y in 0..<rgbImage.height{
                for x in 0..<rgbImage.width{
                    let index = y*rgbImage.width+x
                    var pixel = rgbImage.pixels[index]
                    
                    // + because already intensity is negative
                    let red = Double(pixel.red) + Double(pixel.red) * intensity / 100.0
                    let blue = Double(pixel.blue) + Double(pixel.blue) * intensity / 100.0
                    let green = Double(pixel.green) + Double(pixel.green) * intensity / 100.0
                    
                    pixel.red = UInt8(max(0, min(255, red)))
                    pixel.blue = UInt8(max(0, min(255, blue)))
                    pixel.green = UInt8(max(0, min(255, green)))
                    newImage.pixels[index] = pixel
                }
            }
            return newImage
        }
        if (intensity>0){
            return brighter(intensity)
        }
        else{
            return darker(intensity)
        }
    }
    
    func grayscale() -> RGBAImage {
        var newImage: RGBAImage = rgbImage
        for y in 0..<rgbImage.height{
            for x in 0..<rgbImage.width{
                let index = y*rgbImage.width+x
                var pixel = rgbImage.pixels[index]
                
                let grayImage = 0.299 * Double(pixel.red) + 0.587 * Double(pixel.green) + 0.114 * Double(pixel.blue)
                let grayImage1 = round(grayImage)
                
                pixel.red = UInt8(grayImage1)
                pixel.blue = UInt8(grayImage1)
                pixel.green = UInt8(grayImage1)
                
                newImage.pixels[index] = pixel
            }
        }
        return newImage
    }

    func inverse() -> RGBAImage {
        var newImage: RGBAImage = rgbImage
        for y in 0..<rgbImage.height{
            for x in 0..<rgbImage.width{
                let index = y*rgbImage.width+x
                var pixel = rgbImage.pixels[index]
                
                pixel.red = UInt8(max(0, 255 - Int(pixel.red)))
                pixel.blue = UInt8(max(0, 255 - Int(pixel.blue)))
                pixel.green = UInt8(max(0, 255 - Int(pixel.green)))
                newImage.pixels[index] = pixel
            }
        }
        return newImage
    }


    
    mutating func process(allFilters :[String]) {
        for filter in allFilters{
            switch filter.lowercaseString {
            case "warm":
                self.rgbImage = warmer(2)
            case "cool":
                self.rgbImage = cooler(2)
            case "bright":
                self.rgbImage = brightness(50)
            case "dark":
                self.rgbImage = brightness(-50)
            case "grayscale":
                self.rgbImage = grayscale()
            case "inverse":
                self.rgbImage = inverse()
            default:
                print("wrong option chosed")
            }
        }
        self.uiImage = rgbImage.toUIImage()!
    }
    
}

let image = UIImage(named: "sample")!

var filter1 = Filter(uiImage: image)
filter1.process(["warm", "bright"])
filter1.uiImage

var filter2 = Filter(uiImage: image)
filter2.process(["cool", "dark"])
filter2.uiImage

var filter3 = Filter(uiImage: image)
filter3.process(["grayscale"])
filter3.uiImage

var filter4 = Filter(uiImage: image)
filter4.process(["inverse"])
filter4.uiImage






