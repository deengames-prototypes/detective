class Scene_Profiles < Scene_ItemBase
  # Start Processing
  def start
    super
    create_suspects_window
    create_status_window
    create_details_window    
  end

  def create_suspects_window
    @suspect_list = Window_SuspectsList.new
    @suspect_list.viewport = @viewport
    @suspect_list.set_handler(:ok,     method(:on_suspect_ok))
    @suspect_list.set_handler(:cancel, method(:return_scene))
  end

  def create_details_window
    wy = @suspect_list.y + @suspect_list.height
    wh = Graphics.height - wy  - @status_window.height
    @details_window = Window_ItemList.new(0, wy, Graphics.width, wh)
    @details_window.viewport = @viewport
    @suspect_list.details_window = @details_window    
  end
  
  def create_status_window    
    @status_window = Window_SuspectsStatus.new
    @status_window.viewport = @viewport
    @suspect_list.status_window = @status_window
    @status_window.set_handler(:cancel, method(:on_status_cancel))
    @status_window.deactivate
  end

  # when you select a suspect
  def on_suspect_ok    
    @status_window.activate
    @details_window.deactivate
  end
  
  def on_status_cancel
    @status_window.deactivate       
    @suspect_list.activate
  end
end


class Window_SuspectsList < Window_HorzCommand
  attr_reader   :suspect_list, :status_window

  def initialize
    super(0, 0)
  end

  def window_width
    Graphics.width
  end
  
  ### Maximum number of items to show at one time. Items are fixed width :(
  def col_max
    return 6
  end

  def make_command_list
    DetectiveGame::instance.npcs.each do |n|
      add_command(n.name, n.name.to_sym)
    end
  end

  def details_window=(details_window)
    @details_window = details_window
    update
  end
  
  def status_window=(status_window)
    @status_window = status_window
    update
  end
  
  def index=(index)
    super
    return if @status_window.nil?
    # @index is the current window's index. This is how we select their status.
    # TODO: replace with REAL data.
    # 0 = suspicious, 1 = unknown, 2 = innocent
    # select_symbol doesn't work :/
    data = DetectiveGame::instance.notebook.status_for(@index)
    Logger.log("Cursor moved to #{@index}; selecting #{data}")
    @status_window.select(data)    
  end
end

class Window_SuspectsStatus < Window_HorzCommand
  MY_HEIGHT = 48 # reverse-engineered through experimentation
  attr_reader   :suspect_list, :status_window

  def initialize
    super(0, Graphics.height - MY_HEIGHT)
  end

  def window_width
    Graphics.width
  end
  
  ### Maximum number of items to show at one time. Items are fixed width :(
  def col_max
    return 3
  end

  def update
    super
    #@suspect_list.category = current_symbol if @suspect_list    
  end

  def make_command_list
    # These must match the order in notebook.rb's status_for
    ['Suspicious', 'Unknown', 'Innocent'].each do |c|
      add_command(c, c.to_sym)
    end
  end
end