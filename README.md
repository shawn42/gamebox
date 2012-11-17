# Gamebox

 [![Gamebox Build Status](https://secure.travis-ci.org/shawn42/gamebox.png)](http://travis-ci.org/shawn42/gamebox)
 [![Gamebox Deps Status](https://gemnasium.com/shawn42/gamebox.png)](https://gemnasium.com/shawn42/gamebox)

 * A **game template** for building and distributing Gosu games.
 * Quickly **generate a game** and have it **up and running**.
 * Provide **conventions and DSL** for building your game.
 * Facilitate quickly building **distributable artifacts**.
 * http://shawn42.github.com/gamebox/
 * see [gamebox on rubygems.org](https://rubygems.org/gems/gamebox) for the list of requirements

# Getting started with Gamebox

## Purpose

**Why use Gamebox?** Gamebox was designed to spring board game development. It allows the developer to define business rules about a game very quickly without having to worry about resource loading, sound/music management, creating windows, or messing with viewports.  Gamebox allows you to define a game's business rules within minutes, using the metaphor of a 5th grade play.

The driving idea behind Gamebox is to provide the ability to have as many of the basic common pieces of a **2D game** at the developers disposal from the beginning.  

The reason I wrote Gamebox is twofold: first, to aid in 48 hour game writing competitions and second, to allow me to write simple educational games for my kids.

## Installation

 * gem install gamebox
 * or [tar](http://shawn42.github.com/gamebox)
 * or git clone git://github.com/shawn42/gamebox.git && bundle && rake install

## Game Creation

1. gamebox new zapper
1. this will create the directory structure and needed files to get a basic actor up on the screen:   


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
        │   ├── graphics  
        │   ├── music  
        │   └── sounds   
        ├── spec  
        │   └── helper.rb  
        └── src  
            ├── actors  
            │   └── player.rb  
            ├── app.rb  
            └── demo_stage.rb  


1. you now have a runnable Gamebox game

        cd zapper  
        bundle
        rake

## Stages

A stage is where all the magic happens. Each new play type in your game will use a different stage. An example game may have a number of stages such as: `main_menu`, `play`, or `credits`.  A `demo_stage.rb` is created for you by using the `gamebox new` command.

        define_stage :demo do
          setup do
           ...
          end
        end

## Actors

Actors are the basic building blocks of games in Gamebox. Everything in the game is an actor: the player, an alien, the bullet, even the score on the screen. Internally, actors are just named collections of behaviors and observable attributes.

        define_actor :player do
            has_behaviors do
                shooter recharge_time: 4_000, shot_power: 15, kickback: 0.7
                shielded
                bomber kickback: 5
            
                die_by_sword
                die_by_bullet
                die_by_bomb
                blasted_by_bomb
            
                jumper
            end
            
        end


## Behaviors

Behaviors are what bring life to actors.  They interact interact with the actor's internal data, input, audio, etc.

        define_behavior :projectile do
        
          requires :director
          requires_behaviors :positioned
          setup do
            actor.has_attributes vel_x: 0,
                                 vel_y: 0
        
            director.when :update do |delta_ms, delta_secs|
              actor.x += (actor.vel_x * delta_secs)
              actor.y += (actor.vel_y * delta_secs)
            end
          end
        
        end

## Views

Actor views are the mechanism for drawing an actor in Gamebox. When an actor is created, Gamebox will see if there is a matching actor view by name. It will register the view to be drawn by the renderer. The draw callback is called with the rendering target, the x and y offsets based on the viewport, and the z layer to be used for drawing this actor (see the section on parallax layers for more on z layers).

        define_actor_view :label_view do
          draw do |target, x_off, y_off, z|          
            target.print actor.text, actor.x, actor.y, z, actor.font_style
          end
        end



## Getting actors on stage

To get an actor on the stage, use the `create_actor` method on stage. This can be done directly from a stage or from a behavior that has required stage via `requires :stage`. 

        setup do
            @player = create_actor :label, x: 20, y: 30, text: "Hello World!"
        end


## Input

Input comes from the InputManager. The stage has direct access via `input_manager`, actors have something built-in called input? (check out foxy vs gamebox here)    




# STOP READING HERE.. TODO BELOW  :)


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


This snippet show us that our Actor wants to be updated on every gameloop and that it wants to be animated.  Gamebox favors convention over configuration. This means that there are default locations and setting for most things. They can be overridden but you are not required to do so. The animated behavior assumes that your animated images are in a directory structure based on the Actor's underscored name and its current action.

	zapper/
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

## Stages

A Stage is where all the magic happens. A Stage can be any gameplay mode in your game. The main menu has a different interactions than the _real_ game.  In Gamebox, each should have their own Stage. Stages are configured via the stage_config.yml file in config. Listing :demo there will create DemoStage for you.  Game.rb decides which stage to start on. 

## StageManager

So how do these actors end up on the screen? The StageManager. The stage manager handles contruction of new stages and drawing their actors too. Gamebox has built-in support for parallaxing. Parallax layers denote this distance from the audience an Actor should be.  The clouds in the sky that are really far away can be set to INFINITY to have them not move at all as the viewport moves.  Each parallax layer has layers to allow Actors to be on top of one another, but have the same distance from the audience.  The StageManager respects Actor's layered behaviors, if specified. If no layer is specified, the StageManager puts the Actor on parallax layer one of layer one. Example layered behavior:

  has_behavior :layered #> {:parallax #> 30, :layer #> 2}

This Actor will be 30 layers away from the audience, and will sit on top of anything in parallax layer 30 that has layer less than 2.


## Publisher
## Physics
## SVG Levels


## Intra-Links

[Link to the FAQ] (https://github.com/shawn42/gamebox/wiki/Frequently-Asked-Questions)

## LICENSE:

(MIT)

Copyright &copy; 2012 Shawn Anderson