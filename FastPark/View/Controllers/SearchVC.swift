//
//  SearchVC.swift
//  FastPark
//
//  Created by Mert Ziya on 9.02.2025.
//

import UIKit

class SearchVC: UIViewController {
    
    // MARK: - UI Elements:
    @IBOutlet weak var indicatePresentationView: UIView!
    
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var searchResults: UITableView!
    @IBOutlet weak var districtHistoryCollectionView: UICollectionView!
    
    
    @IBOutlet weak var searchedDistrictsHistoryLabel: UILabel!
    @IBOutlet weak var cleanDistrictHistoryButton: UIButton!
    @IBOutlet weak var isSearchHistoryCleanLabel: UILabel!
    
    @IBOutlet weak var autoparksHistoryLabel: UILabel!
    @IBOutlet weak var cleanAutoparksHistoryButton: UIButton!
    @IBOutlet weak var autoparksHistoryCollectionView: UICollectionView!
    @IBOutlet weak var isAutoHistoryCleanLabel: UILabel!
    
    
    // MARK: - Properties:
    private let searchVM = SearchVM()
    private var searchedDistricts : [District] = []{
        didSet{
            DispatchQueue.main.async {
                self.searchResults.reloadData()
                self.updateTableViewHeight()
            }
        }
    }
    private var searchWorkItem: DispatchWorkItem?

    
    // MARK: - Lifecycles:
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureSearchResults()
        setupCollectionViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeKeyboard), name: .presentationShrinked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDistricSelected), name: .districtSelected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePresentationExpanded), name: .presentatonExpanded, object: nil)
        searchVM.delegate = self
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: .presentationShrinked, object: nil)
        NotificationCenter.default.removeObserver(self, name: .districtSelected, object: nil)
    }
}

// MARK: - UI Configurations
extension SearchVC{
    
    private func setupUI(){
        view.backgroundColor = .barBackground
        
        // district history View Configurations:
        cleanDistrictHistoryButton.layer.cornerRadius = 8
        cleanDistrictHistoryButton.setTitle(NSLocalizedString("Clear", comment: ""), for: .normal)
        searchedDistrictsHistoryLabel.text = NSLocalizedString("Districts History", comment: "")
        cleanDistrictHistoryButton.addTarget(self, action: #selector(handleCleanDistricts), for: .touchUpInside)
        
        // Autoparks History View Configurations:
        cleanAutoparksHistoryButton.layer.cornerRadius = 8
        cleanAutoparksHistoryButton.setTitle(NSLocalizedString("Clear", comment: ""), for: .normal)
        autoparksHistoryLabel.text = NSLocalizedString("Autoparks History", comment: "")
        cleanAutoparksHistoryButton.addTarget(self, action: #selector(handleCleanAutoparks), for: .touchUpInside)
        
        isAutoHistoryCleanLabel.text = NSLocalizedString("No History", comment: "")
        isSearchHistoryCleanLabel.text = NSLocalizedString("No History", comment: "")
        
        // Do any additional setup after loading the view.
        indicatePresentationView.layer.cornerRadius = indicatePresentationView.bounds.height / 2
        
        menuButton.layer.cornerRadius = menuButton.bounds.width / 2
        menuButton.clipsToBounds = true
        menuButton.setTitle("", for: .normal)
        menuButton.backgroundColor = .clear
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        
        searchTF.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Search District", comment: ""), attributes: [
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
        let xmarkTapped = UITapGestureRecognizer(target: self, action: #selector(handleEndEditing))
        rightPaddingView.addGestureRecognizer(xmarkTapped)
        
        
        //End Editing when the view is tapped:
        view.isUserInteractionEnabled = true
        let viewTappedGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        viewTappedGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(viewTappedGesture)
        
        searchTF.addTarget(self, action: #selector(searchBarClicked), for: .editingDidBegin)
        searchTF.addTarget(self, action: #selector(textfieldDidChanged(_:)), for: .editingChanged)
    }
   
}





// MARK: - Search Results UI Confiugaration
extension SearchVC : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchedDistricts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = searchResults.dequeueReusableCell(withIdentifier: SearchListCell.reuseID, for: indexPath) as? SearchListCell else{
            return UITableViewCell()
        }
        
        cell.configureSearchCellWith(self.searchedDistricts[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        searchResults.isHidden = true
        let chosenDistrict = self.searchedDistricts[indexPath.row]
        NotificationCenter.default.post(name: .districtSelected, object: chosenDistrict)
    }
    
    func updateTableViewHeight() {
        // Remove existing height constraint if it exists
        if let existingConstraint = searchResults.constraints.first(where: { $0.firstAttribute == .height }) {
            searchResults.removeConstraint(existingConstraint)
        }

        // Apply new height constraint
        var newHeight = 450 * CGFloat(searchedDistricts.count)
        if newHeight > 4 * 100 {newHeight = 400}
        let heightConstraint = searchResults.heightAnchor.constraint(equalToConstant: newHeight)
        heightConstraint.isActive = true

        // Ensure layout updates
        UIView.animate(withDuration: 0.15) { [weak self] in
            self?.searchResults.superview?.layoutIfNeeded()
        }
    }
    
    private func configureSearchResults(){
        searchResults.layer.cornerRadius = 12
        searchResults.clipsToBounds = true
        searchResults.backgroundColor = .barBackground
        
        searchResults.delegate = self
        searchResults.dataSource = self
        searchResults.showsVerticalScrollIndicator = true
        searchResults.canCancelContentTouches = false
        searchResults.register(UINib(nibName: SearchListCell.nibName, bundle: nil), forCellReuseIdentifier: SearchListCell.reuseID)
        
    }
}


// MARK: - Search History Collection View Config:
extension SearchVC : UICollectionViewDelegate , UICollectionViewDataSource{
    
    private func setupCollectionViews(){
        self.districtHistoryCollectionView.backgroundColor = .clear
        self.districtHistoryCollectionView.delegate = self
        self.districtHistoryCollectionView.dataSource = self
        self.districtHistoryCollectionView.alwaysBounceHorizontal = true
        self.districtHistoryCollectionView.register(UINib(nibName: HistoryCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: HistoryCollectionViewCell.reuseID)
        
        self.autoparksHistoryCollectionView.backgroundColor = .clear
        self.autoparksHistoryCollectionView.delegate = self
        self.autoparksHistoryCollectionView.dataSource = self
        self.autoparksHistoryCollectionView.alwaysBounceHorizontal = true
        self.autoparksHistoryCollectionView.register(UINib(nibName: HistoryCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: HistoryCollectionViewCell.reuseID)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == districtHistoryCollectionView{
            if SearchHistoryService.getSearchHistory().count == 0{ self.isSearchHistoryCleanLabel.isHidden = false }
            else{ self.isSearchHistoryCleanLabel.isHidden = true }
            
            return SearchHistoryService.getSearchHistory().count
        }else{
            if SearchHistoryService.getAutoparkHistory().count == 0{ self.isAutoHistoryCleanLabel.isHidden = false }
            else{ self.isAutoHistoryCleanLabel.isHidden = true }
           
            return SearchHistoryService.getAutoparkHistory().count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == districtHistoryCollectionView{
            guard let cell = districtHistoryCollectionView.dequeueReusableCell(withReuseIdentifier: HistoryCollectionViewCell.reuseID, for: indexPath) as? HistoryCollectionViewCell else{
                return UICollectionViewCell()
            }
            
            let selectedDistrict = SearchHistoryService.getSearchHistory()[indexPath.row]
            cell.configureLabelsWith(district : selectedDistrict)
            
            return cell
        }else{
            guard let cell = autoparksHistoryCollectionView.dequeueReusableCell(withReuseIdentifier: HistoryCollectionViewCell.reuseID, for: indexPath) as? HistoryCollectionViewCell else{
                return UICollectionViewCell()
            }
            
            let selectedPark = SearchHistoryService.getAutoparkHistory()[indexPath.row]
            cell.configureLabelsWith(parkDetails: selectedPark)
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == districtHistoryCollectionView{
            let districtSearchHistory = SearchHistoryService.getSearchHistory()
            let chosenDistrict = districtSearchHistory[indexPath.row]
            NotificationCenter.default.post(name: .districtSelected, object: chosenDistrict)
        }else{
            let autoparksSearchHistory = SearchHistoryService.getAutoparkHistory()
            let chosenAutopark = autoparksSearchHistory[indexPath.row]
            NotificationCenter.default.post(name: .autoparkSelected, object: chosenAutopark)
        }
    }
    
    
    
    @objc private func handleCleanDistricts(){
        Alerts.confirmationAlert(on: self, title: NSLocalizedString("Delete History", comment: "" ), message: NSLocalizedString("Are you sure you want to delete history?", comment: "")) {
            SearchHistoryService.clearDistrictHistory()
            self.districtHistoryCollectionView.reloadData()
            HapticFeedbackManager.mediumImpact()
        }
    }
    
    @objc private func handleCleanAutoparks(){
        Alerts.confirmationAlert(on: self, title: NSLocalizedString("Delete History", comment: "" ), message: NSLocalizedString("Are you sure you want to delete history?", comment: "")) {
            SearchHistoryService.clearAutoParkSearchHistory()
            self.autoparksHistoryCollectionView.reloadData()
            HapticFeedbackManager.mediumImpact()
        }
    }
}



// MARK: - Actions:
extension SearchVC{
    @objc private func searchBarClicked(){
        searchResults.isHidden = false
        handleStartEditing()
        NotificationCenter.default.post(name: .searchBarClicked, object: nil, userInfo: nil)
    }
  
    @objc private func closeKeyboard(){
        handleEndEditing()
    }
    
    @objc private func menuButtonTapped(){
        
        NotificationCenter.default.post(name: .menuButtonTapped, object: nil, userInfo: nil)
    }
    
    @objc private func textfieldDidChanged(_ textfield : UITextField){
        // clear search result if textfield is empty:
        if textfield.text == "" {self.searchedDistricts = []}
        
        // Cancel any pending work
        searchWorkItem?.cancel()

        // Create a new work item with your search request
        let workItem = DispatchWorkItem { [weak self] in
            guard let query = textfield.text, !query.isEmpty else { return }
            self?.searchVM.fetchDistricts(query: query)
        }
        
        // Assign to the property
        searchWorkItem = workItem

        // Execute after 0.5 seconds (adjust delay as needed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: workItem)
    }
    
    @objc private func handleEndEditing(){
        searchTF.placeholder = NSLocalizedString("Search District", comment: "")
        searchTF.text = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.textfieldDidChanged(self.searchTF)
            self.searchedDistricts = []
        }
        
        view.endEditing(true)
    }
    
    @objc private func handleDistricSelected(){
        districtHistoryCollectionView.reloadData()
    }
    
    // MARK: - Acts as viewdidLoad
    @objc private func handlePresentationExpanded(){
        DispatchQueue.main.async {
            self.autoparksHistoryCollectionView.reloadData()
        }
    }
    
    private func handleStartEditing(){
        searchTF.text = ""
        searchTF.placeholder = ""
    }
}

extension SearchVC : SearchVMDelegate{
    func didReturnWithError(error: any Error) {
        DispatchQueue.main.async {
            Alerts.showErrorAlert(on: self, title: NSLocalizedString("Warning", comment: ""), message: error.localizedDescription)
        }
    }
    
    // MARK: - Returns the fetched districts shown own table view:
    func didReturnDistricts(districts: [District]) {
        self.searchedDistricts = districts
    }
}
