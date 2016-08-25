//
//  ViewController.swift
//  ResourceViewController
//
//  Created by Sean Rada on 7/25/16.
//  Copyright © 2016 Sean Rada. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ResourceLinksDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func presentResource() {
        
        //Create view controllers to be presented
        let resourceViewController = ResourceViewController()
        resourceViewController.linksDataSource = self
        let navController = UINavigationController(rootViewController: resourceViewController)
        navController.navigationBar.opaque = false
        
        //Data for the three views in ResourceViewController
        let chartDictionary = ["Total 1": 1000000, "Total 2": 2000000, "Total 3": 7800000, "Total 4": 7469900, "Total 5": 1000000, "Total 6": 5000000, "Total 7": 1200560, "Extra LONG TITLE HERE asdfasdf asd f 1": 6340000, "Extra 2": 5000000, "Extra 3": 1200000]
        let propertiesDictionary = ["Name": "Example Chart", "Auther": "Yishak", "Breakfeast": "Bacon", "Favorite Color": "Red", "Dog":"Man's Best Friend", "Superhero": "Batman", "Panda": "BMW X6"]
        let linkDictionary = ["Investment 001": "Pr 1", "Contract 87": "Property 2", "870000": "Property 3"]
        
        //Present ResourceViewController
        self.presentViewController(navController, animated: true) {
            //If no colors are provided, default colors will be used
            resourceViewController.setup(totals: chartDictionary, properties: propertiesDictionary, links: linkDictionary, colors: [])
            resourceViewController.toggleLinksDisplay()
        }
    }

    //MARK: - <ResourceLinksDataSource>
    
    func resourceViewControllerNumberOfLinkSections(viewController: ResourceViewController) -> Int {
        return 1
    }
    
    func resourceViewController(viewController: ResourceViewController, numberOfRowsForLinkSection: Int) -> Int {
        return 5
    }
    
    func resourceViewController(viewController: ResourceViewController, collectionView: UICollectionView, cellForLinkAtPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LinkCell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.lightGrayColor()
        
        return cell
    }
}

