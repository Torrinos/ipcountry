# ipcountry
A lightweight utility for Mac OS X (tested on 10.11.5) to display the IP and country code in the Menu Bar. As a frequent VPN user I wrote it to be able to see easily the location of the VPN server I am currently connected to.

![Image of Yaktocat](https://github.com/Torrinos/ipcountry/blob/master/ipcountry.png)

The app uses the free [ip GEO API ](http://ip-api.com/) and I used background thread whenever possible to optimize it.

# How to build/use
The app was build in XCode 7.0. Just clone repository. Then install the missing CocoaPods using the provided Podfile. Open the newly created workspace file. Build and enjoy.