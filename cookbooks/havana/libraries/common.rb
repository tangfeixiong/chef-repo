class Chef
 
  class Recipe
  
    def getRole
      
      # Role Variable
      role = ''
     
      # Find what role was assinged 
      if node['roles'].include?('havana_controller_node')
        role = 'havana_controller_node'
      elsif node['roles'].include?('havana_network_node')
        role = 'havana_network_node'
      elsif node['roles'].include?('havana_compute_node')
        role = 'havana_compute_node'
      else
        role = 'notFound'
      end
      
      # Return role
      return role
      
    end

  end

end