//
//  TableViewCell.swift
//  MoveableCellTableViewProtocolDemo
//
//  Created by StormXX on 2017/5/24.
//  Copyright © 2017年 StormXX. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell, MoveableCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
