//
//  ImageSpotCollectionViewCell.swift
//  e-Travel
//
//  Created by Kii Nguyen on 5/11/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import UIKit

protocol ImageCellDelegate:class {
    func delete(cell:ImageSpotCollectionViewCell)
}
class ImageSpotCollectionViewCell: UICollectionViewCell {
    weak var delegate:ImageCellDelegate?
    @IBOutlet weak var imageContent: UIImageView!
    
    @IBOutlet weak var deleteButtonBackground: UIVisualEffectView!
    @IBAction func deleteDidTap(_ sender: Any) {
        delegate?.delete(cell: self)
    }

}
