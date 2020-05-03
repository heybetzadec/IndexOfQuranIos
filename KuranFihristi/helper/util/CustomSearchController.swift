//
//  CustomSearchController.swift
//  KuranFihristi
//
//  Created by Cavad Heybetzade on 5/2/20.
//  Copyright © 2020 Cavad Heybetzade. All rights reserved.
//

import UIKit

class CustomSearchController: UISearchController {
    
    var _searchBar: CustomSearchBar
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self._searchBar = CustomSearchBar()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(searchResultsController: UIViewController?) {
        self._searchBar = CustomSearchBar()
        super.init(searchResultsController: searchResultsController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var searchBar: UISearchBar {
        return self._searchBar
    }
}
