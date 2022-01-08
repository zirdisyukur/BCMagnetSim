
"Pass in a tuple of x y z coordinates of points and their directions for vectors with u v w, pass three arrays as tuples
optional: rotate::bool"
function VisualizeRing(ring::Tuple,rotate=true)
    ##Using GenerateRing.jl Instead
    @gif for frame in range(0, stop = 2pi, length = 50)
        x,y,z,u,v,w = ring
        if(rotate)
            quiver(x,y,z,quiver=(u,v,w),camera = (40+10*cos(frame),45))
        else
            quiver(x,y,z,quiver=(u,v,w),camera = (45,45) )
        end
    end
end