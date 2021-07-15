//
//  LoanedItemsViewController.swift
//  DominicTools
//
//  Created by Irsyad Ashari on 08/07/21.
//

import UIKit

class LoanedItemsViewController: UIViewController {

    public enum NavigationEvent {
        
        case dismiss
        case itemReturned(String)
    }
    
    public var onNavigationEvent: ((NavigationEvent) -> Void)?
    
    // MARK: - PRIVATE PROPERTIES
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var confirmationView: UIView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private var dictTools: [String: Int] = [:]
    private var configuration: Configuration!
    private var selectedTool: String?
    
    public convenience init(configuration: Configuration) {
        self.init()
        self.configuration = configuration
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareSubviewsForAnimation()
        configureWidget()
        sortTools()
        configureTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configureContentHeight()
    }
    
    // MARK: - PUBLIC METHODS
    
    public func show(in viewController: UIViewController) {
        
        self.modalPresentationStyle = .overCurrentContext
        
        viewController.present(self, animated: false) {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                
                self?.contentView.transform = .identity
                self?.view.layoutIfNeeded()
                self?.view.alpha = 1
            })
        }
    }
    
    public func close(animated: Bool = true, completion: (() -> Void)? = nil) {
        
        guard animated else {
            
            view.alpha = 0
            dismiss(animated: false, completion: completion)
            
            return
        }
        
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                
                self?.view.alpha = 0
                
                guard let translateY = self?.contentViewHeightConstraint.constant else {
                    return
                }
                
                self?.contentView.transform = CGAffineTransform(translationX: 0, y: translateY)
                
            }, completion: { [weak self] _ in
                self?.dismiss(animated: false, completion: completion)
            }
        )
        
    }
    
//MARK: - PRIVATE METHOD
    
    private func configureTableView() {
        tableView.register(UINib(nibName: "LoanedToolTableVIewCell", bundle: nil), forCellReuseIdentifier: "loanToolCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    private func configureWidget() {
        photoImageView.layer.cornerRadius = photoImageView.frame.height/2
        photoImageView.image = UIImage(named: configuration.contactsPhoto)
        titleLabel.text = "\(configuration.contactsName)'s Loaned Tools"
    }
    
    private func prepareSubviewsForAnimation() {
        
        view.alpha = 0
        
        configureContentHeight()
    }
    
    private func configureContentHeight() {
        
        let totalHeight = calculateContentViewHeight()
        
        contentViewHeightConstraint.constant = totalHeight
    }
    
    private func calculateContentViewHeight() -> CGFloat {
        
        let maxHeight = UIScreen.main.bounds.height - 40
        let imageVerticalPadding = CGFloat(32)
        let imageHeight = photoImageView.frame.height
        
        let tableViewContentHeight = self.tableView.contentSize.height
        let cellTableViewPadding = CGFloat(dictTools.count * 16)
        print("dictTool count = \(dictTools.count)")
        let bottomButtonVerticalPadding = CGFloat(32)
        let bottomButtonHeight = CGFloat(32)
        
        let totalHeight = imageVerticalPadding +
            imageHeight +
            tableViewContentHeight +
            cellTableViewPadding +
            bottomButtonHeight +
            bottomButtonVerticalPadding
        
        return min(maxHeight, totalHeight)
    }
    
    private func sortTools() {
        
        let toolsInitial = ["Wrench", "Cutter", "Pliers", "Screwdriver" , "Welding machine", "Welding glasses", "Hammer", "Measuring Tape", "Alan key set", "Air compressor"]
        
        for tool in toolsInitial {
            
            var counter = 0
            
            for item in configuration.loanedItems {
                
                if tool == item {
                    counter += 1
                    dictTools[tool] = counter
                }
            }
        }
        
        
    }

    private func getBorrowedToolsCount() -> Int {
        
        var counter = 0
        
        for key in dictTools.keys {
            
            if dictTools[key] != 0 {
                counter += 1
            }
        }
        print("count tools : \(counter)")
        return counter
    }
    
    private func showConfirmationView() {
        
        confirmationView.isHidden = false
    }
    
    private func dismissConfirmationView() {
        
        
        confirmationView.isHidden = true
    }
    
    @IBAction private func onYesButtonTapped(_ sender: Any) {
        
        guard let tool = selectedTool else {
            print("something went wrong")
           return
        }
        
        onNavigationEvent?(.itemReturned(tool))
        
    }
    
    @IBAction private func onCloseButtonTapped(_ sender: Any) {
        
        onNavigationEvent?(.dismiss)
    }
    
    @IBAction private func onNoButtonTapped(_ sender: Any) {
        
        dismissConfirmationView()
    }
}

extension LoanedItemsViewController {
    
    public struct Configuration {
        
        public let contactsPhoto: String
        public let contactsName: String
        public let loanedItems: [String]
       
        public init(loanedItems: [String],
                    contactsPhoto: String,
                    contactsName: String) {
            self.loanedItems = loanedItems
            self.contactsPhoto = contactsPhoto
            self.contactsName = contactsName
        }
    }
}

extension LoanedItemsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        getBorrowedToolsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "loanToolCell") as! LoanedToolTableVIewCell
        
        let toolName = Array(dictTools)[indexPath.row].key
        let toolCount = Array(dictTools)[indexPath.row].value
        
        guard let imageCell = UIImage(named: "\(toolName)") else { return UITableViewCell()}
        
        cell.configure(toolImage: imageCell, loanedToolCount: "\(toolCount)")
        
        return cell
    }
    
}

extension LoanedItemsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedTool = configuration.loanedItems[indexPath.row]
        self.showConfirmationView()
        self.toastMessage("selected : \(selectedTool)")
    }
}


