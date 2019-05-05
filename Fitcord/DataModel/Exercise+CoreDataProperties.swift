//
//  Exercise+CoreDataProperties.swift
//  Fitcord
//
//  Created by Van Le on 30/4/19.
//  Copyright © 2019 Van Le. All rights reserved.
//
//

import Foundation
import CoreData


extension Exercise {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exercise> {
        return NSFetchRequest<Exercise>(entityName: "Exercise")
    }

    @NSManaged public var name: String?
    @NSManaged public var muscleGroup: String?
    @NSManaged public var image: String?
    @NSManaged public var desc: String?

}
