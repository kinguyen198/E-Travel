//
//  DetailSpotViewController.swift
//  e-Travel
//
//  Created by Kii Nguyen on 4/18/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import UIKit
import SwiftOverlays

class DetailSpotViewController: UIViewController {
    @IBOutlet weak var lblNameSpot: UILabel!
    @IBOutlet weak var lblAddressSpot: UILabel!
    @IBOutlet weak var lblPriceSpot: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblSubCategory: UILabel!
    @IBOutlet weak var slideCollection: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!

    var arrayImage = [UIImage]()
    var images = [String]()
    var name = String()
    var address = String()
    var price = String()
    var category = String()
    var des = String()
    var subcategory = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getImage(url: self.images)
        self.slideCollection.delegate = self
        self.slideCollection.dataSource = self
        self.lblNameSpot.text =  self.nonAccentVietnamese(str:  self.name)
        self.lblAddressSpot.text =  self.nonAccentVietnamese(str:  self.address)
        self.lblPriceSpot.text = "\( self.df2so(Double( self.price)!)) VND"
        self.lblCategory.text = "Category: \( self.category)"
        self.lblSubCategory.text = "(\( self.subcategory))"
        self.lblDescription.text =  self.des

    }
    
    func getImage(url:[String]){
        for a in self.images{
            let Url = URL(string: a)
            if a.isEmpty{
                DispatchQueue.main.async {
                    self.arrayImage.append(#imageLiteral(resourceName: "notfound"))
                    print("Get image error")
                }
                DispatchQueue.main.async {
                    print("Reload collection")
                    self.slideCollection.reloadData()
                }
            }else{
                let queue = DispatchQueue(label: "loadHinh")
                queue.async {
                    if let data = try? Data(contentsOf: Url!) {
                        do{
                            if let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    self.arrayImage.append(image)
                                    print("Get image success")
                                }
                                DispatchQueue.main.async {
                                    print("Reload collection")
                                    self.slideCollection.reloadData()
                                }
                            }
                        }catch{}
                    }
                    else{
                        DispatchQueue.main.async {
                            self.arrayImage.append(#imageLiteral(resourceName: "notfound"))
                            print("Get image error")
                        }
                        DispatchQueue.main.async {
                            print("Reload collection")
                            self.slideCollection.reloadData()
                        }
                    }
                }

            }
        }

    }
    func df2so(_ price: Double) -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSeparator = ","
        numberFormatter.groupingSize = 3
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.decimalSeparator = "."
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: price as NSNumber)!
    }
    func nonAccentVietnamese(str:String) -> String {
        var a = str
        a = a.replacingOccurrences(of: "đ", with: "d")
        a = a.replacingOccurrences(of: "Đ", with: "D")
        return a.folding(options: .diacriticInsensitive, locale:NSLocale.current)
    }
}
extension DetailSpotViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = arrayImage.count
        pageControl.isHidden = !(arrayImage.count > 1)
        return arrayImage.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCollectionViewCell
        cell.imageSpot.image = arrayImage[indexPath.row]

        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let witdh = scrollView.frame.width - (scrollView.contentInset.left*2)
        let index = scrollView.contentOffset.x / witdh
        let roundedIndex = round(index)
        self.pageControl?.currentPage = Int(roundedIndex)
    }

}
extension DetailSpotViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = slideCollection.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

