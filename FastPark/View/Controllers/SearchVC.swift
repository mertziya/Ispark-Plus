//
//  SearchVC.swift
//  FastPark
//
//  Created by Mert Ziya on 9.02.2025.
//

import UIKit

class SearchVC: UIViewController {
    
    @IBOutlet weak var indicatePresentationView: UIView!
    
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var menuButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeKeyboard), name: .presentationShrinked, object: nil)

    }

    deinit{
        NotificationCenter.default.removeObserver(self, name: .presentationShrinked, object: nil)
    }
}

// MARK: - UI Configurations
extension SearchVC{
    
    private func setupUI(){
        view.backgroundColor = .barBackground
        
        // Do any additional setup after loading the view.
        indicatePresentationView.layer.cornerRadius = indicatePresentationView.bounds.height / 2
        
        menuButton.layer.cornerRadius = menuButton.bounds.width / 2
        menuButton.clipsToBounds = true
        menuButton.setTitle("", for: .normal)
        menuButton.backgroundColor = .clear
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        
        searchTF.attributedPlaceholder = NSAttributedString(string: "Semt Ara", attributes: [
            .foregroundColor : UIColor.logo
        ])
        
        // Setup the left view of textfield
        let magnifyingGlass = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        magnifyingGlass.tintColor = .logo
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35)) // Adjust width as needed
        magnifyingGlass.frame = CGRect(x: 5, y: 5, width: 25, height: 25) // Adjust positioning
        leftPaddingView.addSubview(magnifyingGlass)
        searchTF.leftView = leftPaddingView
        searchTF.leftViewMode = .always

        // Setup the right view of textfield
        let xmarkIcon = UIImageView(image: UIImage(systemName: "xmark"))
        xmarkIcon.tintColor = .logo
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30)) // Adjust width as needed
        xmarkIcon.frame = CGRect(x: 5, y: 7, width: 16, height: 16) // Adjust positioning
        rightPaddingView.addSubview(xmarkIcon)
        searchTF.rightView = rightPaddingView
        searchTF.rightViewMode = .whileEditing
        
        rightPaddingView.isUserInteractionEnabled = true
        let xmarkTapped = UITapGestureRecognizer(target: self, action: #selector(xmarkTapped))
        rightPaddingView.addGestureRecognizer(xmarkTapped)
        
        
        //End Editing when the view is tapped:
        view.isUserInteractionEnabled = true
        let viewTappedGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(viewTappedGesture)
        
        searchTF.addTarget(self, action: #selector(searchBarClicked), for: .editingDidBegin)
    }
   
}


// MARK: - Actions:
extension SearchVC{
    @objc private func searchBarClicked(){
        handleStartEditing()
        NotificationCenter.default.post(name: .searchBarClicked, object: nil, userInfo: nil)
    }
  
    @objc private func closeKeyboard(){
        handleEndEditing()
    }
    
    @objc private func menuButtonTapped(){
        NotificationCenter.default.post(name: .menuButtonTapped, object: nil, userInfo: nil)
    }
    
    @objc private func xmarkTapped(){
        handleEndEditing()
        view.endEditing(true)
    }
    
    private func handleStartEditing(){
        searchTF.placeholder = ""
    }
    private func handleEndEditing(){
        view.endEditing(true)
        searchTF.placeholder = "Semt Ara"
        searchTF.text = ""
    }
}
