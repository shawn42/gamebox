#--
#	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#
#	Copyright (C) 2008-2010  John Croisant
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


module Rubygame

  # The Vector2 class implements two-dimensional vectors.
  # It is used to represent positions, movements, and velocities
  # in 2D space.
  # 
  class Vector2
    include Enumerable

    RAD_TO_DEG = 180.0 / Math::PI
    DEG_TO_RAD = Math::PI / 180.0


    class << self

      alias :[] :new


      # Creates a new Vector2 from an angle in radians and a
      # magnitude. Use #new_polar_deg for degrees.
      # 
      def new_polar( angle_rad, magnitude )
        self.new( Math::cos(angle_rad)*magnitude,
                  Math::sin(angle_rad)*magnitude )
      end


      # Creates a new Vector2 from an angle in degrees and a
      # magnitude. Use #new_polar for radians.
      # 
      def new_polar_deg( angle_deg, magnitude )
        self.new_polar( angle_deg * DEG_TO_RAD, magnitude )
      end


      # call-seq:
      #   Vector2.many( [x1,y1], [x2,y2], ... )
      # 
      # Converts multiple [x,y] Arrays to Vector2s.
      # Returns the resulting vectors in an Array.
      # 
      def many( *pairs )
        pairs.collect { |pair| self.new(*pair) }
      end

    end


    # Creates a new Vector2 with the given x and y values.
    def initialize( x, y )
      @x, @y = x.to_f, y.to_f
    end

    attr_reader :x, :y

    def x=( value )
      raise "can't modify frozen object" if frozen?
      @x = value.to_f
      @hash = nil
      self
    end

    def y=( value )
      raise "can't modify frozen object" if frozen?
      @y = value.to_f
      @hash = nil
      self
    end


    # Sets this vector's x and y components.
    def set!( x, y )
      raise "can't modify frozen object" if frozen?
      @x = x.to_f
      @y = y.to_f
      @hash = nil
      self
    end


    # Sets this vector's angle (in radians) and magnitude.
    # Use #set_polar_deg! for degrees.
    # 
    def set_polar!( angle_rad, mag )
      raise "can't modify frozen object" if frozen?
      @x = Math::cos(angle_rad) * mag
      @y = Math::sin(angle_rad) * mag
      @hash = nil
      self
    end


    # Sets this vector's angle (in degrees) and magnitude.
    # Use #set_polar! for radians.
    # 
    def set_polar_deg!( angle_deg, mag )
      set_polar!( angle_deg * DEG_TO_RAD, mag )
      self
    end


    # Adds the given vector to this one and return the
    # resulting vector.
    # 
    def +( vector )
      self.class.new( @x + vector.at(0), @y + vector.at(1) )
    end

    # call-seq:
    #   move!( [x,y] )
    #   move!( x,y )
    # 
    # Moves the vector by the given x and y amounts.
    def move!( x, y=nil )
      raise "can't modify frozen object" if frozen?
      if y.nil?
        a = x.to_ary
        @x += a[0]
        @y += a[1]
      else
        @x += x
        @y += y
      end
      @hash = nil
      self
    end

    # call-seq:
    #   move( [x,y] )
    #   move( x,y )
    # 
    # Like #move!, but returns a new vector.
    def move( x, y=nil )
      self.dup.move!(x, y)
    end


    # Subtracts the given vector from this one and return
    # the resulting vector.
    # 
    def -( vector )
      self.class.new( @x - vector.at(0), @y - vector.at(1) )
    end


    # Returns the opposite of this vector, i.e. Vector2[-x, -y].
    def -@
      self.class.new( -@x, -@y )
    end

    # Reverses the vector's direction, i.e. Vector2[-x, -y].
    def reverse!
      raise "can't modify frozen object" if frozen?
      @x, @y = -@x, -@y
      @hash = nil
      self
    end

    # Like #reverse!, but returns a new vector.
    def reverse
      self.dup.reverse!
    end


    # Multiplies this vector by the given scalar (Numeric),
    # and return the resulting vector.
    # 
    def *( scalar )
      self.class.new( @x * scalar, @y * scalar )
    end


    # True if the given vector's x and y components are
    # equal to this vector's components (within a small margin
    # of error to compensate for floating point imprecision).
    # 
    def ==( vector )
      _nearly_equal?(@x, vector.at(0)) and _nearly_equal?(@y, vector.at(1))
    end


    # Returns a component of this vector as if it were an
    # [x,y] Array.
    # 
    def []( index )
      [@x, @y][index]
    end

    alias :at :[]


    def hash # :nodoc:
      @hash ||= (((@x - @x.modulo(1E-10)).hash << 2) +
                 ((@y - @y.modulo(1E-10)).hash << 1) +
                 self.class.hash)
    end


    # Iterates over this vector as if it were an [x,y] Array.
    # 
    def each( &block )
      [@x, @y].each( &block )
    end


    # Returns the angle of this vector, relative to the positive
    # X axis, in radians. Use #angle_deg for degrees.
    # 
    def angle
      Math.atan2( @y, @x )
    end


    # Sets the vector's angle in radians. The vector keeps the same
    # magnitude as before.
    # 
    def angle=( angle_rad )
      raise "can't modify frozen object" if frozen?
      m = magnitude
      @x = Math::cos(angle_rad) * m
      @y = Math::sin(angle_rad) * m
      @hash = nil
      self
    end


    # Returns the angle of this vector relative to the other vector,
    # in radians. Use #angle_deg_with for degrees.
    # 
    def angle_with( vector )
      Math.acos( udot(vector) )
    end


    # Returns the angle of this vector, relative to the positive
    # X axis, in degrees. Use #angle for radians.
    # 
    def angle_deg
      angle * RAD_TO_DEG
    end


    # Sets the vector's angle in degrees. The vector keeps the same
    # magnitude as before.
    # 
    def angle_deg=( angle_deg )
      self.angle = angle_deg * DEG_TO_RAD
      self
    end


    # Returns the angle of this vector relative to the other vector,
    # in degrees. Use #angle_with for radians.
    # 
    def angle_deg_with( vector )
      angle_with(vector) * RAD_TO_DEG
    end


    # Returns the dot product between this vector and the other vector.
    def dot( vector )
      (@x * vector.at(0)) + (@y * vector.at(1))
    end


    # Returns the magnitude (distance) of this vector.
    def magnitude
      Math.hypot( @x, @y )
    end


    # Sets the vector's magnitude (distance). The vector keeps the
    # same angle as before.
    # 
    def magnitude=( mag )
      raise "can't modify frozen object" if frozen?
      angle_rad = angle
      @x = Math::cos(angle_rad) * mag
      @y = Math::sin(angle_rad) * mag
      @hash = nil
      self
    end


    # Returns a copy of this vector, but rotated 90 degrees
    # counter-clockwise.
    # 
    def perp
      self.class.new( -@y, @x )
    end


    # Sets this vector to the vector projection (aka vector resolute)
    # of this vector onto the other vector. See also #projected_onto.
    # 
    def project_onto!( vector )
      raise "can't modify frozen object" if frozen?
      @x, @y = *(vector * vector.dot(self) * (1/vector.magnitude**2))
      @hash = nil
      self
    end

    # Like #project_onto!, but returns a new vector.
    def projected_onto( vector )
      dup.project_onto!( vector )
    end


    # Rotates the vector the given number of radians.
    # Use #rotate_deg! for degrees.
    # 
    def rotate!( angle_rad )
      self.angle += angle_rad
      self
    end

    # Like #rotate!, but returns a new vector.
    def rotate( angle_rad )
      dup.rotate!( angle_rad )
    end


    # Rotates the vector the given number of degrees.
    # Use #rotate for radians.
    # 
    def rotate_deg!( angle_deg )
      self.angle_deg += angle_deg
      self
    end

    # Like #rotate_deg!, but returns a new vector.
    def rotate_deg( angle_deg )
      dup.rotate_deg!( angle_deg )
    end


    # call-seq:
    #   scale!( scale )
    #   scale!( scale_x, scale_y )
    # 
    # Multiplies this vector's x and y values.
    #
    # If one number is given, the vector will be equal to
    # Vector2[x*scale, y*scale]. If two numbers are given, it will be
    # equal to Vector2[x*scale_x, y*scale_y].
    # 
    # Example:
    # 
    #   v = Vector2[1.5,2.5]
    #   v.scale!( 2 )           # => Vector2[3,5]
    #   v.scale!( 3, 4 )        # => Vector2[9,20]
    # 
    def scale!( scale_x, scale_y = scale_x )
      raise "can't modify frozen object" if frozen?
      @x, @y = @x * scale_x, @y * scale_y
      @hash = nil
      self
    end

    # Like #scale!, but returns a new vector.
    def scale( scale_x, scale_y = scale_x )
      dup.scale!(scale_x, scale_y)
    end


    # Returns this vector as an [x,y] Array.
    def to_ary
      [@x, @y]
    end

    alias :to_a :to_ary


    def to_s
      "Vector2[#{@x}, #{@y}]"
    end

    alias :inspect :to_s


    # Returns the dot product of this vector's #unit and the other
    # vector's #unit.
    # 
    def udot( vector )
      unit.dot( vector.unit )
    end


    # Sets this vector's magnitude to 1.
    def unit!
      raise "can't modify frozen object" if frozen?
      scale = 1/magnitude
      @x, @y = @x * scale, @y * scale
      @hash = nil
      self
    end

    alias :normalize! :unit!

    # Like #unit!, but returns a new vector.
    def unit
      self.dup.unit!
    end

    alias :normalized :unit


    private

    def _nearly_equal?( a, b, threshold=1E-10 ) # :nodoc:
      (a - b).abs <= threshold
    end

  end

end
