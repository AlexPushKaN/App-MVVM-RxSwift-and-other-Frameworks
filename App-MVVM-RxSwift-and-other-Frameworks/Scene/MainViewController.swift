//
//  MainViewController.swift
//  App-MVVM-RxSwift-and-other-Frameworks
//
//  Created by Александр Муклинов on 28.07.2024.
//

import UIKit
import SnapKit
import SafariServices
import RxSwift
import RxCocoa

final class MainViewController: UIViewController {
    
    var tableView = UITableView()
    let maskLayer: CAShapeLayer = CAShapeLayer()
    var viewModel: MainViewModel!
    private let disposeBag = DisposeBag()

    var isNoDisplayedDisplayOfInformationView  = false
    
    init(mainViewModel: MainViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = mainViewModel
        binding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        setupMaskLayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.show(mask: maskLayer, view: view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    private func setupMaskLayer() {
        maskLayer.path = UIBezierPath(rect: view.bounds).cgPath
        maskLayer.fillRule = .evenOdd
        maskLayer.opacity = 1.0
        maskLayer.fillColor = UIColor.white.cgColor
        view.layer.mask = maskLayer
    }
    
    private func binding() {
        
    }
    
    private func showDisplayOfInformationView() {
        guard !isNoDisplayedDisplayOfInformationView else { return }
    
    }
    
    private func setupBefore(displayOfInformationView: UIView) {

    }
    
    private func setupAfter(displayOfInformationView: UIView) {

    }
}

//MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500.0
    }
}
