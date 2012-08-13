module ApplicationHelper

  def sortable(column, title = nil)
    title ||= column.titleize
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    link_to title, entrytable_path(:sort => column, :direction => direction, 
                                   :myfrom => @myfrom, :myto => @myto, 
                                   :filter_projects => @filter_projects), :remote => true
  end


end
