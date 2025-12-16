import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func loadImage(from urlString: String) {
        // 1. Check Cache
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        // 2. Set Default Placeholder while loading
        // If "tiger.png" is in your Assets, use it here. Otherwise use system icon.
        self.image = UIImage(named: "tiger.png") ?? UIImage(systemName: "person.crop.circle.fill")
        
        // 3. Download
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil, let image = UIImage(data: data) else { return }
            
            imageCache.setObject(image, forKey: urlString as NSString)
            
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
