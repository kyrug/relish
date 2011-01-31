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
  
  def via_url(url)
    content_tag('span', t('via') + ' ' + URI.parse(url).host)
  end
  
  def tag_crumbs(tags)
    raw tags.collect{|t| link_to(t, tag_path(t)) }.join('')
  end
  
  def link_to_your_bookmarks
    raw "#{t('see')} #{link_to(t('your_bookmarks'), user_bookmarks_path(current_user))}" if current_user
  end
  
  def link_to_bookmarks_page
    if current_user
      link_to(t('bookmarks.label'), user_bookmarks_path(current_user))
    else
      link_to(t('bookmarks.label'), popular_path)
    end
  end
  
end