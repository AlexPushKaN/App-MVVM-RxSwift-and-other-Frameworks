//
//  DisplayOfInformationView.swift
//  App-MVVM-RxSwift-and-other-Frameworks
//
//  Created by Александр Муклинов on 31.07.2024.
//

import UIKit
import RxSwift
import RxCocoa

final class DisplayOfInformationView: UIView {
    
    enum ActionsForButton {
        case internet(String, String) // - show information about the Internet connection
        case page(String, String) // - show information about reaching the maximum page
        case newsDownloads(String, String) // - show information about unfinished news downloads
        case none
    }

    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var connectionTryingsIndicator: UIActivityIndicatorView!
    
    var actionVariant: ActionsForButton = .none
    var update = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    func setup(action: ActionsForButton) {
        
        actionVariant = action
        
        switch action {
        case .internet(let titleLabel, let titleButton):
            informationLabel.text = titleLabel
            actionButton.setTitle(titleButton, for: .normal)
        case .page(let titleLabel, let titleButton):
            informationLabel.text = titleLabel
            actionButton.setTitle(titleButton, for: .normal)
        case .newsDownloads(let titleLabel, let titleButton):
            informationLabel.text = titleLabel
            actionButton.setTitle(titleButton, for: .normal)
        default: break
        }

        self.layer.borderColor = #colorLiteral(red: 0.006242707837, green: 0.4581466317, blue: 0.8921137452, alpha: 1).cgColor
        self.layer.borderWidth = 2.0
        connectionTryingsIndicator.isHidden = true
        
        actionButton.rx.tap
            .subscribe(onNext: { [weak self] in

                switch self?.actionVariant {
                case .internet(_, _):
                    self?.informationLabel.isHidden = true
                    self?.connectionTryingsIndicator.isHidden = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                        self?.update.onNext(())
                    }
                case .page(_, _), .newsDownloads(_, _):
                    self?.update.onNext(())
                case .some(.none), nil: break
                }
            })
            .disposed(by: disposeBag)
    }
}
