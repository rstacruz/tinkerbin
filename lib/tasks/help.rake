def task_categories
  tasks = Rake.application.tasks
  tasks.reject! { |t| t.full_comment.to_s.strip.empty? }
  categories = Hash.new { |h, k| h[k] = Array.new }

  tasks.each do |task|
    category = task.full_comment.match(/\[([^\]]*)\]$/) && $1 || 'Other'
    categories[category] << task
  end

  categories
end

task(:help) {
  task_categories.each do |cat, tasks|
    puts "%s tasks:" % [cat]
    tasks.each do |task|
      desc = task.full_comment
      desc.gsub! /\[([^\]]*)\]$/, ''
      puts "  rake %-15s - %s" % [ task.name, desc ]
    end
    puts ""
  end
}
