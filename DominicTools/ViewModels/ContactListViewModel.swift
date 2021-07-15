//
//  ContactListViewModel.swift
//  DominicTools
//
//  Created by Irsyad Ashari on 08/07/21.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import CoreData

class ContactListViewModel {
    
    
    // MARK: - PRIVATE PROPERTIES
    private let contactsList = BehaviorRelay<[Contact]>(value: [])
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let disposeBag = DisposeBag()
    private var toolsEntity = [ToolEntity]() // database staging property
    
    //MARK: - PUBLIC PROPERTIES
    
    var contactListObservable: Observable<[Contact]> {
        contactsList.asObservable()
    }
    
    // MARK: - PRIVATE METHOD
    
    init() {
       
        loadContact()
    }
    
    private func loadContact(with request: NSFetchRequest<ToolEntity> = ToolEntity.fetchRequest(), predicate: NSPredicate? = nil) {
        
        do {
            
            self.toolsEntity = try context.fetch(request)
            
            if !self.toolsEntity.isEmpty {
                syncContactsWithDB()
            }
            
        } catch {
            print("Error fetching data from context \(error)")
        }
        
    }
    
    private func syncContactsWithDB()  {
        
        var contacts = [
            Contact(name: "Brian", image: "Brian", borrowedTools: []),
            Contact(name: "Letty", image: "Letty", borrowedTools: []),
            Contact(name: "Luke", image: "Luke", borrowedTools: []),
            Contact(name: "Parker", image: "Parker", borrowedTools: []),
            Contact(name: "Shaw", image: "Shaw", borrowedTools: []),
        ]
        
        for (index, contact) in contacts.enumerated() {
            
            let contactName = contact.name.lowercased()
            
            for tool in toolsEntity {
                
                guard let toolName = tool.name else {
                    return
                }
                
                guard let lendersName = tool.lendersName else {
                    return
                }
                
                for lenderName in lendersName {
                    if lenderName == contactName {
                        contacts[index].borrowedTools.append(toolName)
                    }
                }
            }
        }
        
        contactsList.accept(contacts)
    }
    
    private func saveDBContext() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
    }
    
    private func presentLoanedItemViewController(at index: Int,
                                                 from viewController: UIViewController,
                                                 completion: @escaping (String) -> Void) {
        
        let tappedContact = getContactByIndex(index: index)
        let configuration = LoanedItemsViewController.Configuration(loanedItems: tappedContact.borrowedTools, contactsPhoto: tappedContact.image, contactsName: tappedContact.name)
        let loanedViewController = LoanedItemsViewController(configuration: configuration)
        
        loanedViewController.onNavigationEvent = { [weak loanedViewController] (event: LoanedItemsViewController.NavigationEvent) in
            
            switch event {
            case .itemReturned(let tool):
                completion(tool)
                loanedViewController?.dismiss(animated: true, completion: nil)
            default:
                loanedViewController?.dismiss(animated: true, completion: nil)
            }
        }
        
        loanedViewController.show(in: viewController)
        
    }
    
    private func presentLoanedItem(index: Int, viewController: UIViewController) {
        
        presentLoanedItemViewController(at: index, from: viewController, completion: { returnedTool in
            
            let tappedContact = self.getContactByIndex(index: index)
            
            self.returnTool(lenderName: tappedContact.name, toolName: returnedTool, viewController: viewController)
            
        })
        
    }
    
    private func returnTool(lenderName: String, toolName: String, viewController: UIViewController) {
        
        for (indexTool,tool) in toolsEntity.enumerated() {
            
            if tool.name == toolName {
                
                guard let lenders = toolsEntity[indexTool].lendersName else { return}
                
                for (indexLenders, name) in lenders.enumerated() {
                    
                    if lenderName.lowercased() == name.lowercased() {
                        
                        toolsEntity[indexTool].lendersName?.remove(at: indexLenders)
                        toolsEntity[indexTool].itemCount += 1
                        toolsEntity[indexTool].loanCount -= 1
                        
                        saveDBContext()
                        viewController.toastMessage("\(lenderName) has Return \(toolName) ")
                        syncWithContacts(lenderName: lenderName, toolName: toolName, viewController: viewController)
                        return
                    }
                }
            }
        }
        
    }
    
    private func syncWithContacts(lenderName: String, toolName: String, viewController: UIViewController) {
        
        var contactsObject = contactsList.value
        
        for (indexContact, contact) in contactsObject.enumerated() {
            
            if contact.name == lenderName {
                
                for (indexTool, tool) in contact.borrowedTools.enumerated() {
                    
                    if toolName == tool {
                        
                        contactsObject[indexContact].borrowedTools.remove(at: indexTool)
                        break
                    }
                }
            }
        }
        
        contactsList.accept(contactsObject)
        print("sync with contacts executed")
    }
    
    // MARK: - PUBLIC METHOD
    
    func onContactTapped(index: Int, viewController: UIViewController) {
        
        let tappedContact = getContactByIndex(index: index)
        
        if tappedContact.borrowedTools.isEmpty {
            viewController.toastMessage("\(tappedContact.name) has not been borrowing anything yet!")
        } else {
            presentLoanedItem(index: index, viewController: viewController)
        }
    }
    
    func prepareCellForDisplay(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for : indexPath) as? ContactTableViewCell {
            
            let contacts = contactsList.value
            
            if !contacts.isEmpty {
                cell.configure(viewModel: ContactViewModel(contact: contacts[indexPath.row]))
            }
            
            return cell
        }
        
        fatalError()
        
    }
    
    func isBorrowedToolsEmpty(index: Int) -> Bool {
        contactsList.value[index].borrowedTools.isEmpty
    }
    
    func getContacts() -> [Contact] {
        contactsList.value
    }
    
    func getContactByIndex(index: Int) -> Contact {
        contactsList.value[index]
    }
    
    func getContactsCount() -> Int {
        contactsList.value.count
    }
}
