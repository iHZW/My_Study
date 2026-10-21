# frozen_string_literal: true

# 将内容目录和内置旋律注册到三个应用目标，重复运行也不会重复添加。
require 'xcodeproj'

project = Xcodeproj::Project.open(File.expand_path('../My_Study.xcodeproj', __dir__))
group = project.main_group.find_subpath('My_Study/Business/BabyTime', false)
audio_group = group.find_subpath('Audio', false)
raise '找不到宝宝时光项目分组' unless audio_group

resources = [['BabyTimeContent.json', group]]
Dir.glob(File.expand_path('../My_Study/Business/BabyTime/Audio/*.wav', __dir__)).sort.each do |path|
  resources << [File.basename(path), audio_group]
end

targets = project.targets.select { |target| %w[My_Study My_Study_Sit My_Study_Uat].include?(target.name) }
resources.each do |name, parent|
  reference = parent.files.find { |file| file.path == name } || parent.new_file(name)
  targets.each do |target|
    next if target.resources_build_phase.files_references.include?(reference)

    target.resources_build_phase.add_file_reference(reference)
  end
end
project.save
