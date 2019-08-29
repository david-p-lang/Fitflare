//
//  StatsTableViewController.swift
//  FitFlare
//
//  Created by David Lang on 8/29/19.
//  Copyright © 2019 David Lang. All rights reserved.
//

import UIKit
import  CoreData

class StatsViewController: UIViewController {
  
  var screenStack: UIStackView = UIStackView()
  var tableView = UITableView()
  var playerStatsResultsController:NSFetchedResultsController<PlayerStats>!
  var workoutsResultsController:NSFetchedResultsController<Workout>!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Table.reuseId)
    fetchObjectDetectionSets(nil)
    setupScreenStack()
    screenStack.addArrangedSubview(tableView)
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.separatorInset.left = 0
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.topAnchor.constraint(equalTo: screenStack.topAnchor).isActive = true
    tableView.widthAnchor.constraint(equalTo: screenStack.widthAnchor).isActive = true
    tableView.heightAnchor.constraint(equalTo: screenStack.heightAnchor).isActive = true
    
    if playerStatsResultsController.fetchedObjects?.count == 0 {
      addSet()
      addSet()
      addSet()
      print("players", playerStatsResultsController.fetchedObjects?.count)
    }
  }
  
  fileprivate func setupScreenStack() {
    screenStack.axis = .vertical
    screenStack.distribution = .equalCentering
    screenStack.alignment = .center
    screenStack.spacing = 30
    view.addSubview(screenStack)
    screenStack.translatesAutoresizingMaskIntoConstraints = false
    screenStack.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    screenStack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    screenStack.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    screenStack.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
  }
  

    
  func fetchObjectDetectionSets(_ predicate: NSPredicate?) {
    
    //declare a request of type training set
    let request:NSFetchRequest<PlayerStats> = PlayerStats.fetchRequest()
    
    //sort descriptors required
    request.sortDescriptors = []
    
    //add a predicate
    //request.predicate = predicate
    
    //initialize the results controller
    playerStatsResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: DataController.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
    do {
      try playerStatsResultsController.performFetch()
    } catch {
      print(error.localizedDescription)
    }
    print("33", playerStatsResultsController.fetchedObjects)
  }
  
  @objc func addSet() {
    
    //prepare to add a training set into coredata
    guard let entity = NSEntityDescription.entity(forEntityName: "PlayerStats", in: DataController.shared.mainContext) else { return }
    let newPlayerStats = PlayerStats(entity: entity, insertInto: DataController.shared.mainContext)
    
    //identify the training set with a name
    newPlayerStats.name = "default"
    
    //attempt to save the data
    do {
    try DataController.shared.mainContext.save()
    } catch {
      print("error saving")
    }
    //update the results controller
    fetchObjectDetectionSets(nil)
    
    //reload the information in the tableview
    tableView.reloadData()
  }
  
}

extension StatsViewController : UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
      print("22",playerStatsResultsController.sections?.count)
        return 1
      
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let number = playerStatsResultsController?.sections?[section].numberOfObjects ?? 0
      print("22", section)
      print("11", number)
        //there are no training sets, provide a message to the user to create a training set
        if number == 0 {
            tableView.setEmptyMessage("No workouts recorded yet")
        } else {
            tableView.setEmptyMessage("")
        }
        
        return number
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Table.reuseId, for: indexPath)
        let statsArray = Array(playerStatsResultsController.fetchedObjects!)
        print(statsArray)
        //set the name
        cell.textLabel?.text = "workout \(indexPath.row)"  //statsArray[indexPath.row]
        
        // center the text in the cell
        cell.textLabel?.textAlignment = .center
        
        //clarify the cell border
        cell.contentView.backgroundColor = UIColor.init(displayP3Red: 0.9, green: 0.9, blue: 0.9, alpha: 0.2)
        
        //the method requires a UITableViewCell is returned
        return cell
    }
 




}
