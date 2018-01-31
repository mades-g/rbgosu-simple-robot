require 'rubygems'
require 'gosu'

WIDTH, HEIGHT = 640, 580
PADDING = 10
MOVING_STEP = 5

class Command < Gosu::TextInput
  FONT = Gosu::Font.new(10)
  WIDTH = 350
  LENGTH_LIMIT = 20
  PADDING = 5
  
  INACTIVE_COLOR  = 0xcc_666666
  ACTIVE_COLOR    = 0xcc_ff6666
  SELECTION_COLOR = 0xcc_0000ff
  CARET_COLOR     = 0xff_ffffff
  
  attr_reader :x, :y
  
  def initialize(window, x, y)
    # It's important to call the inherited constructor.
    super()
    
    @window, @x, @y = window, x, y
    
    self.text = "Input Command"
  end

  def filter new_text
    allowed_length = [LENGTH_LIMIT - text.length, 0].max
    new_text[0, allowed_length]
  end
  
  def draw(z)
    if @window.text_input == self
      color = ACTIVE_COLOR
    else
      color = INACTIVE_COLOR
    end
    Gosu.draw_rect x - PADDING, y - PADDING, WIDTH + 2 * PADDING, height + 2 * PADDING, color, z
    
    pos_x = x + FONT.text_width(self.text[0...self.caret_pos])
    sel_x = x + FONT.text_width(self.text[0...self.selection_start])
    sel_w = pos_x - sel_x
    
    Gosu.draw_rect sel_x, y, sel_w, height, SELECTION_COLOR, z

    # Draw the caret if this is the currently selected field.
    if @window.text_input == self
      Gosu.draw_line pos_x, y, CARET_COLOR, pos_x, y + height, CARET_COLOR, z
    end

    # Finally, draw the text itself!
    FONT.draw self.text, x, y, z
  end
  
  def height
    FONT.height
  end

  def under_mouse?
    @window.mouse_x > x - PADDING and @window.mouse_x < x + WIDTH + PADDING and
    @window.mouse_y > y - PADDING and @window.mouse_y < y + height + PADDING
  end
  
  def move_caret_to_mouse
    # Test character by character
    1.upto(self.text.length) do |i|
      if @window.mouse_x < x + FONT.text_width(text[0...i])
        self.caret_pos = self.selection_start = i - 1;
        return
      end
    end
    # Default case: user must have clicked the right edge
    self.caret_pos = self.selection_start = self.text.length
  end
end

# Player class.
class Player
  attr_reader :x, :y, :msg
  def initialize(map,x, y)
    @x, @y = x, y
    @dir = :right #:right :down :top
    @map = map
    @msg = ""
    @standing, @walk1, @walk2, @jump = *Gosu::Image.load_tiles("media/rbgame_ruby.png", 50, 50)
    @cur_image = @standing
    @rbot_allowed_to_move = false
    @init_x = WIDTH - (WIDTH - @map.width) + PADDING # x = 0
    @init_y = HEIGHT - (HEIGHT - @map.height) # y = 0
    @falling = Gosu::Sample.new("media/panic.wav")
  end

  def update(command)
    if !@rbot_allowed_to_move && command == 'PLACE'
      clear_msg
      @rbot_allowed_to_move = true
      place_rbt
    else
      @msg = "First command must be PLACE"
    end

    if(@rbot_allowed_to_move)
      clear_msg
      p_v = @x
      p_y = @y
      case command
        when 'MOVE'
          move_rbt
          @msg = "Moviinnng"
        when 'LEFT'
          set_rbt_direction(:left)
        when 'RIGHT'
          set_rbt_direction(:right)
        when 'REPORT'
          report_rbt_location
      end

      if(is_falling_to_doom)
        @x = p_v
        @y = p_y
        @falling.play
      end
    end
  end

  # rotate 90 degrees acording to direction
  def set_rbt_direction(direction)
    @dir = direction
  end

  # Report robot position
  def report_rbt_location
    @msg = "X =#{@x} Y=#{@y}"
  end

  def clear_msg
    @msg = ""
  end

  # Place rbt at 0,0 relativaly to the map
  def place_rbt
    @x = WIDTH - (WIDTH - @map.width) + PADDING # x = 0
    @y = HEIGHT - (HEIGHT - @map.height) # y = 0
  end

  def move_rbt
    # validate if can move
    # Should move until reach fall
    # Example while not is falling to doom increment step
    steps = 1
    until is_falling_to_doom || steps > MOVING_STEP do
      if @dir == :left
        @x -= 1
      else
        @x += 1
      end
      steps += 1
    end
  end

  # o.o no no
  def is_falling_to_doom
    return (
      (@x < @init_x ||
      @x > @init_x + @map.width - @cur_image.width + PADDING) ||
      (@y < @init_y ||
      @y > @init_y + @map.height - @cur_image.height - PADDING)
      )
  end

  def draw
    if @dir == :left
      factor = 1.0
      off_set_x = 0
    else
      factor = -1.0
      off_set_x = 55
    end

    @cur_image.draw(@x + off_set_x, @y, 0, factor, 1.0)
  end

end

class RobotGame < (MainWindow rescue Gosu::Window)
  def initialize
    super WIDTH, HEIGHT
    self.caption = "Robot Ruby Game"
    command_label = "Command:"
    @command = Gosu::Image.from_text command_label, 20, :width => 540
    @message = Gosu::Font.new(20)
    @text_fields = Array.new(1) { |index| Command.new(self, 150, 52) }    
    @map = Gosu::Image.new("media/table.png")
    @rbot = Player.new(@map, (WIDTH - self.width) / 2, (HEIGHT - self.height) / 2)
    @background_image = Gosu::Image.new "media/space.png"
  end
  
  def needs_cursor?
    true
  end

  def draw
    @rbot.draw
    @command.draw 50, 50, 0
    @message.draw("Message: #{@rbot.msg}",50, HEIGHT - 80, 0)
    @text_fields.each { |tf| tf.draw(0) }
    @map.draw (WIDTH - @map.width) / 2, (HEIGHT - @map.height) / 2, -1
    @background_image.draw 0, 0, -2
  end
  
  def button_down(id)
    if id == Gosu::MS_LEFT
      # Mouse click: Select text field based on mouse position.
      self.text_input = @text_fields.find { |tf| tf.under_mouse? }
      # Also move caret to clicked position
      self.text_input.move_caret_to_mouse unless self.text_input.nil?
    end
    if id == Gosu::KB_RETURN
      if self.text_input != nil
        command_input = self.text_input.text
        @rbot.update(command_input)
      end
    elsif id == Gosu::KB_ESCAPE
      close
    else
      super
    end
  end

  def update
    # depending on commands move
    # @rbot.update(move_x)
  end
end

RobotGame.new.show if __FILE__ == $0
