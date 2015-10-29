//
//  imageScrollView.swift
//  ScrollViews
//
//  Created by Mike Jonas on 8/13/15.
//  Copyright (c) 2015 Skyrocket Software. All rights reserved.
//

import UIKit
import Kingfisher

class ImageScrollView: UIView, UIScrollViewDelegate {
    
    var scrollView = UIScrollView()
    var pageControl = UIPageControl()
    var pageViews: [UIImageView?] = []
    var images: [ImageComponents] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initScrollView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initScrollView()
    }
    


    func initScrollView() {
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.blackColor()
        scrollView.pagingEnabled = true
//        scrollView.alwaysBounceHorizontal = true
        self.addSubview(scrollView)
        self.addSubview(pageControl)
   
        print(pageControl.bounds.width)
    }
    
    func setupWithImageComponents(imageComponents:[ImageComponents], width:CGFloat) {
        self.images = imageComponents
        setupView(width)
    }
    func setupView(width:CGFloat) {
        scrollView.frame = CGRectMake(0, 0, width, width)
        pageControl.frame = CGRectMake(width / 2, width - 10, 0, 0)
        
        if images.count > 0 {
            // 0
            pageControl.currentPage = 0
            pageControl.numberOfPages = images.count
            if images.count <= 1 { pageControl.hidden = true }
            
            // 1
            for _ in 0..<images.count {
                pageViews.append(nil)
                
            }
            // 2
            scrollView.contentSize = CGSizeMake(width * CGFloat(images.count), width)
            
            loadPages()
        }
    }
    
    func loadPage(page: Int) {
        // 1
        var frame = scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0.0
        
        // 2
        if let imagePath = images[page].path {
            let newPageView = UIImageView()
            
            if let image = retrieveImageLocally(imagePath) {
                newPageView.image = image
            } else {
                let URL = NSURL(string: "https://s3-us-west-1.amazonaws.com/snapspots/images/\(imagePath)")!
                newPageView.kf_setImageWithURL(URL)
            }
            newPageView.contentMode = .ScaleAspectFit
            newPageView.frame = frame
            scrollView.addSubview(newPageView)
            
            // 3
            pageViews[page] = newPageView
        }
    }
    func loadPages() {
        // Load pages in our range
        for i in 0 ..< images.count {
            loadPage(i)
        }
    }
    
    func updatePager() {
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // Update the page control
        pageControl.currentPage = page
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        updatePager()
    }
    
}
