# Ruake

This addon includes:
	- a terminal that runs godot expressions using nodes from the running scene as context.
	- a REPL that's available in the editor.

This can be used to debug while the game is running:
![A spaceship game is running and a panel similar to quake's console is opened. The panel has a console in which code can be evaluated, and also has a section with a scene tree. Items from the scene tree can be clicked and that makes the code evaluated in the console be interpreted as being evaluated in the context of that node.](https://user-images.githubusercontent.com/11432672/215775298-c1b609cc-d311-4a6a-8602-79b2d0687252.png)

And to try out stuff in the editor!:
![image](https://github.com/user-attachments/assets/ac58e139-4186-4bb9-ab22-12de2e058333)

# How to install

Download the project and copy the addon folder into your godot project.

Go to Project Settings > Plugins, and enable Ruake.

By default, this configures an action called `toggle_ruake` that opens the Ruake terminal by pressing CTRL+1.

The input can be modified in the Input Map, and if you want to use a different action name, you can configure it in ProjectSettings > Addons > Ruake.

![image](https://github.com/Fanny-Pack-Studios/Ruake/assets/11432672/ca604382-569f-4367-ba9a-457aaf1d2a6a)

# How to use

## Ruake (in game)

Input the action that is configured to open ruake (`toggle_ruake` -> CTRL+1 by default) and the terminal will open!

The same action closes it.

You can select a node from the SceneTree and the code will run using that node as self in the context of the expression.

## Repl (in editor)

After enabling Ruake, you will have a new tab in the bottom dock!
![image](https://github.com/user-attachments/assets/73f05c89-9813-49d2-aa29-a7076db1cb04)

You can run expressions there and evaluate them with **Enter**. You can scroll to previous expressions you evaluated with **up** and **down**.

Also, all the expressions are ran in the context of the selected node. So, if you choose a different node on the SceneTree, you can run code in the context of that node. That means, self will be that node for all the code ran.

Finally, you can use the eyedropper to evaluate code on any node of **_the editor itself_**. This can be used to make it easier to create plugins that modify the editor. ⚠️ But be careful!, messing with the nodes of the editor might crash it or force you to reload the project to get the editor back to its initial state.
