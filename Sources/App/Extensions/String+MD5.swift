//
//  String+MD5.swift
//  
//
//  Created by Jeremy Greenwood on 3/19/20.
//

import Vapor

extension String {
    var md5: String? {
        guard let data = data(using: .utf8) else {
            return nil
        }

        return Insecure.MD5.hash(data: data).map { String(format:"%02X", $0) }.joined().lowercased()
    }
}
