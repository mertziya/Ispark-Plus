//
//  ParkAnnotationView.swift
//  FastPark
//
//  Created by Mert Ziya on 10.02.2025.
//

import Foundation
import UIKit
import MapKit

class ParkAnnotationView: MKAnnotationView {

    let bottomTriangle = UIImageView() // for creating the buttom section of the bubble like appeareance
    
    private let titleLabel = UILabel()
    private var annotationFrame = CGRect(){
        didSet{
            updateAnnotationFrame(annotationFrame: annotationFrame)
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        self.frame = CGRect(x: 0, y: 0, width: 120, height: 60) // Adjust size
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.clipsToBounds = false

        // bottom line
        bottomTriangle.image = UIImage(systemName: "arrowtriangle.down.fill")
        bottomTriangle.tintColor = .white
        addSubview(bottomTriangle)
        
        // Title Label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        titleLabel.textColor = .black
        addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomTriangle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 4),
            
            bottomTriangle.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            bottomTriangle.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -4),
            bottomTriangle.heightAnchor.constraint(equalToConstant: 12),
            bottomTriangle.widthAnchor.constraint(equalToConstant: 12),
            
        ])

    }
    
    private func updateAnnotationFrame( annotationFrame: CGRect){
        self.frame = annotationFrame
    }

    func configure(with annotation: ParkAnnotation) {
        titleLabel.text = annotation.title
        annotationFrame = annotation.annotationFrame ?? CGRect(x: 0, y: 0, width: 50, height: 20)
        if annotation.isOpen! {
            guard let fullness = annotation.fullness else{return}
            switch fullness{
            case ..<0.5:
                self.backgroundColor = .systemGreen
                bottomTriangle.tintColor = .systemGreen
            case 0.5...0.7:
                self.backgroundColor = .systemYellow
                bottomTriangle.tintColor = .systemYellow
            case 0.7...0.9:
                self.backgroundColor = .systemOrange
                bottomTriangle.tintColor = .systemOrange
            case 0.9...1.0:
                self.backgroundColor = .systemRed
                bottomTriangle.tintColor = .systemRed
            default:
                break
            }
        }else{
            // TODO: - Handle the closed annotation view here
        }
    }
}
