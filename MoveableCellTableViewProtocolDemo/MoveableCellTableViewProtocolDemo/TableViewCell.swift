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
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.toggleMoving(false)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
