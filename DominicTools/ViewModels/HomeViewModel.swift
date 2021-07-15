//
//  ToolListViewModel.swift
//  DominicTools
//
//  Created by Irsyad Ashari on 02/07/21.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import CoreData

class HomeViewModel {
    
    // MARK: - PRIVATE PROPERTIES
    
    private let toolshed = BehaviorRelay<[Tool]>(value: [])
    private let isEmpty = BehaviorRelay<Bool>(value: true)
    
    private var toolsEntity = [ToolEntity]() // database staging property
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let disposeBag = DisposeBag()
    
    var toolshedObservable: Observable<[Tool]> {
        toolshed.asObservable()
    }
    
    var toolshedCount: Int {
        toolshed.value.count
    }
    
    var isToolshedEmpty: Bool {
        isEmpty.value
    }
    
    // MARK: - PRIVATE METHOD
    
    init() {
        loadTools()
    }
    
    private func loadTools(with request: NSFetchRequest<ToolEntity> = ToolEntity.fetchRequest(), predicate: NSPredicate? = nil) {
        
        do {
            self.toolsEntity = try context.fetch(request)
            
            if self.toolsEntity.isEmpty {
                
                print("toolshed is empty")
                fillToolShedInitialValue()
                isEmpty.accept(true)
            } else {
                print("load toolshed")
                loadToolShedEntityToToolshed()
                isEmpty.accept(false)
            }
            
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    private func loadToolShedEntityToToolshed() {
        
        var tools = [Tool]()
        for item in toolsEntity {
            tools.append(Tool(name: item.name ?? "",
                              image: item.image ?? "",
                              itemCount: Int(item.itemCount),
                              loanCount: Int(item.loanCount),
                              lendersName: item.lendersName ?? []))
        }
        
        toolshed.accept(tools)
        print(" toolshed accept new value")
    }
    
    private func saveToolToDB(item: Tool) {
        
        let newTool = ToolEntity(context: self.context)
        newTool.image = item.image
        newTool.itemCount = Int16(item.itemCount)
        newTool.lendersName = item.lendersName
        newTool.loanCount = Int16(item.loanCount)
        newTool.name = item.name
        
        self.toolsEntity.append(newTool)
        saveDBContext()
    }
    
    private func fillToolShedInitialValue() {
        
        let toolsList = [
            Tool(name: "Wrench", image: "Wrench", itemCount: 6, loanCount: 0, lendersName: []),
            Tool(name: "Cutter", image: "Cutter", itemCount: 15, loanCount: 0, lendersName: []),
            Tool(name: "Pliers", image: "Pliers", itemCount: 12, loanCount: 0, lendersName: []),
            Tool(name: "Screwdriver", image: "Screwdriver", itemCount: 13, loanCount: 0, lendersName: []),
            Tool(name: "Welding machine", image: "Welding machine", itemCount: 3, loanCount: 0, lendersName: []),
            Tool(name: "Welding glasses", image: "Welding glasses", itemCount: 7, loanCount: 0, lendersName: []),
            Tool(name: "Hammer", image: "Hammer", itemCount: 4, loanCount: 0, lendersName: []),
            Tool(name: "Measuring Tape", image: "Measuring Tape", itemCount: 9, loanCount: 0, lendersName: []),
            Tool(name: "Alan key set", image: "Alan key set", itemCount: 4, loanCount: 0, lendersName: []),
            Tool(name: "Air compressor", image: "Air compressor", itemCount: 2, loanCount: 0, lendersName: []),
        ]
        
        toolshed.accept(toolsList)
        
        toolsList.forEach { item in
            saveToolToDB(item: item)
        }
    }
    
    private func saveDBContext() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
    }
    
    private func presentLendersNamePopup(at index: Int,
                                         from viewController: UIViewController,
                                         completion: @escaping (String) -> Void) {
        
        let lendPopUpViewController = LendToolsPopUpViewController()
        
        lendPopUpViewController.onNavigationEvent = { [weak lendPopUpViewController] (event:LendToolsPopUpViewController.NavigationEvent) in
            
            switch event {
            case .saveInput(let text):
                completion(text)
                lendPopUpViewController?.dismiss()
            default:
                lendPopUpViewController?.dismiss()
            }
        }
        
        lendPopUpViewController.show(from: viewController)
    }
    
    private func lendTool(lenderName: String, index: Int) {
        
        toolsEntity[index].lendersName?.append(lenderName)
        toolsEntity[index].itemCount -= 1
        toolsEntity[index].loanCount += 1
        
        saveDBContext()
        
        var tools: [Tool] = []
        
        for tool in toolsEntity {
          
            tools.append(Tool(name: tool.name ?? "",
                              image: tool.image ?? "",
                              itemCount: Int(tool.itemCount),
                              loanCount: Int(tool.loanCount),
                              lendersName: tool.lendersName ?? []))
        }
        
        toolshed.accept(tools)
    }
    
    private func isContactExist(name: String) -> Bool {
        
        let contacts = ContactListViewModel().getContacts()
        
        for contact in contacts {
            if contact.name.lowercased() == name.lowercased() {
                return true
            }
        }
        
        return false
    }
    
    private func presentLendToolPopup(at index: Int, from viewController: UIViewController) {
        
        presentLendersNamePopup(at: index, from: viewController, completion: { name in
            
            if self.isContactExist(name: name) {
                
                viewController.toastMessage("Item has been loaned to \(name)")
                self.lendTool(lenderName: name, index: index)
            } else {
                
                viewController.toastMessage("Contact is not exist!")
            }
        })
    }
    
    private func isToolRemainExist(index: Int) -> Bool {
        
        toolshed.value[index].itemCount != 0
    }
    
    // MARK: - PUBLIC METHOD
    
    func reloadTools() {
        loadTools()
    }
    
    func prepareCellForDisplay(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "toolCell", for : indexPath) as? ToolTableViewCell {
            let tools = toolshed.value
            
            if !tools.isEmpty {
                cell.configure(viewModel: ToolViewModel(tool: tools[indexPath.row]))
            }
            
            return cell
        }
        fatalError()
        
    }
    
    func onToolTapped(at index: Int, from viewController: UIViewController) {
        
        if isToolRemainExist(index: index) {
            presentLendToolPopup(at: index, from: viewController)
        } else {
            viewController.toastMessage("This tool has run out of stock!")
        }
    }
    
    func presentContactList(viewController: UIViewController) {
        
        let contactListViewController = ContactsViewController()
        
        viewController.present(contactListViewController, animated: true) {
            UIView.animate(withDuration: 0.3, animations: {
                
                viewController.view.layoutIfNeeded()
                viewController.view.alpha = 1
            })
        }
    }
}
