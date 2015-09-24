/*
*
* TableViewController.swift
* Airports
* Created by Guus Beckett on 14/09/15.
*
*   Copyright © 2015 Reupload. All rights reserved.
*
*
* Licensed under the EUPL, Version 1.1 or – as soon they will be approved by the European Commission - subsequent versions of the EUPL (the "Licence");
* You may not use this work except in compliance with the Licence.
* You may obtain a copy of the Licence at:
*
* http://ec.europa.eu/idabc/eupl
*
* Unless required by applicable law or agreed to in writing, software distributed under the Licence is distributed on an "AS IS" basis,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the Licence for the specific language governing permissions and limitations under the Licence.
*/

import UIKit

class TableViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    var tableData = Dictionary<String, [Airport]>()
    var filteredAirports = Dictionary<String, [Airport]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let middleman = DatabaseMiddleman.sharedInstance
        self.tableData = middleman.getAllAirports()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return tableData.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        var keys = [String]()
        for item in tableData.keys {
            keys.append(item)
        }

        let rows = tableData[keys[section]]
        return rows!.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> AirportTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("airportCell", forIndexPath: indexPath) as! AirportTableViewCell

        
        let row = indexPath.row
        let section = indexPath.section
        
        var keys = [String]()
        for item in tableData {
            keys.append(item.0)
        }

        let rowData = tableData[keys[section]]
        
        cell.airportName.text = rowData?[row].name
        cell.municipality.text = (rowData?[row].municipality)! + " (" + (rowData?[row].iso_country)! + ")"
        
        return cell
    }
    
    
    // Header title
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var keys = [String]()
        for item in tableData.keys {
            keys.append(item)
        }
        return keys[section]
    }
    
    
     override func sectionIndexTitlesForTableView(tableView: UITableView)
        -> [String] {
            var keys = [String]()
            for item in tableData.keys {
                keys.append(item)
            }
            return keys
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Check if the right segue is handled
        if segue.identifier == "airportDetail" {
            
            // Get destination controller
            if let destination = segue.destinationViewController as? AirportDetailedViewController {
                
                // Get selected row and lookup selected person in array
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    let section = indexPath.section
                    
                    var keys = [String]()
                    for item in tableData.keys {
                        keys.append(item)
                    }
                    
                    let rowData = tableData[keys[section]]
                    // Pass person to detailed view
                    let airport = rowData?[indexPath.row]
                    destination.airport = airport
                    
                }
            }
        }
    }
    
}
