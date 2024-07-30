//
//  SplashViewModel.swift
//  App-MVVM-RxSwift-and-other-Frameworks
//
//  Created by Александр Муклинов on 28.07.2024.
//

import UIKit
import RxSwift

final class SplashViewModel {

    var goToMain = PublishSubject<Void>()
    
    func show(mask: CAShapeLayer, view: UIView) {
        AnimationService.contraction(mask: mask, view: view) {
            self.goToMain.onNext(())
        }
    }
}
