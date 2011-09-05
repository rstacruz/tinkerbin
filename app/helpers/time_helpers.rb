class Main
  module TimeHelpers
    def show_date(date)
      date.strftime("%B %d, %Y")
    end
  end

  helpers TimeHelpers
end
