# TVPickerView
Picker View style control for tvOS

The `TVPickerView` behaves like any other focusable element. To enable selection, press on the picker while it is in focus. This then allows swiping left and right to scroll through content. Pressing on the arrow keys is also supported.

![Image](https://raw.githubusercontent.com/Jugale/TVPickerView/master/picker.png)

Click [here](https://youtu.be/GW-F-5AjHYQ) for a demo on YouTube

###Implementation

Have a look at the demo to learn how to implement. You can add the picker from a storyboard, or programmatically.

There is a file called `TVPickerViewInterfaces.swift` ([here](https://github.com/Jugale/TVPickerView/blob/master/TVPickerView/TVPickerViewInterfaces.swift)) in which you can see all the protocols that you need to be aware of. The `TVPickerView` object itself conforms to `TVPickerInterface`, so use that to determine which methods you may call. Documentation can be found above each declaration.

This repository's xcode project has a target to build the `TVPickerView` as a Framework - Carthage doesn't seem to support `appletvos` yet, so you won't be able to add it from a Cartfile until later. Not a fan of CocoaPods, but feel free to fork and add it if you wish.


###Things to note:
- Scrolling to a particular index doesn't seem to work on the Simulator, not sure why
- Resizing the picker after instantiation is not supported. Keep it's width and height fixed!
- Only four views are loaded at a time, and they they are reused.
