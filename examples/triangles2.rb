# the same demo as triangles.rb except all of the hook methods are in
# the top-level instead of in a class

require "rubygems"
require "glapp"

include GLApp

class Triangle
  attr_accessor :angle

  def initialize(angle)
    @angle = angle
  end
  
  def self.boom(num)
    slice = (2.0 * Math::PI) / num.to_f
    (1..num).map { |i| Triangle.new(slice * i) }
  end
  
  def draw
    glPushMatrix
      glTranslate(0, 0.5, -5)
      glRotate(110, 1, 0, 0)
      glTranslate(3.0 * Math::sin(@angle), 3.0 * Math::cos(@angle), 0)
      glRotate(@angle * 90, 1, 1, 1)
      glBegin(GL_TRIANGLES)
        glColor(1, 0, 0)
        glVertex(0, 1, 0)

        glColor(0, 1, 0)
        glVertex(-1, -1, 0)

        glColor(0, 0, 1)
        glVertex(1, -1, 0)
      glEnd
    glPopMatrix
  end
end

def update(seconds)
  @triangles.each { |tri| tri.angle += seconds }
end

def draw
  @triangles.each { |tri| tri.draw }
end

def keyboard_up(key, modifiers)
  exit if key == 27 # escape
end

@triangles = Triangle.boom(10)

show 800, 300, "triangle demo"
