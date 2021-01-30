users = []
5.times do |i|
  u = User.create(first_name: "user_#{i+1}", last_name: "user_#{i+1}_last_name", email: "test_#{i+1}@test.com", password_digest: BCrypt::Password.create("12#{i}"))
  users << u.id
end

projects = []
3.times do |i|
  p = Project.create(user_id: users.sample, project_name: "Project_#{i+1}")
  projects << p.id
end

status = ['Open', 'In Progress', 'Resolved', 'Reopen', 'Closed']

20.times do |i|
  Task.create(project_id: projects.sample, user_id: users.sample, task_name: "Тестовая задача #{i+1}", description: "Здесь должно быть описание #{i+1}-ой задачи", status: status.sample, performer_id: users.sample, due_date: Date.today + rand(15), implementation_time: "")
end
