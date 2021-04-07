//
//  PageCollectionViewCell.swift
//  GiniPayBusiness
//
//  Created by Nadya Karaban on 07.04.21.
//

import Foundation

class PageCollectionViewCell: UICollectionViewCell {
    // var pageImageView: UIImageView!

//    var data: CustomData? {
//            didSet {
//                guard let data = data else { return }
//                bg.image = data.backgroundImage
//
//            }
//        }

    var pageImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    fileprivate func addImageView() {
        contentView.addSubview(pageImageView)
        
        pageImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        pageImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        pageImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        pageImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        pageImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        pageImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addImageView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addImageView()
    }
}
