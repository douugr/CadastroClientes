//
//  ClienteTableViewCell.swift
//  CadastroClientes
//
//  Created by user on 17/08/2018.
//  Copyright © 2018 Doug. All rights reserved.
//

import UIKit

class ClienteTableViewCell: UITableViewCell {

    @IBOutlet weak var nomeLabel: UILabel!
    @IBOutlet weak var cpfLabel: UILabel!
    @IBOutlet weak var endereçoLabel: UILabel!
    @IBOutlet weak var dataNascLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
