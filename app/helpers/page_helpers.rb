class Main
  module PageHelpers
    def body_class(v = nil)
      @body_classes ||= []
      @body_classes << v  if v

      @body_classes.join(' ')
    end

    def title(title=nil)
      @page_title = title  if title
      @page_title
    end
  end

  helpers PageHelpers
end
