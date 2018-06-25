module ProcessPath
  def extract_id_and_name(path)
    path.scan(/\/(\d+)\((.+),\)\//).first
  end
end
