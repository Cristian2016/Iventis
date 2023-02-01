//
//  Secretary.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 01.02.2023.
// Secretary knows shit on anybody! For example it knows how many pinned bubbles exist at any given time without the need to ask CoreData. It collects varous data from various parts of the App

import Foundation

class Secretary {
    private init() { }
    static let shared = Secretary()
}
