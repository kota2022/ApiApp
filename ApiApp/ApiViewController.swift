//
//  ApiViewController.swift
//  ApiApp
//
//  Created by Tsuji Kota on 13.05.2024.
//

import UIKit
import Alamofire
import AlamofireImage
import RealmSwift

class ApiViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
   
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    var shopArray: [ApiResponse.Result.Shop] = []
    var apiKey: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        

        let filePath = Bundle.main.path(forResource: "ApiKey", ofType: "plist")
        let plist = NSDictionary(contentsOfFile: filePath!)!
        apiKey = plist["key"] as! String
        
        updateShopArray()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        // Do any additional setup after loading the view.
    }
    
    func updateShopArray(){
        
        let parameters: [String: Any] = [
            "key": apiKey,
            "start": 1,
            "count": 20,
            "keyword": "ランチ",
            "format": "json"
        ]
        
        AF.request("https://webservice.recruit.co.jp/hotpepper/gourmet/v1/", method: .get, parameters: parameters).responseDecodable(of: ApiResponse.self) { response in
            
            if self.tableView.refreshControl!.isRefreshing {
                self.tableView.refreshControl!.endRefreshing()
            }
            
            //レスポンス受信処理
            switch response.result{
                
            case .success(let apiResponse):
                print("受信データ\(apiResponse)")
                self.shopArray = apiResponse.results.shop
                self.statusLabel.text = ""
                
            case .failure(let error):
                print(error)
                self.shopArray = []
                self.statusLabel.text = "データの取得が失敗しました"
                
                
            }
            self.tableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ShopCell
        let shop = shopArray[indexPath.row]
        let url = URL(string: shop.logo_image)!
        cell.logoImageView.af.setImage(withURL: url)
        cell.shopNameLabel.text = shop.name
        
        let starImageName = shop.isFavorite ? "star.fill" : "star"
        let starImage = UIImage(systemName: starImageName)?.withRenderingMode(.alwaysOriginal)
        cell.favoriteButton.setImage(starImage, for: .normal)
        
        return cell
    }
    
    @objc func refresh(){
        updateShopArray()
    }
    
    
    
    @IBAction func tapFavoriteButton(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView)
        let indexPath = tableView.indexPathForRow(at: point)!
        let shop = shopArray[indexPath.row]
        
        if shop.isFavorite {
            print("「\(shop.name)」をお気に入りから消去します")
            try! realm.write {
                let favoriteShop = realm.object(ofType: FavoriteShop.self, forPrimaryKey: shop.id)!
                realm.delete(favoriteShop)
            }
        } else {
            print("「\(shop.name)」をお気に入りに追加します")
            try! realm.write {
                let favoriteShop = FavoriteShop()
                favoriteShop.id = shop.id
                favoriteShop.name = shop.name
                favoriteShop.logoImageURL = shop.logo_image
                if shop.coupon_urls.sp == ""{
                    favoriteShop.couponURL = shop.coupon_urls.pc
                    
                }else{
                    favoriteShop.couponURL = shop.coupon_urls.sp
                }
                realm.add(favoriteShop)
            }
        }
        tableView.reloadData()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
