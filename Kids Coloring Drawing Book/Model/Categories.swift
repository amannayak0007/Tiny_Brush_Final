
import UIKit

enum CategoryType: Int {
    case Animal, Fruit, Vehicle, Shape, People, Nature, Geometry, Christmas
}

class Categories {

    var title: String
    var featuredImage: UIImage
    var color: UIColor
    var categoryType: CategoryType
    
    init(title: String, featuredImage: UIImage, color: UIColor, categoryType: CategoryType) {
        self.title = title
        self.featuredImage = featuredImage
        self.color = color
        self.categoryType = categoryType
    }
    
    // dummy data
    static func fetchHomeCategories() -> [Categories] {
        return [
            Categories(title: "", featuredImage: UIImage(named: "christmasBG")!, color: UIColor.clear, categoryType: .Christmas),
            
            Categories(title: "", featuredImage: UIImage(named: "people_bg")!, color: UIColor.clear, categoryType: .People),
            
            Categories(title: "", featuredImage: UIImage(named: "geometry_bg")!, color: UIColor.clear, categoryType: .Geometry),
            
            Categories(title: "", featuredImage: UIImage(named: "vehicle_bg")!, color: UIColor.clear, categoryType: .Vehicle),
            
            Categories(title: "", featuredImage: UIImage(named: "animalBG")!, color: UIColor.clear, categoryType: .Animal),
            
            Categories(title: "", featuredImage: UIImage(named: "nature_bg")!, color: UIColor.clear, categoryType: .Nature),
            
            Categories(title: "", featuredImage: UIImage(named: "fruitBG")!, color: UIColor.clear, categoryType: .Fruit),
            
            Categories(title: "", featuredImage: UIImage(named: "shapMatch")!, color: UIColor.clear, categoryType: .Shape)
        ]
    }
}
