# Requirements
## High Level Requirements
* Create binary in-game controls to simplify analysis of EMG data since user controls will be received serially in binary form (i.e., simple commands such as up, down, right, left).
* Accessibility and learning curve of the videogame should be easy, so that a high capacity of adaptation is not required to be able to get used to the videogame quickly.
* Adaptation to a generic audience. 
* Competitive games, since studies [1] suggest that a non-competitive game without levels, when completed, becomes a repetitive and monotonous task.

## Technical Requirements
### Hardware connection
This should be done automatically. With a synchronization method so that the game can run autonomously and when there is a Serial connection, it can be used. This system is commonly called "plug&play".
### Static 2D environments
Those elements that remain static should be rendered last because dynamic objects can not overlap over static elements. It is possible to render in 3D and generate the static elements in the axis z = 0, and the other objects with z < 0.
### Background image
This should be generated the first one. The image is at developer's choice, which can be random by changing the image for each execution of the game.
### Avatar
The avatar will be a type of object, in which, as a minimum, it will have stored its current turn and the position of the sword (up or down). 
### Dynamic objects
Dynamic objects will be an array of objects of a special type of object. These objects must have at least their current rotation, velocity vector and position. In addition, special destruction effects (e.g. splitting in two) may be included. Their reappearance (left or right) and the angle of inclination with respect to the plane must be random.
Its corresponding icon must also be random within a set of pre-selected images.
In addition, a certain level of difficulty can be added at the runtime or after a certain score, for example, with the rate of spawn of objects and their speed, which can be increased significantly.
### Target panel
In the target panel, an object of the same type as the dynamic objects should be displayed at a certain random time (between 2 and 5 seconds, variable with time). The destroyed object, when making a cut on a dynamic object by the user, will be compared with this object.
### Score panel
This panel shows the current score starting with 0. When the user makes a cut and matches the current object in the target panel, the value increases.
### Calibration panel
It is probable that for the initial phases of the project some type of panel will have to be made for the initial calibration of the device. An interface can be designed to adjust the sensitivity of the device. Using the user calibration as a pre-game loading screen, similar to the wii controls.
