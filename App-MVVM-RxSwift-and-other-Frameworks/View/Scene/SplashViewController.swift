//
//  SplashViewController.swift
//  App-MVVM-RxSwift-and-other-Frameworks
//
//  Created by Александр Муклинов on 28.07.2024.
//

import UIKit
import SnapKit
import RxSwift

final class SplashViewController: UIViewController {
    
    let maskLayer = CAShapeLayer()
    let catImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "cat Launch"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let disposeBag = DisposeBag()
    private let viewModel: SplashViewModel!
    private let coordinator: Coordinator!
    
    init(coordinator: Coordinator, viewModel: SplashViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setup()
        setupMaskLayer()
        
        binding()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.show(mask: maskLayer, view: view)
    }
    
    private func setup() {
        
        let safeArea = view.safeAreaLayoutGuide
        
        view.addSubview(catImageView)
        catImageView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalTo(safeArea)
        }
    }
    
    private func setupMaskLayer() {
        maskLayer.path = UIBezierPath(rect: view.bounds).cgPath
        maskLayer.fillRule = .evenOdd
        maskLayer.opacity = 1.0
        view.layer.mask = maskLayer
    }
    
    private func binding() {
        viewModel.goToMain
            .subscribe(onNext: { [weak self] in
                self?.coordinator.show(scene: .main)
            })
            .disposed(by: disposeBag)
    }
}
