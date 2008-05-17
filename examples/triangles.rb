require File.join(File.dirname(__FILE__), "..", "gl_app")
include GLApp
include Math

def setup
  @triangles = Triangle.boom(10)
end

def update(seconds)
  @triangles.each { |tri| tri.angle += seconds/1000.0 }
end

def draw
  @triangles.each { |tri| tri.draw }
end

class Triangle
  attr_accessor :angle

  def initialize(angle)
    @angle = angle
  end
  
  def self.boom(num)
    slice = (2.0 * PI) / num.to_f
    (1..num).map { |i| Triangle.new(slice * i) }
  end
  
  def draw
    glPushMatrix
      glTranslate 0, 0.5, -5
      glRotate 110, 1, 0, 0
      glTranslate 3.0 * sin(@angle), 3.0 * cos(@angle), 0
      glRotate @angle * 90, 1, 1, 1
      glBegin GL_TRIANGLES
        glColor 1, 0, 0
        glVertex 0, 1, 0

        glColor 0, 1, 0
        glVertex -1, -1, 0

        glColor 0, 0, 1
        glVertex 1, -1, 0
      glEnd
    glPopMatrix
  end
end

go_windowed 800, 300
