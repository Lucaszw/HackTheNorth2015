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
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // create graph
//        var graph = CPTXYGraph(frame: CGRectZero)
//        graph.title = "Hello Graph"
//        graph.paddingLeft = 0
//        graph.paddingTop = 0
//        graph.paddingRight = 0
//        graph.paddingBottom = 0
//        // hide the axes
//        var axes = graph.axisSet as! CPTXYAxisSet
//        var lineStyle = CPTMutableLineStyle()
//        lineStyle.lineWidth = 0
//        axes.xAxis.axisLineStyle = lineStyle
//        axes.yAxis.axisLineStyle = lineStyle
//        
//        // add a pie plot
//        var pie = CPTPieChart()
//        pie.dataSource = self
//        pie.pieRadius = (self.view.frame.size.width * 0.9)/2
//        graph.addPlot(pie)
//        
//        self.graphView.hostedGraph = graph
//
//
//    }
//    
//    
//    
//    
//    
//    
//    
//}