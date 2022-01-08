import Plots
gr()

x,y,z,u,v,w = GenerateRing(1,5,1,2)
x2,y2,z2,u2,v2,w2 = GenerateRing(6,7,1,2)


@gif for frame in range(0, stop = 2pi, length = 50)
    quiver!(x,y,z,quiver=(u,v,w),camera = (40+10*cos(frame),45) )
    quiver!(x2,y2,z2,quiver=(u2,v2,w2))
end