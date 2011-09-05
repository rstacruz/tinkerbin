class Main
  module TemplateHelpers
    def partial(what, locals={})
      haml what, { :layout => false }, locals
    end

    def extends(what, locals={})
      partial what, locals
    end

    # Extensions to content_for
    def has_content?(key)
      return false  unless content_blocks.keys.include?(key.to_sym)
      content_blocks[key.to_sym].any?
    end

    def content_for!(key, &blk)
      content_blocks[key.to_sym] = [ blk ]
    end
  end

  helpers TemplateHelpers
end
