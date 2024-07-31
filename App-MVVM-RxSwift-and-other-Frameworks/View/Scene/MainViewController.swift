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
    
    typealias News = ContentModel.News
    
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
        
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
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
        
        viewModel.dataService.saveContext()
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
        
        tableView.dataSource = nil
        tableView.delegate = nil
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.content
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: TableViewCell.self)) { index, model, cell in
                cell.configure(with: model)
            }
            .disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(News.self)
            .asDriver()
            .drive(onNext: { [weak self] news in
                if let url = news.urlToSourсe {
                    let presentationNewsController = SFSafariViewController(url: url)
                    presentationNewsController.dismissButtonStyle = .close
                    presentationNewsController.modalPresentationStyle = .popover
                    presentationNewsController.modalTransitionStyle = .coverVertical
                    self?.present(presentationNewsController, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        tableView.rx
            .itemSelected
            .asDriver()
            .drive(onNext: { [weak self] indexPath in
                guard let strongSelf = self else { return }
                strongSelf.tableView.deselectRow(at: indexPath, animated: true)

            })
            .disposed(by: disposeBag)
        
        tableView.rx.willDisplayCell
            .subscribe(onNext: { [weak self] _, indexPath in
                guard let strongSelf = self else { return }
                if indexPath.row + 2 >= strongSelf.viewModel.content.value.count {
                    strongSelf.viewModel.downloadContent()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.maskDeinit
            .subscribe(onNext: { [weak self] in
                self?.maskLayer.removeFromSuperlayer()
            })
            .disposed(by: disposeBag)
        
        viewModel.showNoConnectToInternet
            .subscribe(onNext: { [weak self] error in
                if case let NetworkErrors.noConnectToNetwork(stringForLabel, stringForButton) = error {
                    DispatchQueue.main.async {
                        self?.showDisplayOfInformationView(action: .internet(stringForLabel, stringForButton))
                    }
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.showAboutPageLimit
            .subscribe(onNext: { [weak self] in
                DispatchQueue.main.async {
                    self?.showDisplayOfInformationView(action: .page("You have reached the maximum content page", "I see"))
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.showDownloadsOfNewsNotFinish
            .subscribe(onNext: { [weak self] in
                DispatchQueue.main.async {
                    self?.showDisplayOfInformationView(action: .newsDownloads("News downloads not finished", "I see"))
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func showDisplayOfInformationView(action: DisplayOfInformationView.ActionsForButton) {
        guard !isNoDisplayedDisplayOfInformationView else { return }
        
        let nib = UINib(nibName: "DisplayOfInformationView", bundle: nil)
        if let displayOfInformationView = nib.instantiate(withOwner: nil, options: nil).first as? DisplayOfInformationView {
            displayOfInformationView.setup(action: action)
            setupBefore(displayOfInformationView: displayOfInformationView)
            
            displayOfInformationView.update
                .subscribe(onNext: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.setupAfter(displayOfInformationView: displayOfInformationView)
                    if case .internet(_, _) = action {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            strongSelf.viewModel.isContentDownloaded = true
                            strongSelf.viewModel.downloadContent()
                        }
                    }
                })
                .disposed(by: disposeBag)
            
            view.addSubview(displayOfInformationView)
            isNoDisplayedDisplayOfInformationView = true
        }
    }
    
    private func setupBefore(displayOfInformationView: UIView) {
        displayOfInformationView.center = view.center
        AnimationService.animationOfInformation(display: displayOfInformationView)
        tableView.layer.opacity = 0.5
        tableView.isUserInteractionEnabled = false
        tableView.isScrollEnabled = false
        tableView.setContentOffset(tableView.contentOffset, animated: false)
    }
    
    private func setupAfter(displayOfInformationView: UIView) {
        AnimationService.animationOfInformation(hiding: displayOfInformationView)
        tableView.layer.opacity = 1.0
        tableView.isUserInteractionEnabled = true
        tableView.isScrollEnabled = true
        loadViewIfNeeded()
        isNoDisplayedDisplayOfInformationView = false
    }
}

//MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500.0
    }
}
