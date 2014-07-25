class ScrOrganizacion < ActiveRecord::Base
  self.table_name = "scr_organizacion"
  belongs_to :"scr_cat_organizacion"	
end

#    <%= f.collection_select(:localidad_id, :localidad_id, ScrLocalidad.all, :id, :id) %>
#    <% cities_array = City.all.map { |city| [city.name, city.id] } %>
#<%= options_for_select(cities_array) %>
#<%= options_from_collection_for_select(City.all, :id, :name) %>
