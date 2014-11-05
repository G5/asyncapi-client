def indifferent_hash(json)
  parsed_json = JSON.parse(json)
  if parsed_json.respond_to?(:with_indifferent_access)
    parsed_json.with_indifferent_access
  elsif parsed_json.respond_to?(:map)
    parsed_json.map(&:with_indifferent_access)
  end
end
