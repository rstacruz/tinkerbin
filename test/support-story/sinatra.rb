class StoryTest
  def self.production(name, &blk)
    describe("Production tests #{name}") {
      setup { app.expects(:environment).returns(:production) }
      yield
    }
  end
end
