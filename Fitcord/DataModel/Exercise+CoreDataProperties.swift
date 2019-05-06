//
//  Exercise+CoreDataProperties.swift
//  Fitcord
//
//  Created by Van Le on 5/5/19.
//  Copyright © 2019 Van Le. All rights reserved.
//
//

import Foundation
import CoreData


extension Exercise {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exercise> {
        return NSFetchRequest<Exercise>(entityName: "Exercise")
    }

    @NSManaged public var desc: String?
    @NSManaged public var image: String?
    @NSManaged public var muscleGroup: String?
    @NSManaged public var name: String?
    @NSManaged public var routines: NSSet?

}

// MARK: Generated accessors for routines
extension Exercise {

    @objc(addRoutinesObject:)
    @NSManaged public func addToRoutines(_ value: Routine)

    @objc(removeRoutinesObject:)
    @NSManaged public func removeFromRoutines(_ value: Routine)

    @objc(addRoutines:)
    @NSManaged public func addToRoutines(_ values: NSSet)

    @objc(removeRoutines:)
    @NSManaged public func removeFromRoutines(_ values: NSSet)

}
