# Gamebox

[![Gamebox Build Status](https://secure.travis-ci.org/shawn42/gamebox.png)](http://travis-ci.org/shawn42/gamebox)
[![Gamebox Deps Status](https://gemnasium.com/shawn42/gamebox.png)](https://gemnasium.com/shawn42/gamebox)

* A **game template** for building and distributing Gosu games.
* Quickly **generate a game** and have it **up and running**.
* Provide **conventions and DSL** for building your game.
* Facilitate quickly building **distributable artifacts**.
* http://shawn42.github.com/gamebox/
* see [gamebox on rubygems.org](https://rubygems.org/gems/gamebox) for the list of requirements

## Getting started with Gamebox

### Purpose

**Why use Gamebox?** Gamebox was designed to spring board game development. It allows the developer to define business rules about a game very quickly without having to worry about resource loading, sound/music management, creating windows, or messing with viewports.  Gamebox allows you to define a game's business rules within minutes, using the metaphor of a 5th grade play.

The driving idea behind Gamebox is to provide the ability to have as many of the basic common pieces of a **2D game** at the developers disposal from the beginning.

The reason I wrote Gamebox is twofold: first, to aid in 48 hour game writing competitions and second, to allow me to write simple educational games for my kids.

### Installation

* `gem install gamebox`
* `git clone git://github.com/shawn42/gamebox.git && cd gamebox && bundle && rake install`

### Game Creation

To create a new Gamebox project run:

```bash
gamebox zapper
```

This will create the directory structure and needed files to get a basic actor up on the screen:

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
```

To run your game:

```bash
cd zapper
bundle
rake
```

### Stages

A stage is where all the magic happens. Each new play type in your game will use a different stage. An example game may have a number of stages such as: `main_menu`, `play`, or `credits`.  A `demo_stage.rb` is created for you by using the `gamebox new` command.

```ruby
define_stage :demo do
  curtain_up do
   ...
  end
end
```

## Actors

Actors are the basic building blocks of games in Gamebox. Everything in the game is an actor: the player, an alien, the bullet, even the score on the screen. Internally, actors are just named collections of behaviors and observable attributes.

```ruby
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
```

### Behaviors

Behaviors are what bring life to actors.  They interact interact with the actor's internal data, input, audio, etc.

```ruby
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
```

### Views

Actor views are the mechanism for drawing an actor in Gamebox. When an actor is created, Gamebox will see if there is a matching actor view by name. It will register the view to be drawn by the renderer. The draw callback is called with the rendering target, the x and y offsets based on the viewport, and the z layer to be used for drawing this actor (see the section on parallax layers for more on z layers).

```ruby
define_actor_view :label_view do
  draw do |target, x_off, y_off, z|
    target.print actor.text, actor.x, actor.y, z, actor.font_style
  end
end
```

### Getting actors on stage

To get an actor on the stage, use the `create_actor` method on stage. This can be done directly from a stage or from a behavior that has required stage via `requires :stage`.

```ruby
curtain_up do
  @player = create_actor :label, x: 20, y: 30, text: "Hello World!"
end

# or
stage.create_actor ..
```

### Input

Input comes from the InputManager. The stage has direct access via the `input_manager` method. Behaviors can request that they get the `input_manager` via `requires :input_manager`. The preferred way of getting input to your actors is via the actor's `input` method. It returns an InputMapper that can be built with a hash of events. Behaviors then subscribe for those events from the actor's input, or ask for it during updates.

```ruby
actor.input.map_input '+space' => :shoot,
                      '+w' => :jump,
                      '+a' => :walk_left
                      '+s' => :duck
                      '+d' => :walk_right

actor.input.when :shoot do
  # shoot code
end

# or
if actor.input.walk_left?
  # walk left
end
```

### Updates

Updates all come from the Director. Again, the stage has direct access via `director` and behaviors must `requires :director`.

```ruby
director.when :update do |t_ms, t_sec|
  # update something
end
```

### Sound and Music

SoundManager handles the autoloading of sounds from `data/sounds` and `data/music`. The stage has direct access via `sound_manager`. To allow an actor to emit sounds or music, give them the `audible` behavior.  See Reactions below for usage from actors.

```ruby
# music
sound_manager.play_music :overworld

# sounds
sound_manager.play_sound :death
```

### Reactions

To ask to react to something we use the `react_to` method. It sends your message to all of the actors behaviors, giving them a chance to (you guessed it), react.

```ruby
actor.react_to :play_sound, :jump
```

If the actor has an audible behavior listening, he'll play the jump sound. But what if something else wants to know about playing sounds. Maybe the actor triggers an effect by making sound. If the actor had a `noise_alert` behavior, it too would be notified of the `:play_sound` event.

```ruby
define_behavior :noise_alert do
  setup do
    reacts_with :play_sound
  end

  helpers do
    def play_sound(*args)
      # react here
    end
  end
end
```

The `reacts_with` helper takes a list of events that your behavior is interested in, and maps them to helper methods.

## TODO

### Configuration

1. `Gamebox.configuration`

### Resources

1. load paths
2. fonts
3. graphics (caching)
4. sounds

### Stages

1. configuring stages
1. changing stages

### Physics

## Links

[Frequently Asked Questions](https://github.com/shawn42/gamebox/wiki/Frequently-Asked-Questions)

## License

The MIT License (MIT)

Copyright &copy; 2012 Shawn Anderson

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
