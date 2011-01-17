module ApplicationHelper

  def simple_tag_cloud tags
    return if tags.empty?
    classes = %w(tag_cloud1 tag_cloud2 tag_cloud3 tag_cloud4 tag_cloud4) 
    
    #! hmmmmmmmmmmmmmm
    max_count = 1000 #tags.sort_by(&:count).last.count.to_f 

    tags.collect { |tag|
      index = ((tag.count / max_count) * (classes.size - 1)).round
      link_to(tag.name, tag_path(tag.name), :class => classes[index])
    }.join(" ")
  end
  
end
