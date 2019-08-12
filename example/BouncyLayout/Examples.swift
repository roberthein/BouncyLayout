import UIKit

enum Example {
    case chatMessage
    case photosCollection
    case barGraph
    
    static let count = 3
    
    func controller() -> ViewController {
        return ViewController(example: self)
    }
    
    var title: String {
        switch self {
        case .chatMessage: return "Chat Messages"
        case .photosCollection: return "Photos Collection"
        case .barGraph: return "Bar Graph"
        }
    }
}

class Examples: UITableViewController {
    
    let examples: [Example] = [.chatMessage, .photosCollection, .barGraph]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Examples"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Example.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = examples[indexPath.row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(examples[indexPath.row].controller(), animated: true)
    }
}
