require 'rake/clean'

CLEAN.include("work_dir/*/", "第*", "./backup")

task :default => [:run]


desc "課題がディレクトリに一つしかなければ実行できる"
task :run => [:check_kadai_num, :clear] do
  sh "ruby lib/auto_check.rb #{kadai_dir}"
end

desc "課題ディレクトリの数をチェック"
task :check_kadai_num do
  kadai_dirs = FileList.new("第*")
  raise "課題が一つに定まりませんでした" unless kadai_dirs.size == 1
end

desc "提出物（./第N回.../）は削除せず生成されたファイルのみ削除"
task :clear => [:init]do
  sh "rm -rf work_dir/*/"
end

desc "提出物をコピーしてバックアップを作成"
task :init do
  if Dir.exist?("backup")
    tmp_kadai_dir = kadai_dir
    sh "rm -rf #{tmp_kadai_dir}"
    sh "cp -rf backup/#{tmp_kadai_dir} ./"
  else
    sh "mkdir backup"
    sh "cp -rf #{kadai_dir} ./backup/"
  end
end

def kadai_dir
  FileList.new("第*").first.gsub(/ /,'\ ')
end
