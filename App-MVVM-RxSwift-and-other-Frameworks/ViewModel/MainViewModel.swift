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
    private let disposeBag = DisposeBag()

    var isContentDownloaded: Bool = true
    
    var maskDeinit = PublishSubject<Void>()
    
    var showAboutPageLimit = PublishSubject<Void>()
    var showDownloadsOfNewsNotFinish = PublishSubject<Void>()
    
    let maxPage: Int = 5
    var contentSize: Int = 0
    var contentPageNumber: Int = 1
    
    func downloadContent() {
    }
    
    private func appendToContent() {
    }

    func show(mask: CAShapeLayer, view: UIView) {
    }
}
