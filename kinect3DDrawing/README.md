# 3D Drawing

this sketch allows the user to draw in 3D using a Kinect V1.8 and works using hand gesture detection.

To use it you must own a Kinect v 1.8 (usually found with xbox 360).

To setup Kinect in your OS you must download
the respective drivers which can be found [here](https://www.microsoft.com/en-us/download/details.aspx?id=40278)

We make use of the _SimpleOpenNI_ library (v 1.9) to access the Kinect's hand gesture recognition algorithm. to install it
please follow the instructions [here](https://code.google.com/archive/p/simple-openni/). Take into account that this library
requires Processing 2.0 to be used.

Finally we make use of the _Toxiclibs_ library to draw the 3D objects. To install this library follow [These instructions](http://toxiclibs.org/downloads/) 
