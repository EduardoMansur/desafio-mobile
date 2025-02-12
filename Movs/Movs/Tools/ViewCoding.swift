//
//  ViewCoding.swift
//  Movs
//
//  Created by Eduardo Pereira on 28/07/19.
//  Copyright © 2019 Eduardo Pereira. All rights reserved.
//

import Foundation

protocol ViewCoding{
    func buildViewHierarchy()
    func setUpConstraints()
}

extension ViewCoding{
    func initViewCoding(){
        buildViewHierarchy()
        setUpConstraints()
    }
}

