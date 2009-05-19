require 'rubygems'
require 'opengl'

module GLApp
  attr_reader :width, :height, :title
  
  def show(width, height, title = "glapp", fullscreen = false)
    glutInit
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH)
    
    @width = width
    @height = height
    @title = title
    
    fullscreen ? go_fullscreen : go_windowed
    setup
    
    setup_context
    wire
    glutMainLoop
  end
  
  def go_windowed
    if glutGameModeGet(GLUT_GAME_MODE_ACTIVE) != 0
      glutLeaveGameMode
    end

    unless @window
      glutInitWindowSize(width, height)
      @window = glutCreateWindow(title)
    end
  end

  def go_fullscreen
    glutGameModeString([width, height].join("x"))

    if glutGameModeGet(GLUT_GAME_MODE_POSSIBLE)
      glutEnterGameMode
      if glutGameModeGet(GLUT_GAME_MODE_ACTIVE) == 0
        go_windowed
      end
    else
      go_windowed
    end
  end
  
  # begin hooks

  def setup_context
    glEnable(GL_DEPTH_TEST)
    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    glutIgnoreKeyRepeat(1)
  end
  
  def setup
  end
  
  def pre_draw
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity
    gluPerspective(30.0, width / height, 0.1, 1000.0)

    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity
  end
  
  def draw
  end
  
  def post_draw
    glutSwapBuffers
  end
  
  def update(seconds)
  end
  
  def keyboard_down(key, modifiers)
  end
  
  def keyboard_up(key, modifiers)
  end
  
  def special_keyboard_down(key, modifiers)
  end
  
  def special_keyboard_up(key, modifiers)
  end
  
  def mouse_click(button, state, x, y)
  end
  
  def mouse_dragging_motion(x, y)
  end
  
  def mouse_passive_motion(x, y)
  end
  
  def mouse_motion(x, y)
  end
  
  def resize
    # Reset the coordinate system
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity

    # Set the viewport to be the entire window
    glViewport(0, 0, width, height)

    # Set the correct perspective
    gluPerspective(45, width.to_f / height.to_f, 1, 1000)
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity
    gluLookAt(0, 0, 5,
              0, 0, -1,
              0, 1, 0)
  end
  
  # end hooks
  
  def wire
    glutDisplayFunc(lambda do
      pre_draw
      draw
      post_draw
    end)

    glutIdleFunc(lambda do
      time = Time.now
      @last_time ||= time
      delta = time - @last_time
      update(delta)
      @last_time = time
      glutPostRedisplay
    end)

    glutKeyboardFunc(lambda do |key, x, y|
      keyboard_down(key, glutGetModifiers)
    end)

    glutKeyboardUpFunc(lambda do |key, x, y|
      keyboard_up(key, glutGetModifiers)
    end)

    glutSpecialFunc(lambda do |key, x, y|
      special_keyboard_down(key, glutGetModifiers)
    end)

    glutSpecialUpFunc(lambda do |key, x, y|
      special_keyboard_up(key, glutGetModifiers)
    end)

    glutMouseFunc(lambda do |button, state, x, y|
      mouse_click(button, state, x, y)
    end)

    glutMotionFunc(lambda do |x, y|
      mouse_dragging_motion(x, y)
      mouse_motion(x, y)
    end)

    glutPassiveMotionFunc(lambda do |x, y|
      mouse_passive_motion(x, y)
      mouse_motion(x, y)
    end)

    glutReshapeFunc(lambda do |width, height|
      @width = width
      @height = height
      resize
    end)
  end
end
