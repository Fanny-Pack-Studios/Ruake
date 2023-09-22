# Ruake

Allows a terminal that runs gdscript to be opened while the game is running.

It also opens the scene tree and by clicking nodes in the tree you can evaluate code directly in their context!

![A spaceship game is running and a panel similar to quake's console is opened. The panel has a console in which code can be evaluated, and also has a section with a scene tree. Items from the scene tree can be clicked and that makes the code evaluated in the console be interpreted as being evaluated in the context of that node.](https://user-images.githubusercontent.com/11432672/215775298-c1b609cc-d311-4a6a-8602-79b2d0687252.png)

# How to install

Download the project and copy the addon folder into your godot project.

Go to Project Settings > Plugins, and enable Ruake.

# How to use

You need to choose which action will be used to open ruake:
For example, in the image I'm choosing a `toggle_ruake` action that I need to set up in the Input Map.
![image](https://github.com/Fanny-Pack-Studios/Ruake/assets/11432672/ca604382-569f-4367-ba9a-457aaf1d2a6a)

You can also configure which layer Ruake is displayed in and if it should pause the scene tree when it's opened.
