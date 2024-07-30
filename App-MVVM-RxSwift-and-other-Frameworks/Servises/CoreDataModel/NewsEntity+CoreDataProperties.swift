//
//  NewsEntity+CoreDataProperties.swift
//  App-MVVM-RxSwift-and-other-Frameworks
//
//  Created by Александр Муклинов on 28.07.2024.
//
//

import Foundation
import CoreData


extension NewsEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewsEntity> {
        return NSFetchRequest<NewsEntity>(entityName: "NewsEntity")
    }

    @NSManaged public var descript: String?
    @NSManaged public var imageData: Data?
    @NSManaged public var publishedAt: Date?
    @NSManaged public var title: String?
    @NSManaged public var uniqueNewsIdentifier: String?
    @NSManaged public var urlToSource: URL?
    @NSManaged public var newsEnties: NewsEnties?

}

extension NewsEntity : Identifiable {

}
