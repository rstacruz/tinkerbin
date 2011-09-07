class Main
  module TemplateHelpers
    def partial(what, locals={})
      haml what, { :layout => false }, locals
    end
  end

  helpers TemplateHelpers
end
