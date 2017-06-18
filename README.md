# MovableCellTableViewProtocol
🔨A Swift Protocol Extension For Moveable Cell TableView

### Usage

1. Implement the extension properties in your UIViewController which has a UITableView to move cell.
2. Call the `addMoveCellForTableView()` in `viewDidLoad()` to initialize some  configuration for the UITableView.
3. Implement the `MoveableCell` protocol for your UITableViewCell and call the `self.toggleMoving(false)` in `prepareForReuse()`
4. Implement the `MoveableCellTableViewProtocol` protocol for your UIViewController
5. Move the Cell !!!

#### Implement Properties
```
// MARK: - MovableCellTableViewProtocol Property
// property for moving row
var snapshot: UIView!
var sourceIndexPath: IndexPath!
var originIndexPath: IndexPath!
var lastPosition: NSValue!
var movingRowGesture: UILongPressGestureRecognizer!
// property for tableview auto scroll
var autoscrollDistance: CGFloat = 0
var autoscrollTimer: Timer?
var isTableViewBelowNavigationBar: Bool = true
```

> You should implement these properties in the UIViewController which has a UITableView to move. If your UIViewController has a UINavigationBar, please set isTableViewBelowNaviationBar to true, otherwise false.

####  Implement delegate
```
func longPressGestureAction(_ recognizer: UIGestureRecognizer) {
    handleLongPressGesture(recognizer) // You should call the method here.
}
    
func autoscrollTimerAction(_ timer: Timer) {
    autoscrollTimerFired(timer) // You should call the method here.
}

func moveableCellTableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    // You should exchange the position data in your dataset
}

func moveableCellTableView(_ tableView: UITableView, didEndMoveRowAt originIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    // The function called when you finish move, you can do network request here
}

func moveableCellTableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    return true // If you don't want some cell to be moved, return false
}

func moveableCellTableView(_ tableView: UITableView, shouldMoveRowAt indexPath: IndexPath, to destinationIndexPath: IndexPath) -> Bool {
    return true // If you dont't want some cell to be moved to the destinationIndexPath, return false
}

func moveableCellTableView(_ tableView: UITableView, snapshotStartMovingAnimation snapshot: UIView) {
    // custom moving cell snapshot animation when snapshot starts moving
}

func moveableCellTableView(_ tableView: UITableView, snapshotEndMovingAnimation snapshot: UIView) {
    // custom moving cell snapshot animation when snapshot ends moving
}
```

> Because of selector in protocol extension is not supported, so you have to implement the `longPressGestureAction(\_:)` and `autoscrollTimerAction(\_:)` and call the `handleLongPressGesture(\_:)` and `autoscrollTimerFired(\_:)`. If you have a better solution for it, please pull request.

### Customize
You can customize your snapshot in the UITableViewCell.

```
extension YourCell: MoveableCell {
    var moveableSnapshot: UIView {
        // Custom Snapshot Code Here
    }
}
```

If you want to customize your snapshot animation when moving, please check the `snapshotStartMovingAnimation` and `snapshotEndMovingAnimation` in `MoveableCellTableViewProtocol`

## Minimum Requirement
iOS 8.0

## License
MovableCellTableViewProtocol is released under the MIT license. See [LICENSE](https://github.com/StormXX/MoveableCellTableViewProtocol/blob/master/LICENSE) for details.

## More Info
Have a question? Please [open an issue](https://github.com/StormXX/MoveableCellTableViewProtocol/issues/new)!

