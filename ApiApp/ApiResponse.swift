//
//  ApiResponse.swift
//  ApiApp
//
//  Created by Tsuji Kota on 14.05.2024.
//

import RealmSwift

struct ApiResponse: Decodable{
    var results: Result
    
    struct Result: Decodable{
        var shop: [Shop]
        struct Shop: Decodable{
            var id: String
            var name: String
            var logo_image: String
            var address: String
            var coupon_urls: CouponUrls
            
            struct CouponUrls: Decodable {
                var pc: String
                var sp: String
            }
            
            var isFavorite: Bool {
                if try! Realm().object(ofType: FavoriteShop.self, forPrimaryKey: self.id) != nil{
                    return true
                } else {
                    return false
                }
            }
        }
    }
}
