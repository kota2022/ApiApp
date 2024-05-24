//
//  FavoriteShop.swift
//  ApiApp
//
//  Created by Tsuji Kota on 14.05.2024.
//

import RealmSwift

class FavoriteShop: Object {
    
    @Persisted(primaryKey: true) var id = ""
    @Persisted var name = ""
    @Persisted var logoImageURL = ""
    @Persisted var address = ""
    @Persisted var couponURL = ""
    
}
