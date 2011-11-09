/**
 * ## Introduction
 * 
 * PushButton Engine is an industrial strength open source Flash game framework.
 *
 * Its home page is <a href="http://PushButtonLabs.github.com/PushButtonEngine">http://PushButtonLabs.github.com/PushButtonEngine</a>.
 *
 * You can click the Jump To.. button in the top right of the page to navigate
 * to different parts of the documentation.
 *
 * PBE uses [Docco](http://jashkenas.github.com/docco/) to document itself. As
 * you read these docs, you are reading through the PBEDemos demo framework
 * that ship with PBE. (See all that code on the right hand side?) Each demo
 * covers a specific feature of the engine, and by reading through the docs,
 * you'll learn all about PBE!
 *
 * ## Compiling PBEDemos
 *
 * Create a new ActionScript FlashBuilder project named PBEDemos pointing at
 * your copy of PBE (specifically, the parent of the src/ folder). Set the 
 * compiler options from the next section. Great! You're good to go. Compile,
 * run, and follow along.
 *
 * ## Using PBE In Your Project
 *
 * To use PBE, create a folder called com/pblabs in your source directory and 
 * copy everything from PBE's src/com/pblabs folder into it.
 *
 * Don't forget to add the following to your compiler options:
 *
 *     --keep-as3-metadata+=TypeHint,EditorData,Embed,Inject,PostInject
 *
 * And that's it!
 *
 */
package
{
    import com.greensock.OverwriteManager;
    import com.greensock.TweenMax;
    import com.pblabs.core.PBGameObject;
    import com.pblabs.core.PBGroup;
    import com.pblabs.debug.Console;
    import com.pblabs.debug.ConsoleCommandManager;
    import com.pblabs.debug.Logger;
    import com.pblabs.input.KeyboardManager;
    import com.pblabs.property.PropertyManager;
    import com.pblabs.simplest.SimplestMouseFollowComponent;
    import com.pblabs.simplest.SimplestSpatialComponent;
    import com.pblabs.simplest.SimplestSpriteRenderer;
    import com.pblabs.time.TimeManager;
    import com.pblabs.util.TypeUtility;
    
    import demos.demo_01_simplestRenderer.SimplestRendererScene;
    import demos.demo_02_bindingDemo.BindingDemoScene;
    import demos.demo_03_mouseFollower.MouseFollowerScene;
    import demos.demo_04_circlePickup.CirclePickupScene;
    import demos.demo_05_circlePickupWithTimeManager.CirclePickupWithTimeManagerScene;
    import demos.demo_06_oneButtonDemo.OneButtonDemoScene;
    import demos.demo_07_twoButtonDemo.TwoButtonDemoScene;
    import demos.demo_08_carDemo.CarDemoScene;
    import demos.demo_09_stateMachineDemo.FSMDemoScene;
    import demos.molehill.MolehillScene;
    
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    
    /**
     * ## PBEDemos?
     * 
     * PBEDemos is a sweet PushButton Engine demo framework. It switches 
     * between different small PBE demo applications, using the < and > keys.
     *
     * If you are brand new to PBE, you might want to start with one of these
     * very small demos, like
     * <a href="SimplestRendererScene.html">SimplestRendererScene.as</a>, rather
     * than digesting the demo framework.
     * 
     * PBEDemos cycles amongst multiple demo "scenes" to show off
     * various parts of the engine's capabilities. Use < and > to change the 
     * demo. Press ~ (tilde) to bring up the console. Type help to learn about
     * the different debug commands.
     * 
     * The demo scenes are all implemented in their own classes that live in 
     * the demo package. A great way to learn the engine is to read through
     * each demo, in order, and look at the demo app at the same time.
     */
     
     /**
      * ## The Demo Framework
      *
      * Look at the code on the right and follow along!
      *
      * PBEDemos acts to load and unload instances of the classes that implement
      * the various PBEDemos. It contains some book-keeping and UI code to 
      * manage this, and it makes a few standard things available to the demos.
      */
    [SWF(frameRate="32",wmode="direct")]
    public class PBEDemos extends Sprite
    {
        // rootGroup is a PBGroup that contains the current demo scene. It
        // provides a few dependencies that every demo needs.
        public var rootGroup:PBGroup = new PBGroup();

        // We maintain a list of all the demo scenes that we'll cycle between,
        // identified by their type. (The molehill demo requires a molehill
        // enabled dev environment and is disabled by default.)
        public var sceneList:Array = 
            [ SimplestRendererScene, BindingDemoScene, MouseFollowerScene, 
                CirclePickupScene, CirclePickupWithTimeManagerScene, 
                OneButtonDemoScene, TwoButtonDemoScene, CarDemoScene,
                FSMDemoScene /*, MolehillScene*/ ];
        
        // Keep track of the current demo scene.
        public var currentSceneIndex:int = 0;
        public var currentScene:PBGroup;
        
        // We have a couple of UI elements to show whether the demo is
        // paused, how to work the demo, and what demo is currently running.
        public var sceneCaption:TextField = new TextField();
        public var usageCaption:TextField = new TextField();
        public var pauseCaption:TextField = new TextField();
        
        /**
         * ## PBEDemos Constructor
         *
         * Initialize the demo and show the first scene.
         */
        public function PBEDemos()
        {
            // Set up the TweenMax plugins we use. PBEDemos uses TweenMax for 
            // some nice animation effects, but TweenMax is not a standard
            // part of PBE. It is, however, a great tweening library.
            OverwriteManager.init(OverwriteManager.AUTO);

            // Set the stage to resize properly.
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            // Set up the root group for the demo and register a few useful
            // managers. Managers are available via dependency injection to the
            // demo scenes and objects.
            rootGroup.initialize();
            rootGroup.name = "PBEDemoGroup";
            rootGroup.registerManager(Stage, stage);
            rootGroup.registerManager(PropertyManager, new PropertyManager());
            rootGroup.registerManager(ConsoleCommandManager, new ConsoleCommandManager());
            rootGroup.registerManager(TimeManager, new TimeManager());
            rootGroup.registerManager(KeyboardManager, new KeyboardManager());
            rootGroup.registerManager(Console, new Console());
            
            // Listen for keyboard events.
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
            
            // Detect when the app gains or loses focus; we will display a 
            // pause caption in this case and pause the TimeManager.
            stage.addEventListener(Event.DEACTIVATE, onDeactivate);
            stage.addEventListener(Event.ACTIVATE, onActivate);

            // Set up the scene caption. This will display the type of the 
            // demo we're currently viewing. (ie, SimplestRendererDemo)
            sceneCaption.autoSize = TextFieldAutoSize.LEFT;
            sceneCaption.text = "Loading..";
            sceneCaption.mouseEnabled = false;
            sceneCaption.textColor = 0x0;
            sceneCaption.defaultTextFormat = new TextFormat(null, 48, 0x0, true);
            addChild(sceneCaption);
            
            // Set up the usage caption. This shows the user what keys will
            // control PBEDemos.
            usageCaption.autoSize = TextFieldAutoSize.CENTER;
            usageCaption.y = stage.stageHeight - 32;
            usageCaption.x = 0;
            usageCaption.mouseEnabled = false;
            usageCaption.width = stage.stageWidth;
            usageCaption.defaultTextFormat = new TextFormat(null, 24, 0x0, true);
            usageCaption.text = "~ for console, < for previous demo, > for next demo.";
            usageCaption.textColor = 0x0;
            addChild(usageCaption);
            
            // Set up the paused caption. This is displayed when the demo loses
            // focus.
            pauseCaption.autoSize = TextFieldAutoSize.CENTER;
            pauseCaption.y = stage.stageHeight/2 - 64;
            pauseCaption.x = 0;
            pauseCaption.mouseEnabled = false;
            pauseCaption.width = stage.stageWidth;
            pauseCaption.defaultTextFormat = new TextFormat(null, 48, 0xFF0000, true);
            pauseCaption.text = "Paused!";
            pauseCaption.textColor = 0x0;
            addChild(pauseCaption);
            
            // Make sure first demo is loaded.
            updateScene();
        }
        
        /**
         * ## Event.DEACTIVATE Handler
         *
         * Called when we lose focus; we fade in the pause caption and set
         * the TimeManager timeScale to zero to pause our game. Note this only
         * affects things that use the TimeManager, not components that directly
         * listen for Event.ENTER_FRAME! 
         */
        protected function onDeactivate(e:Event):void
        {
            TweenMax.to(pauseCaption, 1.0, {alpha: 1});
            (rootGroup.getManager(TimeManager) as TimeManager).timeScale = 0;
        }

        /**
         * ## Event.ACTIVATE Handler
         *
         * Called when we gain focus; we fade out the pause caption and set
         * the TimeManager timeScale to one to resume our game. Note this only
         * affects things that use the TimeManager, not components that directly
         * listen for Event.ENTER_FRAME! 
         */
        protected function onActivate(e:Event):void
        {
            TweenMax.to(pauseCaption, 1.0, {alpha: 0});
            (rootGroup.getManager(TimeManager) as TimeManager).timeScale = 1;
        }

        /**
         * ## Scene Switching Handler
         *
         * Called when the scene index is changed, to make sure the index is
         * valid, then to destroy the old demo scene, create the new demo scene,
         * and to update the UI.
         */
        protected function updateScene():void
        {
            // Make sure the current index is valid.
            if(currentSceneIndex < 0)
                currentSceneIndex = sceneList.length - 1;
            else if(currentSceneIndex > sceneList.length - 1)
                currentSceneIndex = 0;
            
            // Note our change in state.
            Logger.print(this, "Changing scene to #" + currentSceneIndex + ": " + sceneList[currentSceneIndex]);
            
            // Destroy old scene and instantiate new scene.
            if(currentScene)
                currentScene.destroy();
            currentScene = new sceneList[currentSceneIndex];
            currentScene.owningGroup = rootGroup;
            currentScene.initialize();
            
            // Trigger UI to show the new scene we've selected.
            sceneCaption.text = TypeUtility.getObjectClassName(currentScene).split("::")[1];
            TweenMax.killTweensOf(sceneCaption);
            sceneCaption.alpha = 1;
            TweenMax.to(sceneCaption, 1.0, {alpha:0, delay: 2.0 }); 
        }
        
        /**
         * ## KeyboardEvent.KEY_UP Handler
         *
         * Global key handler to switch scenes. We listen with normal Flash
         * so that we don't interfere with the activity of the various
         * demos.
         */
        protected function onKeyUp(ke:KeyboardEvent):void
        {
            // Figure out what key was hit.
            var keyAsString:String = String.fromCharCode(ke.charCode);
            
            // It might be time to change scenes.
            var sceneChanged:Boolean = false;
            if(keyAsString == "<")
            {
                currentSceneIndex--;
                sceneChanged = true;
            }
            else if(keyAsString == ">")
            {
                currentSceneIndex++;
                sceneChanged = true;
            }
            
            // If so, run updateScene();
            if(sceneChanged)
            {
                updateScene();
            }
        }
    }
}

/**
 * ## Legal Notices
 * 
 * <i>The PushButton Engine is covered under the MIT license in its entirety,
 * not including 3rd party components. Please read LICENSE for more 
 * information on the MIT license.</i>
 *
 * <i>Copyright 2009-2011 PushButton Labs, LLC. All rights reserved.</i>
 */
// @docco-chapter 1. First Steps
// @docco-order 1
