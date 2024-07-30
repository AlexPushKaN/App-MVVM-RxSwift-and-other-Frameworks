//
//  MainViewModel.swift
//  App-MVVM-RxSwift-and-other-Frameworks
//
//  Created by Александр Муклинов on 28.07.2024.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa

class MainViewModel {
    
    private let contentQueue = DispatchQueue(label: "com.yourapp.contentQueue", attributes: .concurrent)
    var networkService: NetworkServiceDescription!
    let dataService: CoreDataStack!
    private let disposeBag = DisposeBag()

    var isContentDownloaded: Bool = true
    var content = BehaviorRelay<[ContentModel.News]>(value: [])
    
    var maskDeinit = PublishSubject<Void>()
    
    var showNoConnectToInternet = PublishSubject<NetworkErrors>()
    var showAboutPageLimit = PublishSubject<Void>()
    var showDownloadsOfNewsNotFinish = PublishSubject<Void>()
    
    let maxPage: Int = 5
    var contentSize: Int = 0
    var contentPageNumber: Int = 1
    
    init(networkService: NetworkServiceDescription, dataService: CoreDataStack) {
        
        self.networkService = networkService
        self.dataService = dataService
        
        self.networkService.callViewWithInfoNoConnect
            .subscribe(onNext: { [weak self] error in
                self?.showNoConnectToInternet.onNext(error)
            })
            .disposed(by: disposeBag)
        
        if let contentData = try? dataService.mainContext.fetch(NewsEnties.fetchRequest()), !contentData.isEmpty {
            guard let content = contentData.first else { return }
            let mappedContent = ContentModel.mapFrom(enties: content)
            self.content.accept(mappedContent)
            if let contentSize = content.newsEntity {
                self.contentSize = contentSize.count
            }
        } else {
            downloadContent()
        }
        
        content.subscribe(onNext: { [weak self] _ in
            guard let strongSelf = self else { return }
            guard !strongSelf.content.value.isEmpty else { return }
            if strongSelf.content.value.count == strongSelf.contentSize  {
                strongSelf.isContentDownloaded = true
                DispatchQueue.global(qos: .utility).async {
                    let contentCopy = strongSelf.content.value
                    ContentModel.creatingToEntiesInContext(from: contentCopy,
                                                           in: strongSelf.dataService.mainContext)
                }
            }
        })
        .disposed(by: disposeBag)
    }
    
    func downloadContent() {
        
        guard contentPageNumber <= maxPage, isContentDownloaded else {
            if !isContentDownloaded {
                showDownloadsOfNewsNotFinish.onNext(())
            } else if contentPageNumber > maxPage {
                showAboutPageLimit.onNext(())
                
                print(content.value.count, " - count content news")
                var onlyContent = [URL]()
                content.value.forEach { news in
                    if let url = news.urlToSourсe {
                        onlyContent.append(url)
                    }
                }

                var counts: [URL: Int] = [:]
                onlyContent.forEach { url in
                    counts[url, default: 0] += 1
                }

                // Вывод количества вхождений каждого URL
                for (url, count) in counts {
                    print("\(url): \(count)")
                }

                // Для получения только одинаковых элементов
                let duplicateURLs = counts.filter { $0.value > 1 }
                print("")
                print("Duplicate URLs: \(duplicateURLs)")

            }
            return
        }
        
        networkService.requestFor(page: contentPageNumber) { [weak self] something in
            guard let strongSelf = self else { return }
            guard let content = something else { return }
            
            strongSelf.contentSize += content.count
            strongSelf.contentPageNumber += 1
            strongSelf.isContentDownloaded = false
            
            let _ = content.compactMap { someNews in

                guard var news = someNews as? ContentModel.News else { return }
                if let urlToImage = news.urlToImage {
                    strongSelf.networkService.loadDataImage(from: urlToImage) { result in
                        switch result {
                        case .success(let data):
                            news.imageData = data
                            strongSelf.appendToContent(news)
                        case .failure(_):
                            getRandomPicture()
                        }
                    }
                } else {
                    getRandomPicture()
                }
                
                func getRandomPicture() {
                    let randomNumberImage = [1,2,3,4,5,6,7].randomElement()
                    if let image = UIImage(named: "cat \(String(randomNumberImage!))"),
                       let imageData = image.pngData() {
                        news.imageData = imageData
                        strongSelf.appendToContent(news)
                    }
                }
            }
        }
    }
    
    private func appendToContent(_ news: ContentModel.News) {
        contentQueue.async(flags: .barrier) { [weak self] in
            guard let strongSelf = self else { return }
            var currentContent = strongSelf.content.value
            currentContent.append(news)
            strongSelf.content.accept(currentContent)
        }
    }

    func show(mask: CAShapeLayer, view: UIView) {
        AnimationService.expansion(mask: mask, view: view) { [weak self] in
            self?.maskDeinit.onNext(())
        }
    }
}
