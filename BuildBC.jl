function BuildBC(ring::Tuple,ringType="copper"::String)
    x,y,z,u,v,w=ring
    ringType == "brass" ? quiver!(x,y,z,quiver=(u,v,w),color=:viridis) : quiver!(x,y,z,quiver=(u,v,w),color=:hsv) 
end

