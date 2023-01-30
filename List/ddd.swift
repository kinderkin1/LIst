//
//  ddd.swift
//  List
//
//  Created by Kinder on 25/12/2021.
//

    import SwiftUI

    class UserSetting: ObservableObject {
        @Published var isOn: Bool = UserDefaults.standard.bool(forKey: "isOn"){
        didSet {
            UserDefaults.standard.set(self.isOn, forKey: "isOn")
        }
    }
    }
