# Ruake

Allows a terminal that runs godot expressions on the nodes you select.

This can be used to debug while the game is running:
![A spaceship game is running and a panel similar to quake's console is opened. The panel has a console in which code can be evaluated, and also has a section with a scene tree. Items from the scene tree can be clicked and that makes the code evaluated in the console be interpreted as being evaluated in the context of that node.](https://user-images.githubusercontent.com/11432672/215775298-c1b609cc-d311-4a6a-8602-79b2d0687252.png)

Also, it can be used in the editor:
![image](https://github.com/user-attachments/assets/ac58e139-4186-4bb9-ab22-12de2e058333)


# How to install

Download the project and copy the addon folder into your godot project.

Go to Project Settings > Plugins, and enable Ruake.

# How to use

## Ruake (in game)

You need to choose which action will be used to open ruake:
For example, in the image I'm choosing a `toggle_ruake` action that I need to set up in the Input Map.
![image](https://github.com/Fanny-Pack-Studios/Ruake/assets/11432672/ca604382-569f-4367-ba9a-457aaf1d2a6a)

You can also configure which layer Ruake is displayed in and if it should pause the scene tree when it's opened.

## Repl (in editor)

After enabling Ruake, you will have a new tab in the bottom dock!
![image](https://github.com/user-attachments/assets/73f05c89-9813-49d2-aa29-a7076db1cb04)

You can run expressions there and evaluate them with **Enter**. You can scroll to previous expressions you evaluated with **up** and **down**.

Also, all the expressions are ran in the context of the selected node. So, if you choose a different node on the SceneTree, you can run code in the context of that node. That means, self will be that node for all the code ran.

Finally, you can use the eyedropper to evaluate code on any node of **_the editor itself_**. This can be used to make it easier to create plugins that modify the editor. ⚠️ But be careful!, messing with the nodes of the editor might crash it or force you to reload the project to get the editor back to its initial state.
