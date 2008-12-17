require "rubygems"
require "opengl"

module GlutWrapper
  include Gl, Glu, Glut

  # callback stubs ... override these in your code for fun!
  def setup; end
  def draw; end
  def update(seconds); end # seconds since call
  def special_keyboard(key, modifiers); end
  def mouse_click(button, state, x, y); end
  def mouse_active_motion(x, y); end
  def mouse_passive_motion(x, y); end
  def keyboard(key, modifiers); exit if key == 27; end

  def go_windowed(width, height, title = "")
    init(width, height, title)

    if glutGameModeGet(GLUT_GAME_MODE_ACTIVE) != 0
      glutLeaveGameMode
    end

    unless @window
      glutInitWindowSize(*@screen_size)
      @window = glutCreateWindow(@window_title)
    end

    setup_context
    go unless going?
  end

  def go_fullscreen(width, height, title = "")
    init(width, height, title)

    glutGameModeString(@screen_size.join("x"))

    if glutGameModeGet(GLUT_GAME_MODE_POSSIBLE)
      glutEnterGameMode
      if glutGameModeGet(GLUT_GAME_MODE_ACTIVE) == 0
        go_windowed
      end
    else
      go_windowed
    end

    setup_context
    go unless going?
  end

  attr_reader :screen_size

  def init(width, height, title)
    @screen_size = [width, height]
    @window_title = title
    @going = false
    gl_init
  end

  def go
    setup
    @going = true
    glutMainLoop
  end

  def going?
    @going
  end

  def gl_init
    glutInit
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH)
  end

  def setup_context
    glEnable(GL_DEPTH_TEST)

    glutIgnoreKeyRepeat(1)

    glutDisplayFunc(lambda do
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
      glLoadIdentity
      $gl_app.draw
      glutSwapBuffers
    end)

    glutIdleFunc(lambda do
      time = Time.now
      @last_time ||= time
      delta = time - @last_time
      update(delta * 1000.0)
      glutPostRedisplay
    end)

    glutKeyboardFunc(lambda do |key, x, y|
      keyboard(key, glutGetModifiers)
    end)

    glutSpecialFunc(lambda do |key, x, y|
      special_keyboard(key, glutGetModifiers)
    end)

    glutMouseFunc(method(:mouse_click).to_proc)
    glutMotionFunc(method(:mouse_active_motion).to_proc)
    glutPassiveMotionFunc(method(:mouse_passive_motion).to_proc)

    glutReshapeFunc(method(:resize).to_proc)

    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  end

  def resize(width, height)
    # avoid divide-by-zero
    height = 1.0 if height <= 0

    # Reset the coordinate system
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity

    # Set the viewport to be the entire window
    glViewport(0, 0, *@screen_size)

    # Set the correct perspective
    gluPerspective(45, width.to_f / height.to_f, 1, 1000)
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity
    gluLookAt(0, 0, 5, 0, 0, -1, 0, 1, 0)

    @screen_size = [width, height]
  end
end

include GlutWrapper

class GLApp
  include Gl, Glu, Glut

  def initialize(engine)
    @engine = engine
    $gl_app = self
  end

  def show(width, height, title = "")
    go_windowed(width, height, title = "")
  end

  def draw
    @engine.draw
  end
  
  def update(seconds)
    @engine.update(seconds)
  end
end

