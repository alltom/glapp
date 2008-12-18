require 'rubygems'
require 'opengl'

class GLApp
  def self.instance
    @@instance
  end

  def initialize(engine, width, height, title = "")
    unless engine.is_a?(GLApp::Engine)
      raise ArgumentError.new('Engine has to be a GLApp::Engine')
    end

    @engine = engine
    @width = width
    @height = height
    @title = title
    @running = false
    gl_init
    @@instance = self
  end

  def update(seconds)
    @engine.update(seconds)
  end

  def draw
    @engine.draw
  end

  def keyboard(key, modifiers)
    # exit if key == 27
    @engine.keyboard(key, modifiers)
  end

  def special_keyboard(key, modifiers)
    @engine.special_keyboard(key, modifiers)
  end

  def mouse_click(button, state, x, y)
    @engine.mouse_click(button, state, x, y)
  end

  def mouse_active_motion(x, y)
    @engine.mouse_click(button, state, x, y)
  end

  def mouse_passive_motion(x, y)
    @engine.mouse_passive_motion(x, y)
  end

  def resize(width, height)
    # avoid divide-by-zero
    height = 1.0 if height <= 0

    # Reset the coordinate system
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity

    # Set the viewport to be the entire window
    glViewport(0, 0, width, height)

    # Set the correct perspective
    gluPerspective(45, width.to_f / height.to_f, 1, 1000)
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity
    gluLookAt(0, 0, 5, 0, 0, -1, 0, 1, 0)

    @width, @height = width, height
  end

  def show
    if Glut.glutGameModeGet(GLUT_GAME_MODE_ACTIVE) != 0
      Glut.glutLeaveGameMode
    end

    unless @window
      Glut.glutInitWindowSize(@width, @height)
      @window = glutCreateWindow(@title)
    end

    self.setup_context
    self.go unless running?
  end

  protected

  def go_fullscreen(width, height, title = "")
    init(width, height, title)

    glutGameModeString([width, height].join("x"))

    if glutGameModeGet(GLUT_GAME_MODE_POSSIBLE)
      glutEnterGameMode
      if glutGameModeGet(GLUT_GAME_MODE_ACTIVE) == 0
        go_windowed
      end
    else
      go_windowed
    end

    setup_context
    go unless running?
  end

  def go
    @running = true
    Glut.glutMainLoop
  end

  def running?
    @running
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
      draw
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

    glutMouseFunc(lambda do |button, state, x, y|
      mouse_click(button, state, x, y)
    end)

    glutMotionFunc(lambda do |x, y|
      mouse_active_motion(x, y)
    end)

    glutPassiveMotionFunc(lambda do |x, y|
      mouse_passive_motion(x, y)
    end)

    glutReshapeFunc(lambda do |width, height|
      resize(width, height)
    end)

    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  end

  class Engine
  end
end

