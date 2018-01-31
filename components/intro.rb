require 'gosu'

WIDTH, HEIGHT = 640, 580

class Welcome < (MainWindow rescue Gosu::Window)
  PADDING = 20
  
  def initialize
    super WIDTH, HEIGHT
    
    self.caption = "Robot Game Overview"
    
    text =
      "<b>Descripition:</b>

      The origin (0,0) can be considered to be the SOUTH WEST most corner.
      he first valid command to the robot is a PLACE command, after that, any sequence of commands may be issued, in any order, including another PLACE command. The application should discard all commands in the sequence until a valid PLACE command has been executed.
      MOVE will move the toy robot one unit forward in the direction it is currently facing.
      LEFT and RIGHT will rotate the robot 90 degrees in the specified direction without changing the position of the robot.
      RREPORT will announce the X,Y and orientation of the robot.
      A robot that is not on the table can choose to ignore the MOVE, LEFT, RIGHT and REPORT commands.

      The robot is free to roam around, but must not fall to is doom.
      • To exit the game, press <b>Esc</b>.

      Constraints: 
      • The toy robot must not fall off the table during movement.
      • This also includes the initial placement of the toy robot.
      • Any move that would cause the robot to fall must be ignored.

      List of Commands (Write inside command input):
      • PLACE - a must to init.
      • MOVE - move according to position
      • LEFT - RIGHT ( rotate 90e depeding on direction)
      • REPORT - repot x,y position
      "
    
    @text = Gosu::Image.from_text text, 20, :width => WIDTH - 2 * PADDING
    
    @background_image = Gosu::Image.new "media/space.png"
  end
  
  def draw
    @background_image.draw 0, 0 ,0
    @text.draw PADDING, PADDING, 0
  end
end

Welcome.new.show if __FILE__ == $0
