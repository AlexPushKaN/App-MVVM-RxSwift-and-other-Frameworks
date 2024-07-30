//
//  NewsEnties+CoreDataProperties.swift
//  App-MVVM-RxSwift-and-other-Frameworks
//
//  Created by Александр Муклинов on 28.07.2024.
//
//

import Foundation
import CoreData


extension NewsEnties {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewsEnties> {
        return NSFetchRequest<NewsEnties>(entityName: "NewsEnties")
    }

    @NSManaged public var newsEntity: NSOrderedSet?

}

// MARK: Generated accessors for newsEntity
extension NewsEnties {

    @objc(insertObject:inNewsEntityAtIndex:)
    @NSManaged public func insertIntoNewsEntity(_ value: NewsEntity, at idx: Int)

    @objc(removeObjectFromNewsEntityAtIndex:)
    @NSManaged public func removeFromNewsEntity(at idx: Int)

    @objc(insertNewsEntity:atIndexes:)
    @NSManaged public func insertIntoNewsEntity(_ values: [NewsEntity], at indexes: NSIndexSet)

    @objc(removeNewsEntityAtIndexes:)
    @NSManaged public func removeFromNewsEntity(at indexes: NSIndexSet)

    @objc(replaceObjectInNewsEntityAtIndex:withObject:)
    @NSManaged public func replaceNewsEntity(at idx: Int, with value: NewsEntity)

    @objc(replaceNewsEntityAtIndexes:withNewsEntity:)
    @NSManaged public func replaceNewsEntity(at indexes: NSIndexSet, with values: [NewsEntity])

    @objc(addNewsEntityObject:)
    @NSManaged public func addToNewsEntity(_ value: NewsEntity)

    @objc(removeNewsEntityObject:)
    @NSManaged public func removeFromNewsEntity(_ value: NewsEntity)

    @objc(addNewsEntity:)
    @NSManaged public func addToNewsEntity(_ values: NSOrderedSet)

    @objc(removeNewsEntity:)
    @NSManaged public func removeFromNewsEntity(_ values: NSOrderedSet)

}

extension NewsEnties : Identifiable {

}
