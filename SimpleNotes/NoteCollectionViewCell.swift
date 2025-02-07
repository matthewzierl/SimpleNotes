import UIKit

class NoteCollectionViewCell: UICollectionViewCell {
    var noteView: UIImageView!
    var title: UILabel!
    var cellNote: Note?
    
    var notSelectedImage: UIImageView!
    var selectedImage: UIImageView!
    var isEditMode = false {
        didSet {
            if isEditMode {
                notSelectedImage.isHidden = false
            } else {
                notSelectedImage.isHidden = true
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    override var isSelected: Bool {
        didSet {
            if isEditMode {
                notSelectedImage.isHidden = isSelected // circle
                selectedImage.isHidden = !isSelected // checkmark circle
                if isSelected {
                    noteView.layer.borderWidth = 3
                } else {
                    noteView.layer.borderWidth = 0
                }
            } else {
                if isSelected {
                    noteView.layer.borderWidth = 3
                } else {
                    noteView.layer.borderWidth = 0
                }
            }
            
        }
    }
    
    
    private func setupViews() {
        // Configure noteView
        noteView = UIImageView()
        noteView.backgroundColor = .systemGray5
        noteView.layer.cornerRadius = 8
        noteView.translatesAutoresizingMaskIntoConstraints = false
        noteView.layer.borderWidth = 0
        noteView.layer.borderColor = CGColor(red: 0, green: 0, blue: 1, alpha: 1)
        
        contentView.addSubview(noteView)
        
        
//        // Set the correct target size for rendering
//        let targetSize = CGSize(width: 100, height: 80)
//        
//        // Create the renderer with the target size
//        let renderer = UIGraphicsImageRenderer(size: targetSize)
//        
//        let image = renderer.image { context in
//            
//            context.cgContext.setFillColor(UIColor.blue.cgColor)
//            
//            let rect = CGRect(x: .zero, y: .zero, width: 20, height: 40)
//            
//            context.cgContext.fill(rect)
//        }
//        
//        noteView.image = image
        
        // Configure title label
        title = UILabel()
        title.text = cellNote?.title
        title.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        title.numberOfLines = 2
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(title)
        
        // Configure selection overlays
        notSelectedImage = UIImageView(image: UIImage(systemName: "circle"))
        notSelectedImage.isHidden = true // Initially hidden
        notSelectedImage.layer.position = CGPoint(x: 56, y: 60)
        contentView.addSubview(notSelectedImage)
        
        selectedImage = UIImageView(image: UIImage(systemName: "checkmark.circle"))
        selectedImage.isHidden = true
        selectedImage.layer.position = CGPoint(x: 56, y: 60)
        contentView.addSubview(selectedImage)
        
        // Set up constraints for noteView
        NSLayoutConstraint.activate([
            noteView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            noteView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            noteView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            noteView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.7)
        ])
        
        // Set up constraints for title
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: noteView.bottomAnchor, constant: 5),
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            title.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }

}
