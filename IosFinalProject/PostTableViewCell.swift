//
//  PostTableViewCell.swift
//  IosFinalProject
//
//  Created by 황윤구 on 6/13/24.
//

import Foundation
import UIKit

class PostTableViewCell: UITableViewCell {
    let title = UILabel()
    let comment = UILabel()
    let imageViewCell = UIImageView()
    let userName = UILabel()
    let time = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(title)
        contentView.addSubview(imageViewCell)
        contentView.addSubview(userName)
        contentView.addSubview(time)
        
//        contentView.backgroundColor = .lightGray
        contentView.layer.cornerRadius = 30
        contentView.clipsToBounds = true
        
        title.translatesAutoresizingMaskIntoConstraints = false
        imageViewCell.translatesAutoresizingMaskIntoConstraints = false
        userName.translatesAutoresizingMaskIntoConstraints = false
        time.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            title.trailingAnchor.constraint(equalTo: userName.leadingAnchor, constant: -20),
            
            userName.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20),
            userName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            time.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 20),
            time.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            imageViewCell.topAnchor.constraint(equalTo: time.bottomAnchor, constant: 20),
            imageViewCell.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            imageViewCell.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageViewCell.widthAnchor.constraint(equalToConstant: 200),
            imageViewCell.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
