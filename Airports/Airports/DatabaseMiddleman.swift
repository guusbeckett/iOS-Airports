/*
*
* DatabaseMiddleman.swift
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


class DatabaseMiddleman: NSObject {
    
    static let sharedInstance = DatabaseMiddleman()
    
    
    
    var database : COpaquePointer = nil
    
    override init() {
        
        let path = NSBundle.mainBundle().pathForResource("airports", ofType: "sqlite");
        
        if sqlite3_open(path!, &database) != SQLITE_OK {
            print("error opening airports database")
        }
    }
    
    func getAllAirports() -> Dictionary<String, [Airport]>{
        
        let query = "SELECT * FROM airports WHERE iso_country = \"NL\" OR iso_country = \"BE\" OR iso_country = \"JP\" ORDER BY name ASC"
        var iso_countries = [String]()
        // Prepare query and execute
        var statement : COpaquePointer = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String.fromCString(sqlite3_errmsg(database))
            print("error query: \(errmsg)")
            return Dictionary<String, [Airport]>()
        }
        
        var airports = Dictionary<String, [Airport]>()
        
        // Convert results to objects
        while sqlite3_step(statement) == SQLITE_ROW {
            let airport = Airport();
            
            // ICAO code and naming
            airport.icao = String.fromCString(UnsafePointer<Int8>(sqlite3_column_text(statement, 0)))
            airport.name = String.fromCString(UnsafePointer<Int8>(sqlite3_column_text(statement, 1)))
            
            // GPS coordinates
            airport.longitude = sqlite3_value_double(sqlite3_column_value(statement, 2))
            airport.latitude = sqlite3_value_double(sqlite3_column_value(statement, 3))
            airport.elevation = sqlite3_value_double(sqlite3_column_value(statement, 4))
            
            // Country and city
            airport.iso_country = String.fromCString(UnsafePointer<Int8>(sqlite3_column_text(statement, 5)))
            airport.municipality = String.fromCString(UnsafePointer<Int8>(sqlite3_column_text(statement, 6)))
            
            // Add to result
            
            if((airports[airport.iso_country!]) == nil) { //If country does not exist, add to dictionary
                iso_countries.append(airport.iso_country!)
                airports[airport.iso_country!] = [Airport]()
            }
            airports[airport.iso_country!]?.append(airport) //Add airport to array of it's country
        }
        return airports

    }
    
}