class Chef
 
  class Recipe
  
    def getRole
      
      # Role Variable
      role = ''
     
      # Find what role was assinged 
      if node['roles'].include?('controller_node')
        role = 'controller_node'
      elsif node['roles'].include?('network_node')
        role = 'network_node'
      elsif node['roles'].include?('compute_node')
        role = 'compute_node'
      else
        role = 'notFound'
      end
      
      # Return role
      return role
      
    end

  end

end