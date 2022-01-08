using Plots
gr()

#lineRes determines how much points per line, number of vectors in a ring is:
# lineRes * ringWidthRes * ringHeightRes

"Generate Ring: (startingHeight::Int,endingHeight::Int,innerRadius::Int,outerRadius::Int, optional: lineRes (10)
, ringWidthRes (2), ringHeightRes(2), ringSlitAngle(0), arrowRes=0.1"
function GenerateRing(startingHeight::Int,endingHeight::Int,innerRad::Int,outerRad::Int,
    lineRes=50, ringWidthRes=5,ringHeightRes=5,ringSlitAngle=2*pi/12,arrowRes=0.1)

    #initialization for x,y,z array coordinates (1 dim)
    x=[]
    y=[]
    z=[]

    #T range defines how each line is divided into lineRes number of vectors
    t=range(0,length=lineRes,step=(2*pi-ringSlitAngle)/lineRes)
    #println(t)

    #for each ring width in j, add another x array with same circle shape with different amplitudes j
    for j in range(innerRad, stop = outerRad, length = ringWidthRes)
        x=cat( x , j*cos.(t) ,dims=1)
        y=cat( y , j*sin.(t) ,dims=1)
    end

    #for each ring ring height in i, define a z value with equaly spaced heights from startingHeight to endingHeight
    pointsPerRing = length(x)
    for i in range(startingHeight, stop = endingHeight, length = ringHeightRes)
        z=cat( z , fill(i,pointsPerRing),dims=1)
    end

    #Adjusting x and y arrays so that length matches number of z entries (copy pasting)
    numLayers = length(range(startingHeight, stop = endingHeight, length = ringHeightRes))
    tempX = copy(x)
    tempY = copy(y)
    for layer in 1:numLayers-1
        x=cat( x , tempX ,dims = 1)
        y=cat( y , tempY ,dims = 1)
    end

    #defines vector directions, u, v are standardized to an ring's current. adjusted by arrowRes parameter. w is always 0**seeissues
    #u,v,w length do not match x,y,z, but loop after being done.
    u=-sin.(t) * arrowRes
    v=cos.(t) * arrowRes
    w=fill(0,100)
    
    #=stats
    b=x,y,z,u,v,w
    println("this is lengths of x,y,z,u,v,w: ", length.(b))
    println("This ring has ", ringHeightRes, " vertical layers, ", ringWidthRes, " horizontal layers, and" , lineRes,
     " vectors per line. This results in ", ringHeightRes * ringWidthRes * lineRes, " vectors defined
      in this ring")
     =#

    #returnign ring data as tuple
    return x,y,z,u,v,w;
end

#ISSSUEEESS

#can't see direction of arrows
#Code fails with 1 Dimensional or 2 Dimensional Rings (lines and disks) 
#Why does visualization of vectors fail if w is filled with less zeroes than 100