class Main
  module AttrHelpers
    def active_if(condition)
      condition ? {:class => 'active'} : {}
    end

    def checked_if(condition)
      condition ? {:checked => '1'} : {}
    end

    def selected_if(condition)
      condition ? {:selected => '1'} : {}
    end

    def disabled_if(condition)
      condition ? {:disabled => '1'} : {}
    end

    def enabled_if(condition)
      disabled_if !condition
    end
  end

  helpers AttrHelpers
end
