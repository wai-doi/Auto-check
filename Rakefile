require 'rake/clean'

CLEAN.include("work_dir/*/", "第*")

desc "提出物（./第N回.../）は削除せず生成されたファイルのみ削除"
task :clear do
  sh "rm -rf work_dir/*/"
end

desc "課題がディレクトリに一つしかなければ実行できる"
task :run => [:clear] do
  kadai_dirs = FileList.new("第*")
  if kadai_dirs.size == 1
    sh "ruby lib/auto_check.rb #{kadai_dirs.first.gsub(/ /,'\ ')}"
  else
    raise "課題が一つに定まりませんでした"
  end
end
