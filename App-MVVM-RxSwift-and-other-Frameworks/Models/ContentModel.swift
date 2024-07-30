//
//  ContentModel.swift
//  App-MVVM-RxSwift-and-other-Frameworks
//
//  Created by Александр Муклинов on 28.07.2024.
//

import Foundation
import CoreData

struct ContentModel: Decodable {
    
    var news: [News] = []
    
    enum ContentKeys: String, CodingKey{
        case contentKey = "articles"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContentKeys.self)
        self.news = try container.decode([News].self, forKey: .contentKey)
    }
    
    struct News: Decodable {
        
        //for JSON
        var title: String?
        var publishedAt: Date?
        var description: String?
        var urlToImage: URL?
        var urlToSourсe: URL?
        
        //for storageData
        var imageData: Data?
        var uniqueNewsIdentifier: String?
        
        private enum CodingKeys: String, CodingKey {
            case title, publishedAt, description, urlToImage, urlToSourсe = "url"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.title = try container.decodeIfPresent(String.self, forKey: .title)
            self.publishedAt = try container.decodeIfPresent(Date.self, forKey: .publishedAt)
            self.description = try container.decodeIfPresent(String.self, forKey: .description)
            if let urlToImage = try container.decodeIfPresent(String.self, forKey: .urlToImage),
               let url = URL(string: urlToImage) {
                self.urlToImage = url
            }
            if let urlToSource = try container.decodeIfPresent(String.self, forKey: .urlToSourсe) {
                if let url = URL(string: urlToSource) {
                    self.urlToSourсe = url
                }
                self.uniqueNewsIdentifier = urlToSource
            }
        }
        
        init(title: String, publishedAt: Date, description: String, urlToSource: URL, imageData: Data?, uniqueNewsIdentifier: String) {
            self.title = title
            self.publishedAt = publishedAt
            self.description = description
            self.urlToSourсe = urlToSource
            self.imageData = imageData
            self.uniqueNewsIdentifier = uniqueNewsIdentifier
        }
    }
}

//MARK: - For storageData
extension ContentModel {
    
    typealias EntityType = NewsEntity
    typealias EntiesType = NewsEnties
    typealias StorageData = ContentModel.News
    
    static func creatingToEntiesInContext(from news: [StorageData], in context: NSManagedObjectContext) {

        var enties: EntiesType
        
        if let newsEnties = try? context.fetch(EntiesType.fetchRequest()).first {
            enties = newsEnties
        } else {
            enties = EntiesType(context: context)
        }
        
        for args in news {
            
            let fetchRequest: NSFetchRequest<EntityType> = EntityType.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "publishedAt", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            if let uniqueNewsIdentifier = args.uniqueNewsIdentifier {
                fetchRequest.predicate = NSPredicate(format: "uniqueNewsIdentifier == %@", uniqueNewsIdentifier)
                
                if let _ = make(request: fetchRequest, in: context) {
                    continue
                } else {
                    let newsEntity = creatingToEntityIn(context: context, from: args, for: enties)
                    enties.addToNewsEntity(newsEntity)
                }
            }
        }
        print("saveContext")
        try? context.save()
    }
    
    private static func make(request: NSFetchRequest<EntityType>, in context: NSManagedObjectContext) -> EntityType? {
        
        do {
            let fetcResult = try context.fetch(request)
            if fetcResult.count > 0 {
                assert(fetcResult.count == 1, "The database contains a duplicate news")
                return fetcResult[0]
            }
        } catch let error as NSError {
            print("Error occurred while executing fetch request from data base: \(error), \(error.userInfo)")
        }
        
        return nil
    }
    
    private static func creatingToEntityIn(context: NSManagedObjectContext, from news: StorageData, for newsEnties: NewsEnties) -> NewsEntity {
        let newsEntity = EntityType(context: context)
        newsEntity.title = news.title
        newsEntity.publishedAt = news.publishedAt
        newsEntity.descript = news.description
        newsEntity.urlToSource = news.urlToSourсe
        newsEntity.imageData = news.imageData
        newsEntity.uniqueNewsIdentifier = news.uniqueNewsIdentifier
        newsEntity.newsEnties = newsEnties
        return newsEntity
    }

    static func mapFrom(enties: EntiesType) -> [StorageData] {

        var storageData: [StorageData] = []
        enties.newsEntity?.forEach({ entity in
            let newsEntity = (entity as! EntityType)
            guard let title = newsEntity.title,
                  let publishedAt = newsEntity.publishedAt,
                  let description = newsEntity.descript,
                  let urlToSource = newsEntity.urlToSource,
                  let uniqueNewsIdentifier = newsEntity.uniqueNewsIdentifier else { return }
            
            let news = News(title: title,
                            publishedAt: publishedAt,
                            description: description,
                            urlToSource: urlToSource,
                            imageData: newsEntity.imageData,
                            uniqueNewsIdentifier: uniqueNewsIdentifier)
            
            storageData.append(news)
        })
        return storageData
    }
}
