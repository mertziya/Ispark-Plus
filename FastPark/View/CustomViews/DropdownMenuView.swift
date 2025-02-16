//
//  DropdownMenuView.swift
//  FastPark
//
//  Created by Mert Ziya on 15.02.2025.
//


import UIKit

class DropdownMenuView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    var items: [String] = []
    var selectionHandler: ((String) -> Void)?
    
    private let tableView = UITableView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .white
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 8
        clipsToBounds = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isUserInteractionEnabled = true
        tableView.allowsSelection = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        addSubview(tableView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds
    }
    
    func show(items: [String], from button: UIButton, in parentView: UIView) {
        self.items = items
        tableView.reloadData()
        
        let buttonFrame = button.convert(button.bounds, to: parentView)

        // Show below the button (or above if not enough space)
        let dropdownHeight = min(CGFloat(items.count) * 44, 44 * 3)
        let maxY = buttonFrame.maxY + 8
        let bottomSpace = parentView.bounds.height - maxY
        
        if bottomSpace >= dropdownHeight {
            // Enough space below
            frame = CGRect(x: buttonFrame.minX, y: maxY, width: buttonFrame.width, height: dropdownHeight)
        } else {
            // Not enough space below, show above
            frame = CGRect(x: buttonFrame.minX, y: buttonFrame.minY - dropdownHeight - 8, width: buttonFrame.width, height: dropdownHeight)
        }

        parentView.addSubview(self)
    }
    
    func hide() {
        DispatchQueue.main.async {
           self.removeFromSuperview()
       }
    }

    // MARK: - UITableView DataSource & Delegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = items[indexPath.row]
        selectionHandler?(selectedItem)
        hide()
    }
}
