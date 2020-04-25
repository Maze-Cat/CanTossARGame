# Can Toss AR Game

This is a can toss AR game. The game is designed based on the Reality Kit and AR Kit technology. This project includes two parts:  ***Project Source Code*** and ***Step-by-Step Tutorial***.

## Game Introduction

1. User first need to move the phone to detect the plane
2. Then put a basket on the place
3. User could choose to throw a soda can or a box
4. Touch the specified location on the screen to throw
5. Gain scores when can/box tossed in the basket
6. When the score is larger than 5, upgrade to next game level: 
Level 1: Static basket
Level 2: Basket moves from left to right
Level 3: Basket spins

Follow the YouTube link here to see a short video of our game: 
[RealityKit AR Game App! Can Toss AR Game](https://youtu.be/3IoP7wfxBVc)


---
# Can Toss AR Game Tutorial (Reality Kit)

This tutorial is a step-by-step approach to creating a complete app - Can Toss AR Game. This game is designed based on the Reality Kit.

## Table of Contents
* [Basic knowledge](#basic-knowledge)
* [Start a project](#start-a-project)
* [Make a model with reality composer](#make-a-model-with-reality-composer)
* [Add sound effect and movement in reality composer](#add-sound-effect-and-movement-in-reality-composer)
* [Make a model programmatically](#make-a-model-programmatically)
* [Place a virtual object at real-world position](#place-a-virtual-object-at-real-world-position)
* [Collision Detection](#collision-detection)
* [Score function & Level function](#score-function-level-function)

## Basic knowledge
There are four basic components in RealityKit:
`ARView`, `Scene`, `Anchor` and `Entity`
The structure of these four are shown in the graph below.

<div align="center">
<img src="/TutorialPic/RealityKitStructure.png" title="Reality Kit Structure" width="600">
</div>

* ***ARView*** - A view that enables you to display an AR experience with RealityKit. We use the view to set up the environment, handle gestures and render 3D graphics to the users.

* ***Scene*** - A container that holds the collection of entities rendered by an AR view. Every ARView has a single scene instance where you can add one or more anchor entities.
* ***Anchor*** - An anchor that tethers virtual content to a real-world object in an AR session.
* ***Entity*** - An element of a RealityKit scene to which you attach components that provide appearance and behavior characteristics for the entity. It is the most important part in RealityKit since entities associates what virtual objects you would like to display with an ARView

Each entity is built up by components.

<div align="center">
<img src="/TutorialPic/EntityComponent.png" title="Entity Component" width="600">
</div>

## Start a project
Open Xcode and start a new project using *File -> New -> Project*.

Then Select the **Augmented Reality App**.

<div align="center">
<img src="/TutorialPic/set-up-project.png" title="Set Up Project" width="600">
</div>

Choose one Product Name and make sure the Language is Swift and the User Interface is Storyboard. The Content Technology should be **RealityKit**.

Finally try to run it on iphone. It shows one 3D box in reality.

### Storyboard setup
Go to the *main.storyboard*. Select the *ARView* and click on *Editor -> Embed In -> Navigation Controller*. Add navigation bar to our app.

Set the title of the *Navigation Item* as 'Can Toss Game'. Add 'refresh' *bar button item* to the navigation bar. This button is used to restart the game.

<div align="center">
<img src="/TutorialPic/set-navigation.png" title="Set Up Navigation Bar" width="600">
</div>

The **ARView** is the main view of our game. The ARView class allows us to display a 3D interactive AR scene using the RealityKit framework. It lets us easily load, manipulate, and render 3D AR content in the application.

Add one *Label* 'Score:' on the top and one *Text View* near it to show the socre. The text view is set to 0 at first. Add one bottle *button* in the bottom. The button is used to change from 'put basket mode' to 'throw bottle mode'. Add one box *button* in the bottom. The button is used to change to 'throw box mode'

Insert two more *View Controller*. Add subview to them. One is a pop up reminder view. One is a a welcome page view.

### ViewController initial setup
Import ARKit framework. Make the ViewController a subclass of *ARSessionDelegate*.

Then override the function *viewDidAppear* to Setup the ARView.

```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    arView.session.delegate = self
    setupARView()
    arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
}

func setupARView() {
    arView.automaticallyConfigureSession = false
    let config = ARWorldTrackingConfiguration()
    config.planeDetection = [.horizontal]
    config.environmentTexturing = .automatic
    arView.session.run(config)
}
```

* ***ARWorldTrackingConfiguration*** - monitors the iOS device's position and orientation while enabling users to augment the environment that's in front of the user.
* ***config.planeDetection = [.horizontal]*** - Add planeDetection to the configuration to detect the horizontal plane.
* ***arView.addGestureRecognizer*** - Enable the gesture recognizer. Attaching a gesture recognizer to a view defines the scope of the represented gesture, causing it to receive touches hit-tested to that view and all of its subviews.

If we touch the screen and no horizontal plane is detected. We designed one pop up view to show the reminder.

```swift
    func popUpReminder() {
        // Vibrate to notify plane detection failed
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        //direct to pop up window
        let popVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "popID") as! PopUpViewController
        self.addChild(popVC)
        popVC.view.frame = self.view.frame
        self.view.addSubview(popVC.view)
        popVC.didMove(toParent: self)

        print("ERROR-- No surface detected")
    }
```

## Make a model with Reality Composer
In Reality Kit Framework, we can use **Reality Composer** app to create a 3D model. Reality Composer could combine 3D models, audio, and other assets together into our project with .rcproject file.

To get Reality Composer for iOS, request access to the beta version from the [Apple Developer download page](https://developer.apple.com/download/). From the Xcode menu, choose Xcode > Open Developer Tool, and select Reality Composer.

When the Reality Composer prompts you to choose an anchor, select *Horizontal*, as we will place our objects on a horizontal plane.

<div align="center">
<img src="/TutorialPic/place-anchor.png" title="place-anchor" width="600">
</div>

Reality Composer offers a large selection of free objects, we choose to add a soda-can as our 3D content.

<div align="center">
<img src="/TutorialPic/add-object.png" title="add-object" width="600">
</div>

To configure an object, select it, and drag it to the coordinate we want. In this project, we place the object in the middle position.

<div align="center">
<img src="/TutorialPic/place-object.png" title="place-object" width="600">
</div>

Reality Composer also supports importing custom 3D Assets from a File. For our wastebasket model, we download a .dae file from the [Turbosquid Website](https://www.turbosquid.com/Search/3D-Models). Then we use the **Reality Converter** app, which could convert, view, and customize USDZ 3D objects on Mac.

<div align="center">
<img src="/TutorialPic/reality-converter.png" title="reality-converter" width="600">
</div>

After getting the USDZ file, just drag it into the Reality Composer so we could have our wastebasket object.

## Add sound effect and movement in Reality Composer
To set the properties of our soda-can object, click on the *Property* button in the Toolbar. We set its Style to be *Stylized*, Motion Type to be *Fixed*, and the material is *Plastic*, Collision Shape is *Sphere*.

<div align="center">
<img src="/TutorialPic/set-property.png" title="set-property" width="600">
</div>

We want to trigger movement and sound when the object shows up, it is enabled in the object behaviors. So click the *Behaviors* button in the Toolbar to reveal the Behaviors setting, and then click the plus button. We choose to set the trigger to be Scene Start, so when the user taps the screen and the soda-can shows up, the action and sound begin. To set the movement, add Bounce emphasize to the object. Also, add the sound playing effect.

<div align="center">
<img src="/TutorialPic/set-behavior.png" title="set-behavior" width="600">
</div>

After we finish building our objects, we need to add it to our PaperToss Project. Click File > Save in the menu to save the models as a .rcproject file. Then drag this file directly into the navigation pane of our Xcode project. Xcode will automatically generate a class for the scene in an enumeration with the name of our .rcproject file.

We call the load method to get the Reality Composer scene’s anchor, the properties and behaviors we set to objects will exist as children of the anchor entity. Then we could add the anchor to AR view.

```swift
guard let bottle = try? Drink.loadScene() else {return}
arView.scene.anchors.append(bottle)
 ```

## Make a model programmatically
We can also generate some simple 3D shapes with RealityKit framework, such as spheres and boxes. For example, we can initilize an model entity by specifying meshes and materials to control the appearance of the model. Fortunately, RealityKit has provided us `MeshResource` as a mesh generator to create simple shape like boxes and spheres.

```swift
let box = MeshResource.generateBox(size: 0.3)

let boxEntityA = ModelEntity(mesh: box)
```

We can also determine the material we want to apply to our model.

```swift
let material = SimpleMaterial(color: .yellow, isMetallic: false)

let boxEntityB = ModelEntity(mesh: box, materials: [material])
```

In order to display our entity in our `ARView`, we need to make sure that this entity is added as a child to an anchor or the entity class satisfy the `HasAnchoring` protocol, which enables anchoring of virtual content to a real-world object in an AR scene.

```swift
let anchor = AnchorEntity(plane: .horizontal)

arView.scene.addAnchor(anchor)

anchor.addChild(boxEntityB)
```

## Place a virtual object at real-world position
We want our app to allow recognize touch gesture on the screen and place a corresponding virtual object in the real-world environment. To do this, we first need to set up a tap gesture recognizer in our `ARView`.

```swift
arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
```

This line of code enables a tap gesture recognizer and whenever the user touch the screen, it will call our `handleTap` function to deal with the request.

In order to find a 3D point in the real-world environment, we need the ray-casting method to convert our 2D point from the user's touch screen to a 3D point in the real-world. In short, ray-casting method is an algorithm that help us to create a 3D perspective in a 2D map.This is the preferred method for finding positions on surfaces in the real-world environment. And the `ARView` has already provided us with such method.

```swift
@objc
func handleTap(recognizer:UITapGestureRecognizer) {
    let location = recognizer.location(in: arView)

    /* To get a 3D world position that corresponds to the tap location, cast a ray from the camera’s origin through the touch location to check for intersection with any real-world surfaces along that ray.
    */
    // return an array of horizontal surfaces detected
    guard let raycastResult = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any).first else {
        popUpReminder()
        return
    }
    //map the tapped point into the 3D coordinate space
    let goal =  arView.unproject(location, ontoPlane: raycastResult.worldTransform)
    gameController.putThing(arView, scoreText, goal!)
}
```
* ***raycastResult*** - we first pass our location of the touch point on the screen to ray-casting method and get the result. This returned result is an array of ray-cast results, sorted from nearest to farthest from the camera. We only take the first result from the array in this example.
* ***popUpReminder*** - in case the ray cast method fail, it will pop up the reminder to inform the user
* ***arView.unproject*** - this method maps a 2D point from the view’s coordinate system onto the given plane in 3D space. In our example, this method creates a 3D point in the real-world from the touch location and the ray-casting result.
* ***gameController.putThing*** - Now that we have the 3D point in the real world, we can finally put our virtual object in that position.


Every `ARView` consists of a scene, which is a container that holds the collection of entities rendered by an AR view. And all virtual objects we would like to add to our `ARView` is called entities. In our example, we want to position models(bottle and basket) made in Reality Composer into a scene.
```swift
func putThing(_ arView: ARView, _ scoreText: UITextView, _ goal: simd_float3) {
        switch status {
        case .Bottle:
            guard let bottle = try? Drink.loadScene() else {return}
            //position the entity at the tap location
            bottle.position = goal
            arView.scene.anchors.append(bottle)
        default:
            guard let basket = try? Basket.loadScene() else { return }
            //position the entity at the tap location
            basket.position = goal
            arView.scene.anchors.append(basket)
        }
    }
```
* ***Drink.loadScene() & Basket.loadScene()*** - These two methods loads an entity from the model we created in the reality composer. We call these load methods to get the Reality Composer scene’s anchor, so that we can then add the anchor to our `ARView` scene’s anchor collection. The virtual baskets and bottles can therefore appear in our app while displaying the AR view.
* ***status*** - this variable determines whether the user want to add a basket or a bottle


## Collision detection
In our Can Toss Game, we want to score when a can is tossed into the bin. To realize this function, we have to detect the collisions between bins and cans. We first need to generate the collision shape of our model by calling the function. It creates collision shapes for model entities by recursively visiting all children and generatingcollsion shapes for all entities in this subtree. The collision shape is stored in the `CollisionComponent`.

```swift
public func generateCollisionShapes(recursive: Bool)
```
Once we generate collision shapes for all our models, we can start to detect coliisions. First, we should enable our scene to receive an collsion event.

```swift
arView.scene.subscribe(to: CollisionEvents.Began.self, on: basket)
```
* ***CollisionEvents.Began.self*** - Event raised when a collision between two objects was detected.
* ***basket*** - The model for trash bin in our game

We will loop through all baskets we previously added to check for collisions and add these events into a ` subscriptions ` array to record all subscriber relationships. Also notice that, we are calling this method from the side of cans, because they are the objects that hit the baskets. In this way, we connect the cans and baskets through subscriptions.

```swift
for basket in baskets {
    let subscription = arView.scene.subscribe(to: CollisionEvents.Began.self, on: basket) { event in
        self.score += 1
        scoreText.text = String(self.score)
        self.subscriptions.removeAll()
    }
    subscriptions.append(subscription)
}
```

## Score function & Level function
We designed the game with three levels. In the first level, the basket is static. In the second level, the basket model should contain animation - moving from one side to another side and repeating. In the last level, the basket spins. In each level, users should get 5 scores and then change to next level.

We maintain two variables *level* and *score* to track the game status. When detecting the collision between *drink* and *basket*, the score will add one. Every time the score adds to five, the level will add one.

```swift
    var level = 1
    var score = 0 {
        didSet {
            if score == 5 {
                level += 1
                restart()
                if level == 2 {
                    showAlertMsg(title: "Level Up!", message: "Go to level 2", time: 5)
                    gameController.setMovingBin()
                } else if level == 3 {
                    showAlertMsg(title: "Level Up!", message: "Go to level 3", time: 5)
                    gameController.setRotatingBin()
                } else {
                    showAlertMsg(title: "You win!", message: "Retry!", time: 5)
                    level = 1
                }
            }
        }
    }
```

When level changes, all objects are cleared. And different models are loaded.

