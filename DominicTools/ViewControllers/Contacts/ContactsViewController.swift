//
//  ContactsViewController.swift
//  DominicTools
//
//  Created by Irsyad Ashari on 08/07/21.
//

import UIKit
import RxSwift
import RxCocoa

class ContactsViewController: UIViewController {

    // MARK: - PRIVATE PROPERTIES
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!
    private let disposeBag = DisposeBag()
    private var contactListViewModel = ContactListViewModel()
    
    // MARK: - PRIVATE METHOD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    private func setupTableView() {
        
        configureTableViewHeight()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "contactCell")
        
        contactListViewModel.contactListObservable
            .subscribe(onNext: { _ in
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func configureTableViewHeight() {
        
        let contentHeight = CGFloat(contactListViewModel.getContactsCount() * 100)
        
        tableViewHeightConstraint.constant = contentHeight
    }
    
    @IBAction private func onBackButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - EXTENSIONS

extension ContactsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contactListViewModel.getContactsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        contactListViewModel.prepareCellForDisplay(tableView: tableView, indexPath: indexPath)
    }
    
}

extension ContactsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        contactListViewModel.onContactTapped(index: indexPath.row, viewController: self)
    }
}
