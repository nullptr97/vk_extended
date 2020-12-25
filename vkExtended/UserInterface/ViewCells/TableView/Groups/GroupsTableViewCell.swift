//
//  GroupsTableViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 22.12.2020.
//

import UIKit

class GroupsTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupActivityLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .getThemeableColor(fromNormalColor: .white)
        contentView.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        
        avatarImageView.setRounded()
        
        groupNameLabel.textColor = .getThemeableColor(fromNormalColor: .black)
        groupNameLabel.font = GoogleSansFont.medium(with: 16)
        
        groupActivityLabel.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        groupActivityLabel.font = GoogleSansFont.medium(with: 13)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setup(by viewModel: GroupCellViewModel) {
        if let url = URL(string: viewModel.photo100) {
            avatarImageView.kf.setImage(with: url)
        }
        groupNameLabel.text = viewModel.name
        groupActivityLabel.text = viewModel.activity
    }
}
