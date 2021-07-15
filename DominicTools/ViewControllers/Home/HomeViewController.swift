//
//  HomeViewController.swift
//  DominicTools
//
//  Created by Irsyad Ashari on 02/07/21.
//

import UIKit
import RxSwift

class HomeViewController: UIViewController {

    // MARK: - PRIVATE PROPERTIES
    
    @IBOutlet private weak var tableView: UITableView!
    private let disposeBag = DisposeBag()
    private var homeViewModel = HomeViewModel()
    
    // MARK: - PRIVATE METHOD
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("view reappeared to screen")
        homeViewModel.reloadTools()
    }
    
   private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ToolTableViewCell", bundle: nil), forCellReuseIdentifier: "toolCell")
    
        homeViewModel.toolshedObservable
            .subscribe(onNext: { _ in
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction private func onContactBtnTapped(_ sender: Any) {
        
        homeViewModel.presentContactList(viewController: self)
    }
}

//MARK: - EXTENSIONS

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        homeViewModel.toolshedCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        homeViewModel.prepareCellForDisplay(tableView: tableView, indexPath: indexPath)
    }
    
}


extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.homeViewModel.onToolTapped(at: indexPath.row, from: self)
    }
}

