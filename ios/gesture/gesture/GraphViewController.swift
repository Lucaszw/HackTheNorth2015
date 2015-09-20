////
////  GraphViewController.swift
////  gesture
////
////  Created by Maksym Pikhteryev on 2015-09-19.
////  Copyright (c) 2015 seapig. All rights reserved.
////
//
//import Foundation
//
//
//class GraphViewController: UIViewController {
//    
//    @IBOutlet 
//    
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        
//        // create graph
//        var graph = CPTXYGraph(frame: CGRectZero)
//        
//        graph.paddingLeft = 5
//        graph.paddingTop = 5
//        graph.paddingRight = 5
//        graph.paddingBottom = 5
//        // Axes
//        var axes = graph.axisSet as! CPTXYAxisSet
//        var lineStyle = CPTMutableLineStyle()
//        lineStyle.lineWidth = 2
//        axes.xAxis.axisLineStyle = lineStyle
//        axes.yAxis.axisLineStyle = lineStyle
//        
//        self.graphView.hostedGraph = graph
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//        
//    
//
//    
//    
//    
//    
//    
//    
//    
//}