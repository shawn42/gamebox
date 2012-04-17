# Ftor ("Fake vecTOR"), a vector-like class for 2D position/movement.
#--
#	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#	Copyright (C) 2004-2007  John Croisant
#
#	This library is free software; you can redistribute it and/or
#	modify it under the terms of the GNU Lesser General Public
#	License as published by the Free Software Foundation; either
#	version 2.1 of the License, or (at your option) any later version.
#
#	This library is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#	Lesser General Public License for more details.
#
#	You should have received a copy of the GNU Lesser General Public
#	License along with this library; if not, write to the Free Software
#	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#++


# *NOTE*: Ftor is DEPRECATED and will be removed in Rubygame 3.0!
# A mostly-compatible vector class will be provided at or before
# that time.
# 
# *NOTE*: you must require 'rubygame/ftor' manually to gain access to
# Rubygame::Ftor. It is not imported with Rubygame by default!
# 
# Ftor ("Fake vecTOR"), a vector-like class for 2D position/movement.
# 
# (NB: See #angle for an important note about why angles appear to be the
# opposite of what you may expect.)
# 
# Ftor is useful for storing 2D coordinates (x,y) as well as
# vector quantities such as velocity and acceleration (representationally,
# points and vectors are equivalent.) Although Ftors are always represented
# internally as Cartesian coordinates (x, y), it is possible to deal with an
# Ftor as polar coordinates (#angle, #magnitude) instead.
# See #new_am and #set_am!, for example.
# 
# Ftor is a "fake" vector because it has certain convenient properties which
# differ from "true" vectors (i.e. vectors in a strict mathematical sense).
#
# Unlike vectors, Ftors may be multiplied or divided to another Ftor. This is
# equivalent to multiplying or dividing each component by the corresponding
# component in the second Ftor. If you like, you can think of this feature as
# scaling each component of the Ftor by a separate factor:
# 
#   Ftor(a,b) * Ftor(c,d)  =  Ftor(a*c, b*d)
# 
# Of course, Ftors also have the usual vector behavior for addition/subraction
# between two Ftors, and multiplication/division of an Ftor by a scalar:
# 
#   Ftor(a,b) + Ftor(c,d) = Ftor(a+c, b+d)
#   Ftor(a,b) * n = Ftor(a*n, b*n)
# 
# Additionally, Ftor contains functions for manipulating itself.
# You can both get and set such properties as #angle, #magnitude, #unit,
# and #normal, and the Ftor will change in-place as needed. For example,
# if you set #angle=, the vector will change to have the new angle,
# but keeps the same magnitude as before.
# 
# Ftor attempts to save processing time (at the expense of memory) by 
# storing secondary properties (angle, magnitude, etc.) whenever they are
# calculated,so that they need not be calculated repeatedly. If the vector
# changes, the properties will be calculated again the next time they
# are needed.
# (In future versions, it may be possible to disable this feature for
# certain Ftors, for example if they will change very often, to save memory.)
# 
class Ftor
  PI = Math::PI
  HALF_PI = PI*0.5
  THREE_HALF_PI = PI*1.5
  TWO_PI = PI*2

	# Create a new Ftor by specifying its x and y components. See also #new_am
  # and #new_from_to.
	def initialize(x,y)
    @x, @y = x, y
	end

	# Create a new Ftor by specifying its #angle (in radians) and #magnitude.
  # See also #new.
	def self.new_am(a,m)
		v = self.new(1,0)
    v.a, v.m = a, m
		return v
	end

  # Returns a new Ftor which represents the difference in position of two
  # points +p1+ and +p2+. (+p1+ and +p2+ can be Ftors, size-2 Arrays, or
  # anything else which has two numerical components and responds to #[].)
  # 
  # In other words, assuming +v+ is the Ftor returned by this function:
  #   p1 + v = p2
  def self.new_from_to(p1,p2)
    return self.new(p2[0]-p1[0],p2[1]-p1[1])
  end

	attr_reader :x                # The x component of the Ftor.
  # Set the x component of the Ftor.
	def x=(value)
    @x = value
    _clear()
	end

  attr_reader :y                # The y component of the Ftor.
  # Set the y component of the Ftor.
	def y=(value)
    @y = value
    _clear()
	end

	# Modify the x and y components of the Ftor in-place
	def set!(x,y)
    @x, @y = x,y
		_clear()
	end

	# Modify the #angle (in radians) and #magnitude of the Ftor in-place
	def set_am!(a,m)
    self.angle, self.magnitude = a, m
  end

  # Same as #to_s, but this Ftor's #object_id is also displayed.
	def inspect
		"#<#{self.class}:#{object_id}: %f, %f>"%[@x,@y]
	end

  # Display this Ftor in the format: "#<Ftor: [x, y]>". x and y are displayed
  # as floats at full precision. See also #pp.
	def to_s
		"#<#{self.class}: [%f, %f]>"%[@x,@y]
	end

  # "Pretty print". Same as #to_s, but components are displayed as rounded
  # floats to 3 decimal places, for easy viewing.
	def pretty
		"#<#{self.class}: [%0.3f, %0.3f]>"%[@x,@y]
	end

  # Same as #to_s_am, but this Ftor's #object_id is also displayed.
	def inspect_am
		"#<#{self.class}:AM:#{object_id}: %f, %f>"%[angle(),magnitude()]
	end

  # Display this Ftor in the format: "#<Ftor:AM: [angle, magnitude]>". 
  # angle and magnitude are displayed as floats at full precision.
  # See also #to_s and #pp_am.
  def to_s_am
		"#<#{self.class}:AM: [%f, %f]>"%[angle(),magnitude()]
  end

  # "Pretty print" with angle and magnitude. 
  # Same as #to_s_am, but components are displayed as rounded floats to 3
  # decimal places, for easy viewing.
	def pretty_am
		"#<#{self.class}:AM: [%0.3f, %0.3f]>"%[angle(),magnitude()]
	end

  # Returns an Array of this Ftor's components, [x,y].
	def to_a
		[@x,@y]
	end
	alias :to_ary :to_a

  # Return the +i+th component of this Ftor, as if it were the Array
  # returned by #to_a.
	def [](i)
		[@x,@y][i]
	end

  # True if this Ftor is equal to +other+, when both have been converted to
  # Arrays via #to_a. In other words, a component-by-component equality check.
	def ==(other)
		to_a() == other.to_a
	end

  # The reverse of this Ftor. I.e., all components are negated. See also
  # #reverse!.
  def -@
    self.class.new(-@x,-@y)
  end

  # Like #-@, but reverses this Ftor in-place.
  def reverse!
    set!(-@x,-@y)
  end

  # Perform vector addition with this Ftor and +other+, adding them on a
  # component-by-component basis, like so:
  #   Ftor(a,b) + Ftor(c,d)  =  Ftor(a+c, b+d)
	def +(other)
    return self.class.new(@x+other[0],@y+other[1])
	end

  # Like #+, but performs subtraction instead of addition.
	def -(other)
    return self.class.new(@x-other[0],@y-other[1])
	end

  # Perform multiplication of this Ftor by the scalar +other+, like so:
  #   Ftor(a,b) * n = Ftor(a*n, b*n)
  # 
  # However, if this causes TypeError, attempt to extract indices 0 and 1
  # with +other+'s #[] operator, and multiply them into the corresponding
  # components of this Ftor, like so:
  #   Ftor(a,b) * Ftor(c,d) = Ftor(a*c, b*d)
  #   Ftor(a,b) * [c,d]     = Ftor(a*c, b*d)
	def *(other)
    return self.class.new(@x*other,@y*other)
  rescue TypeError
    return self.class.new(@x*other[0],@y*other[1])
	end

  # Like #*, but performs division instead of multiplication.
	def /(other)
		x, y = @x.to_f, @y.to_f
    return self.class.new(x/other,y/other)
  rescue TypeError
    return self.class.new(x/other[0],y/other[1])
	end

	# Return the angle (radians) this Ftor forms with the positive X axis.
  # This is the same as the Ftor's angle in a polar coordinate system.
  # 
  # *IMPORTANT*: Because the positive Y axis on the Rubygame::Screen points
  # *downwards*, an angle in the range 0..PI will appear to point *downwards*,
  # rather than upwards!
  # This also means that positive rotation will appear *clockwise*, and
  # negative rotation will appear *counterclockwise*!
  # This is the opposite of what you would expect in geometry class!
	def angle
		@angle or @angle = Math.atan2(@y,@x)
	end

	# Set the angle (radians) of this Ftor from the positive X axis.
	# Magnitude is preserved.
	def angle=(a)
		m = magnitude()
		set!( Math.cos(a)*m, Math.sin(a)*m )
	end

	alias :a  :angle
	alias :a= :angle= ;

	# Returns the magnitude of the Ftor, i.e. its length from tail to head.
  # This is the same as the Ftor's magnitude in a polar coordinate system.
	def magnitude
		@magnitude or @magnitude = Math.hypot(@x,@y)
	end

	# Modifies the #magnitude of the Ftor, preserving its #angle.
  # 
  # In other words, the Ftor will point in the same direction, but it will
  # be a different length from tail to head.
	def magnitude=(m)
		new = unit() * m
		set!(new.x, new.y)
	end

	alias :m  :magnitude
	alias :m= :magnitude= ;

	# Return a new unit Ftor which is perpendicular to this Ftor (rotated by
  # pi/2 radians, to be specific).
	def normal
		@normal or @normal = unit().rotate(HALF_PI)
	end

  # Rotate this Ftor in-place, so that it is perpendicular to +other+.
  # This Ftor will be at an angle of -pi/2 to +other+.
	def normal=(other)
    set!( *(self.class.new(*other).unit().rotate(-HALF_PI) * magnitude()) )
	end

	alias :n  :normal
	alias :n= :normal= ;

	# Return the unit vector of the Ftor, i.e. an Ftor with the same direction,
  # but a #magnitude of 1. (This is sometimes called a "normalized" vector,
  # not to be confused with a vector's #normal.)
	def unit
		m = magnitude().to_f
		@unit or @unit = Ftor.new(@x/m, @y/m)
	end

	# Rotates this Ftor in-place, so that its #unit vector matches the unit
  # vector of the given Ftor.
  # 
  # In other words, changes the #angle of this Ftor to be the same as the angle
  # of the given Ftor, but this Ftor's #magnitude does not change.
  #--
  # TODO: investigate efficiency of using `self.angle = other.angle` instead
  #++
	def unit=(other)
		set!( *(self.class.new(*other).unit() * magnitude()) )
	end

	alias :u  :unit
	alias :u= :unit=
  alias :align! :unit=;

	# Return the dot product (aka inner product) of this Ftor and +other+.
  # The dot product of two vectors +v1+ and +v2+ is:
  #   v1.x * v2.x + v1.y * v2.y
	def dot(other)
		@x*other[0] + @y*other[1]
	end

	# Return the #dot product of #unit vectors of this Ftor and +other+.
	def udot(other)
		unit().dot(self.class.new(*other).unit)
	end

	#Return the difference in angles (radians) between this Ftor and +other+.
	def angle_with(other)
		Math.acos( self.udot(other) )
	end

  # Rotate this Ftor in-place by +angle+ (radians). This is the same as
  # adding +angle+ to this Ftor's #angle.
  # 
  #--
  # , with one important difference: 
  # This method will be much more efficient when rotating at a right angle,
  # i.e.rotating by any multiple of PI/2 radians from -2*PI to 2*PI radians.
  # 
  # For convenience, and to ensure exactitude, several numerical constants
  # have been defined for multiples of PI/2:
  # * Ftor::PI::             (same as Math::PI)
  # * Ftor::HALF_PI::        PI * 0.5 (or PI/2)
  # * Ftor::THREE_HALF_PI::  PI * 1.5 (or 3*PI/2)
  # * Ftor::TWO_PI::         PI * 2
  #++
  # 
  # *IMPORTANT*: Positive rotation will appear *clockwise*, and negative
  # rotation will appear *counterclockwise*! See #angle for the reason.
	def rotate!(angle)
# 		case(angle)
# 		when HALF_PI, -THREE_HALF_PI
# 			self.set!(@y,-@x)
# 		when THREE_HALF_PI, -HALF_PI
# 			self.set!(-@y,@x)
# 		when PI, -PI
# 			self.set!(@y,-@x)
# 		when 0, TWO_PI, -TWO_PI
# 			self.set!(@y,-@x)
# 		else
			self.a += angle
# 		end
		return self
	end

  # Like #rotate!, but returns a duplicate instead of rotating this Ftor
  # in-place.
	def rotate(radians)
		self.dup.rotate!(radians)
	end

	# Clears stored values for #angle, #magnitude, #normal, and #unit,
  # so that they will be recalculated the next time they are needed.
  # Intended for internal use, but might be useful in other situations.
	def _clear
		@angle = nil
		@magnitude = nil
		@normal = nil
		@unit = nil
		return self
	end
end
