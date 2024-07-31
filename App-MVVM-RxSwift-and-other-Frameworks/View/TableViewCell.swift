//
//  TableViewCell.swift
//  App-MVVM-RxSwift-and-other-Frameworks
//
//  Created by Александр Муклинов on 31.07.2024.
//

import UIKit
import SnapKit

final class TableViewCell: UITableViewCell {
    
    enum Shape {
        case circle
        case square
    }
    
    static let reuseIdentifier = "cell"
    
    var titleLabel: UILabel!
    var pictureView: UIImageView!
    var publishedAtLabel: UILabel!
    var descriptLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        pictureView.image = nil
        publishedAtLabel.text = nil
        descriptLabel.text = nil
    }
    
    func configure(with news: ContentModel.News) {
        titleLabel.text = news.title
        if let picture = news.imageData {
            pictureView.image = UIImage(data: picture)
        }
        publishedAtLabel.text = String(news.publishedAt!.description.dropLast(5))
        descriptLabel.text = news.description

        updatePictureViewConstraints(shape: news.imageFromNet == false ? .circle : .square)
    }
    
    private func setupSubviews() {
        self.clipsToBounds = true
        
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        
        pictureView = UIImageView()
        pictureView.contentMode = .scaleAspectFill
        pictureView.clipsToBounds = true
        pictureView.layer.borderWidth = 1.0
        pictureView.layer.borderColor = UIColor.lightGray.cgColor
        
        publishedAtLabel = UILabel()
        publishedAtLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        
        descriptLabel = UILabel()
        descriptLabel.numberOfLines = 0
        
        addSubview(titleLabel)
        addSubview(pictureView)
        addSubview(publishedAtLabel)
        addSubview(descriptLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self).offset(16.0)
            make.leading.equalTo(self).offset(16.0)
            make.trailing.equalTo(self).inset(16.0)
        }

        pictureView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10.0)
            make.centerX.equalToSuperview()
            make.height.equalTo(200.0)
        }

        publishedAtLabel.snp.makeConstraints { make in
            make.top.equalTo(pictureView.snp.bottom).offset(10.0)
            make.leading.equalTo(self).offset(16.0)
            make.trailing.equalTo(self).inset(16.0)
        }

        descriptLabel.snp.makeConstraints { make in
            make.top.equalTo(publishedAtLabel.snp.bottom).offset(10.0)
            make.leading.equalTo(self).offset(16.0)
            make.trailing.equalTo(self).inset(16.0)
        }
    }
    
    private func updatePictureViewConstraints(shape: Shape) {
        pictureView.snp.remakeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10.0)
            make.centerX.equalToSuperview()
            
            if shape == .square {
                make.leading.equalTo(self).offset(16.0)
                make.trailing.equalTo(self).inset(16.0)
                make.height.equalTo(200.0)
                pictureView.layer.cornerRadius = 20.0
            } else if shape == .circle {
                let size = 200.0
                make.width.height.equalTo(size)
                pictureView.layer.cornerRadius = size / 2
            }
        }
    }
}
