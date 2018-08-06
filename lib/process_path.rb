module ProcessPath
  def extract_id_and_name(path)
  
 	# 課題の場合はIDと名前をとる
  	if m = path.match(/\/(\d+)\((.+),\)\//)
  	  [m[1], m[2]]
  	  
  	# 中間と期末テストの場合は名前だけとる  
  	else
  	  m = path.match(/\/([^_]+)__/)
  	  ["#", m[1]]
  	end
  end
end
