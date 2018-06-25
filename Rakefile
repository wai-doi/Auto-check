require 'rake/clean'

CLEAN.include("work_dir/*/", "第*")

desc "提出物（./第N回.../）は削除せず生成されたファイルのみ削除"
task :clear do
  sh "rm -rf work_dir/*/"
end
