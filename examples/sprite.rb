require File.join(File.dirname(__FILE__), "..", "gl_app")
include GLApp::Engine
public

class Texture
  attr_reader :num, :width, :height
  
  # expects a P6 PPM, with no comments, and values 0-255
  # mask is can be an RGB triple (ex: [255, 0, 255])
  def initialize(filename, mask = nil)
    # read the texture file
    format, size, depth, pixels = File.read(filename).split(/\n/, 4)
    @width, @height = size.split.map{|c| c.to_i}

    # convert to ARGB, applying a mask if given
    pixels = pack_pixarr(unpack_ppm(pixels, mask))

    # create the OpenGL texture
    # I hear it's more efficient if the dimensions are powers of 2
    @num = glGenTextures(1).first
    glBindTexture(GL_TEXTURE_2D, @num)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, @width, @height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels)
  end
  
  private
  
    def unpack_ppm(ppm, mask = nil)
      arr = []
      each_triple(ppm.unpack("C*")) do |triple|
        arr << triple + [triple == mask ? 0 : 255]
      end
      arr
    end
  
    def pack_pixarr(arr)
      arr.flatten.pack("C*")
    end
  
    def each_triple(arr)
      buf = []
      arr.each do |i|
        buf << i
        if buf.length == 3
          yield buf
          buf = []
        end
      end
    end
  
end

class Sprite
  def initialize(texture, x, y, w, h)
    @tex = texture
    @x, @y, @w, @h = x, y, w, h
  end
  
  def render
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    glEnable(GL_BLEND)
    
    glMatrixMode(GL_TEXTURE)
    glPushMatrix
    glLoadIdentity
    glOrtho(0, 2*@tex.width, 0, 2*@tex.height, -1, 1)

    glBindTexture(GL_TEXTURE_2D, @tex.num)
    glBegin(GL_QUADS)
        glColor3f(1.0, 1.0, 1.0)
        glTexCoord2d(@x, @y)
            glVertex2d(-@w/2, -@h/2)
        glTexCoord2d(@x + @w, @y)
            glVertex2d(@w/2, -@h/2)
        glTexCoord2d(@x + @w, @y + @h)
            glVertex2d(@w/2, @h/2)
        glTexCoord2d(@x, @y + @h)
            glVertex2d(-@w/2, @h/2)
    glEnd
    
    glMatrixMode(GL_TEXTURE)
    glPopMatrix
    glMatrixMode(GL_MODELVIEW)
    glDisable(GL_BLEND)
  end
end

# state machine encoding frame transitions for hedgehog animation
class HedgehogAction
  attr_reader :frame
  
  def initialize
    @frame = 0
    @frametime = 0
    @state = :standing
  end
  
  def duck
    if @state == :standing
      @frame = 1
      @state = :ducking
    end
  end
  
  def stand
    if @state != :standing
      @frame = 1
      @state = :getting_up
    end
  end
  
  def update(seconds)
    @frametime += seconds
    
    while @frametime > 0.1
      @frametime -= 0.1
      if @state == :getting_up
        @frame = 0
        @state = :standing
      elsif @state == :ducking
        @frame = 2
        @state = :spinning
      elsif @state == :spinning
        @frame = (((@frame - 2) + 1) % 4) + 2
      end
    end
  end
end

def setup
  glEnable(GL_TEXTURE_2D)
  
  # cannot allocate textures until OpenGL window is created
  # so be sure to do this in setup at the earliest
  hedgehog = Texture.new("hedgehog.ppm", [1, 170, 225])
  @sprites = (0..5).map { |i| Sprite.new(hedgehog, i*40, 0, 40, 50) }
  @animator = HedgehogAction.new
end

def keyboard_down(key, modifiers)
  @animator.duck
end

def keyboard_up(key, modifiers)
  exit if key == 27 # escape
  @animator.stand
end

def update(seconds)
  @animator.update(seconds)
end

def draw
  # change coordinate system to match screen pixels
  glMatrixMode(GL_PROJECTION)
  glLoadIdentity
  glOrtho(0, 300, 300, 0, -1000, 1000)
  glMatrixMode(GL_MODELVIEW)
  glLoadIdentity

  # draw a hedgehog in the center of the screen
  glPushMatrix
    glTranslate(150, 150, 0)
    @sprites[@animator.frame].render
  glPopMatrix
end

GLApp.new(self, 300, 300).show
