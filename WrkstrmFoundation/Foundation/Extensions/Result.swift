//
//  Result.swift
//  wrkstrm
//
//  Created by Cristian Monterroza on 9/1/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation

public enum Result<Model> {

    case success(Model)

    case failure(Error)
}
