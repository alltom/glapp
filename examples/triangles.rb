require File.join(File.dirname(__FILE__), "..", "gl_app")

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
      glTranslate 0, 0.5, -5
      glRotate 110, 1, 0, 0
      glTranslate 3.0 * Math::sin(@angle), 3.0 * Math::cos(@angle), 0
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

class TriangleDemo
  include GLApp::Engine
  
  def setup
    @triangles = Triangle.boom(10)
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
end

app = GLApp.new(TriangleDemo.new, 800, 300, "Triangle demo")
app.show
