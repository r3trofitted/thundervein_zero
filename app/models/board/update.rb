class Board
  class Update
    delegate :size, :[], to: :@zones_with_types
    
    def initialize(**zones_with_types)
      @zones_with_types = zones_with_types
    end
  end
end
