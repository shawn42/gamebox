# Gamebox
 ![http://travis-ci.org/shawn42/gamebox](https://secure.travis-ci.org/shawn42/gamebox.png)   
 ![https://gemnasium.com/shawn42/gamebox](https://gemnasium.com/shawn42/gamebox.png)

 * A game template for building and distributing Gosu games.
 * Quickly generate a game and have it up and running.
 * Provide conventions and DSL for building your game.
 * Facilitate quickly building distributable artifacts.
 * http://shawn42.github.com/gamebox/
 * see [gamebox on rubygems.org](https://rubygems.org/gems/gamebox) for the list of requirements


# Getting started with Gamebox

## Purpose

Why use Gamebox? Gamebox was designed to spring board game development. It allows the developer to define business rules about a game very quickly without having to worry about resource loading, sound/music management, creating windows, or messing with viewports.  Gamebox allows you to define a game's business rules within minutes.

The driving idea behind Gamebox is to provide the ability to have as many of the basic common pieces of a 2D game at the developers disposal from the beginning.  

The reason I wrote Gamebox is twofold: first, to aid in 48 hour game writing competitions and second, to allow me to write simple educational games for my kids.

## Installation

 * gem install gamebox
 * or [tar](http://shawn42.github.com/gamebox)
 * or git clone git://github.com/shawn42/gamebox.git

## Game Creation

``` $ gamebox zapper```

```$ this will create the directory structure and needed files to get a basic actor up on the screen```

```
zapper
    ├── Gemfile  
    ├── README.rdoc  
    ├── Rakefile  
    ├── config  
    │   ├── boot.rb  
    │   ├── environment.rb  
    │   └── game.yml  
    ├── data  
    │   ├── fonts  
    │   │   └── FONTS_GO_HERE  
    │   ├── graphics  
    │   │   └── GRAPHICS_GO_HERE  
    │   ├── music  
    │   │   └── MUSIC_GOES_HERE  
    │   └── sounds  
    │       └── SOUND_FX_GO_HERE  
    ├── spec  
    │   └── helper.rb  
    └── src  
        ├── actors  
        │   └── player.rb  
        ├── app.rb  
        └── demo_stage.rb  
```

 you now have a runnable gamebox game

```
	cd zapper 
  bundle 
	rake  
```

## Stages

A Stage is where all the magic happens. A Stage can be any gameplay mode in your game. The main menu has a different interactions than the _real_ game.  In Gamebox, each should have their own Stage. Stages are configured via the stage_config.yml file in config. Listing :demo there will create DemoStage for you.  Game.rb decides which stage to start on. 

## Actors to the Stage

An actor is the base class for any game object. A building, the player, the score, the bullet are all examples of actors. Actors can even be invisible. Any number of behaviors can be added to an actor to define how it will react to the world via the define_actor method. Actors are simply buckets of data and behaviors. The interactions with system are all driven by their behaviors.

So Actors sound fun, how do I get one? That's where the ActorFactory comes in. In your Stage class (demo_stage.rb by default) you can use the create_actor helper method as shown below.
`
`	@score # create_actor :score, x: 10, y: 10
	
This call will return an instance of a score (the first arg is the symbolized version of the actor type).  It will also create the view for the actor and register it to be drawn.  Which view is instantiated depends on the actor requested.  The factory will always look for a view named the same as the actor with _view on the end. So the actor score will look for score_view.  If score_view does not exist, a generic view class will be used based on the behaviors of the actor. Each view is constructed with a reference to the actor it is displaying. See ActorFactor#build for more details.

That's great, but how do I tell my actors what to do? By defining their behaviors!
`
`define_actor :score do
  has_behaviors :positioned, :score_keeping
end


## Sound

There are two ways to play sounds in Gamebox. From your stage you can simple access the SoundManager via the sound_manager method. From your actors, you can play sounds via the play_sound helper method in the audible behavior.
`
`	# music
	sound_manager.play_music :overworld
	
	# sounds
	sound_manager.play_sound :death

or
`
`	# from an actor
        has_behavior :audible
	actor.react_to :play_sound, :jump

## Resources

All file loading is handled by the ResourceManager.  It handles loading images, sounds, fonts, config files, and even svg files. The resource manager caches images based on their name and fonts based on their name/size pair. Example usage from the ScoreView class:
`
`	font # @mode.resource_manager.load_font 'Asimov.ttf', 30

## Behaviors

Behaviors are designed to allow you to build Actors from previously built chunks of code. Lets look at the built in Animated behavior.
`
`  define_behavior :shooting do
    requires :input_manager
    setup do
      input_manager.reg :down, KbSpace do
        shoot
      end
    end

    helpers do
      def shoot
        # shoot
      end
    end
  end


This snippet show us that our Actor wants to be updated on every gameloop and that it wants to be animated.  Gamebox favors convention over configuration. This means that there are default locations and setting for most things. They can be overridden but you are not required to do so. The animated behavior assumes that your animated images are in a directory structure based on the Actor's underscored name and its current action.
`
`	zapper/
	`-- data
	    `-- graphics
	        `-- super_hero
	            |-- flying
	            |   |-- 1.png
	            |   |-- 2.png
	            |   |-- ...
	            |   `-- 8.png
	            |-- idle.png
	            `-- walking
	                |-- 1.png
	                `-- 2.png
	
Here we can see that the SuperHere class has three actions (flying, walking, idle).  These actions will be set by calling action# on your Actor.

  batman # create_actor :super_hero
  batman.action # :flying

The animation will cycle through all the numbered png files for the current action.  To stop animating you simple call stop_animating.

  batman.stop_animating


Animated and Updatable are just two behaviors available in Gamebox. Other include	graphical, audible, layered, and physical. You can easily add your own game specific behaviors by extending Behavior. (see Wanderer in rague example for a simple behavior).

## StageManager

So how do these actors end up on the screen? The StageManager. The stage manager handles contruction of new stages and drawing their actors too. Gamebox has built-in support for parallaxing. Parallax layers denote this distance from the audience an Actor should be.  The clouds in the sky that are really far away can be set to INFINITY to have them not move at all as the viewport moves.  Each parallax layer has layers to allow Actors to be on top of one another, but have the same distance from the audience.  The StageManager respects Actor's layered behaviors, if specified. If no layer is specified, the StageManager puts the Actor on parallax layer one of layer one. Example layered behavior:

  has_behavior :layered #> {:parallax #> 30, :layer #> 2}

This Actor will be 30 layers away from the audience, and will sit on top of anything in parallax layer 30 that has layer less than 2.


## Publisher
## Physics
## SVG Levels

## LICENSE:

(MIT)

Copyright &copy; 2012 Shawn Anderson
