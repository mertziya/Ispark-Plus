//
//  SideBarVC.swift
//  FastPark
//
//  Created by Mert Ziya on 9.02.2025.
//

import UIKit

class SideBarVC: UIViewController {

    // MARK: - UI Elements:
    @IBOutlet weak var sideBarContentView: UIView!
    @IBOutlet weak var swipeIndicatorView: UIView!
    
    @IBOutlet weak var favoritesTableView: UITableView!
    @IBOutlet weak var favoritesLabel: UILabel!
    @IBOutlet weak var favoritesAmountLabel: UILabel!
    @IBOutlet weak var editFavoritesButton: UIButton!
    
    
    @IBOutlet weak var settingsLabel: UILabel!
    
    @IBOutlet weak var darkmodeLabel: UILabel!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var languageMenuButton: UIButton!
    private var dropdownMenuView: DropdownMenuView?
    
    
    // MARK: - Properties:
    
    private var favorites : [ParkDetails] = []{
        didSet{
            DispatchQueue.main.async {
                self.favoritesAmountLabel.text = "\(self.favorites.count) / 30"
                self.favoritesTableView.reloadData()
            }
        }
    }
    
    private var isEditingFavorites : Bool = false{
        didSet{
            DispatchQueue.main.async {
                self.favoritesTableView.reloadData()
            }
        }
    }
    
    
    // MARK: - Lifecycles:
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        setupFavoritesUI()
        
        setupSettingsUI()
        
        fetchFavorites()
        
        addEndEditingGestureToView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleFavoritesUpdated(_:)), name: .favoritesUpdated, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .favoritesUpdated, object: nil)
    }

}


// MARK: - UI Configurations:
extension SideBarVC{
    private func setupUI(){
        
        
        
        // Setup Main View layout and actions
        view.backgroundColor = .clear
        sideBarContentView.layer.cornerRadius = 24
        swipeIndicatorView.layer.cornerRadius = 4 / 2
        sideBarContentView.isUserInteractionEnabled = true
        let sidebarSwipeRightGesture = UIPanGestureRecognizer(target: self, action: #selector(dragView(_:)))
        sideBarContentView.addGestureRecognizer(sidebarSwipeRightGesture)
    }
}


// MARK: - Setup favorites section UI
extension SideBarVC : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = favoritesTableView.dequeueReusableCell(withIdentifier: FavoritesTableViewCell.reuseID, for: indexPath) as? FavoritesTableViewCell else{
            return UITableViewCell()
        }
        cell.configureDeleteFavoritesButton(isEditing: isEditingFavorites)
        
        cell.configureCell(favorites[indexPath.row])
        
        addLongPressGestureToCell(cell: cell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAutoparkDetails = self.favorites[indexPath.row]
        NotificationCenter.default.post(name: .autoparkSelected, object: selectedAutoparkDetails)
        NotificationCenter.default.post(name: .shouldHideSideBar, object: nil)
    }
    
    private func setupFavoritesUI(){
        
        favoritesLabel.text = NSLocalizedString("Favorites:", comment: "")
        editFavoritesButton.setTitle(NSLocalizedString("Edit", comment: ""), for: .normal)
        editFavoritesButton.addTarget(self, action: #selector(editFavorites), for: .touchUpInside)
        
        favoritesTableView.delegate = self
        favoritesTableView.dataSource = self
        favoritesTableView.backgroundColor = .clear
        favoritesTableView.showsVerticalScrollIndicator = false
        favoritesTableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        
        favoritesTableView.register(UINib(nibName: FavoritesTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: FavoritesTableViewCell.reuseID)
    }
    
   
    
    private func addLongPressGestureToCell(cell : FavoritesTableViewCell){
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressed(_:)))
        longPress.cancelsTouchesInView = true
        longPress.minimumPressDuration = 0.5
        cell.addGestureRecognizer(longPress)
    }
    
    @objc private func cellLongPressed(_ gesture : UILongPressGestureRecognizer){
        if gesture.state == .began{
            editFavorites()
        }
    }
    
    @objc private func fetchFavorites(){
        self.favorites = FavoritesService.getFavorites()
    }
    
}




// MARK: - Setup Settings UI & UX:
extension SideBarVC{
    private func setupSettingsUI(){
        settingsLabel.text = NSLocalizedString("Settings:", comment: "")
        darkmodeLabel.text = NSLocalizedString("Dark Mode", comment: "")
        languageLabel.text = NSLocalizedString("Language", comment: "")
        
        
        languageMenuButton.setTitle(UserDefaults.standard.string(forKey: "AppLanguageString"), for: .normal)
        languageMenuButton.contentHorizontalAlignment = .center
        
        darkModeSwitch.addTarget(self, action: #selector(changeTheme), for: .valueChanged)
        darkModeSwitch.isOn = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
        
        languageMenuButton.addTarget(self, action: #selector(menuButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc private func changeTheme() {
        let isDarkMode = darkModeSwitch.isOn
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkModeEnabled")

        if #available(iOS 13.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            window?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        } else {
            // Handle older iOS versions if needed
            // (e.g., present an alert that dark mode is only available on iOS 13 and later)
            
            // This app is IOS 13+ so it would be fine.
        }
    }
    
    
    
    // MARK: - Change Language:
    @objc private func menuButtonTapped(_ sender : UIButton){
        if let dropdownMenuView = dropdownMenuView {
            dropdownMenuView.hide()
            self.dropdownMenuView = nil
        } else {
            let dropdown = DropdownMenuView()
            
            let systemString = NSLocalizedString("Default", comment: "")
            let englishString = NSLocalizedString("English", comment: "")
            let turkishString = NSLocalizedString("Turkish", comment: "")
            
            dropdown.show(items: [systemString, turkishString ,englishString], from: sender, in: view)

            dropdown.selectionHandler = { [weak self] selectedItem in

                // Change the App Language (example approach)
                self?.changeLanguage(to: selectedItem)
                
                self?.dropdownMenuView = nil
            }

            // Tap outside to dismiss
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDropdown))
            tapGesture.cancelsTouchesInView = false
            view.addGestureRecognizer(tapGesture)
            view.isUserInteractionEnabled = true

            dropdownMenuView = dropdown
        }
    }
    
    @objc private func dismissDropdown() {
       dropdownMenuView?.hide()
       dropdownMenuView = nil
    }
    
    func changeLanguage(to language: String) {
        var languageCode = ""
        switch language {
        case NSLocalizedString("English", comment: ""):
            languageCode = "en"
        case NSLocalizedString("Turkish", comment: ""):
            languageCode = "tr"
        case NSLocalizedString("Default", comment: ""):
            languageCode = Locale.preferredLanguages.first ?? "en" // Fallback to system language
        default:
            languageCode = Locale.preferredLanguages.first ?? "en"
        }

        // Save the preferred language to UserDefaults
        UserDefaults.standard.setValue(languageCode, forKey: "AppLanguage")
        UserDefaults.standard.synchronize()
        
        
        UserDefaults.standard.setValue(language, forKey: "AppLanguageString")


        // Change language at runtime
        Bundle.setLanguage(languageCode)

        // Set the Root View Controller Again (to reflect new language)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        let rootViewController = MainVC()
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()

        // Optional: Transition Animation
        let transition = CATransition()
        transition.type = .fade
        transition.duration = 0.3
        window.layer.add(transition, forKey: "languageChangeTransition")
    }
    
}




// MARK: - Actions:
extension SideBarVC{
    
    @objc private func editFavorites(){
        HapticFeedbackManager.mediumImpact()
        if editFavoritesButton.titleLabel?.text == NSLocalizedString("Edit", comment: ""){
            editFavoritesButton.setTitle(NSLocalizedString("Bitir", comment: ""), for: .normal)
            isEditingFavorites = true
        }else{
            editFavoritesButton.setTitle(NSLocalizedString("Edit", comment: ""), for: .normal)
            isEditingFavorites = false
        }
    }
    
    @objc private func endEditingFavorites(){
    
        editFavoritesButton.setTitle(NSLocalizedString("Edit", comment: ""), for: .normal)
        isEditingFavorites = false
    
    }
    
    private func addEndEditingGestureToView(){
        let viewTappedGesture = UITapGestureRecognizer(target: self, action: #selector(endEditingFavorites))
        viewTappedGesture.cancelsTouchesInView = false
        self.sideBarContentView.addGestureRecognizer(viewTappedGesture)
    }
    
    @objc private func handleFavoritesUpdated(_ notification : Notification){
        guard let parkDetails = notification.object as? ParkDetails else{return}
        
        Alerts.confirmationAlert(on: self,
                                 title: NSLocalizedString("Remove from favorites", comment: ""),
                                 message: NSLocalizedString("Are you sure you want to remove this park from favorites?", comment: "")) {
            
            FavoritesService.removeFromFavorites(parkDetails)
            self.fetchFavorites()
        }
    }
    
    // Handle closing the sidebar smoothly
    @objc private func dragView(_ gesture : UIPanGestureRecognizer){
        let translation = gesture.translation(in: sideBarContentView)
        let isSwipedRightReallyFast = gesture.velocity(in: sideBarContentView).x > 1000
        var newX: CGFloat = 0
        
        switch gesture.state{
        case .changed,.began:
            newX = translation.x + 24 // 24 is the distance of sidebarcontentview from view initially
            if newX < 24 {newX = 24}
            sideBarContentView.frame = CGRect(x: newX,
                                              y: sideBarContentView.frame.minY,
                                              width: sideBarContentView.bounds.width,
                                              height: sideBarContentView.bounds.height)
        case .ended:
            if sideBarContentView.frame.minX > 80 || isSwipedRightReallyFast{
                view.frame = CGRect(x: sideBarContentView.frame.minX + 40,
                                    y: view.frame.minY,
                                    width: view.bounds.width,
                                    height: view.bounds.height)
                NotificationCenter.default.post(name: .shouldHideSideBar, object: nil)
            }else{
                UIView.animate(withDuration: 0.2) { [self] in
                    self.sideBarContentView.frame = CGRect(x: 24,
                                                      y: sideBarContentView.frame.minY,
                                                      width: sideBarContentView.bounds.width,
                                                      height: sideBarContentView.bounds.height)
                }
            }
        default:
            break
        }
    }
    
}
