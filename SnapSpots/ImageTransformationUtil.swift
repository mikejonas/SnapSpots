//
//  ImageUtil.swift
//  SnapSpot2
//
//  Created by Mike Jonas on 4/16/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit

class ImageTransformationUtil {
    class func cropVerticalImageToSquare(image:UIImage) -> UIImage {
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let navbarHeight:CGFloat = 64
        let posX:CGFloat = (image.size.width / screenWidth) * navbarHeight
        let posY:CGFloat = 0
        
        let rect: CGRect = CGRectMake(posX, posY, image.size.width, image.size.width)
        let imageRef = CGImageCreateWithImageInRect(image.CGImage, rect)!
        let croppedImage: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        return croppedImage
    }
    
    class func scaleImageTo(newWidth newWidth:CGFloat, image:UIImage) -> UIImage {
        let newHeight = (image.size.height/image.size.width) * newWidth
        let newSize = CGSizeMake(newWidth, newHeight)
        var resizedImage:UIImage
        
        // Resize the image
        UIGraphicsBeginImageContext(newSize)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
