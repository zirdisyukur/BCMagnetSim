using Plots: _axis_defaults
using Plots
gr()

#lineRes=100
#ringWidthRes=5
#ringHeightRes=5
ringSlitAngle=30*0.5*2.79*pi/180
arrowRes=0.1
layer=0
angHoffBC=1.0*pi
numberCuLayers=26

"Generates a ring"
function GenerateSingleRing(Height::Number,Rad::Number,
    lineRes::Number,ringSlitAngle=0.5*2.79*pi/180;arrowRes=1,layer=0,BCType="CCHE")

    #normal ringSlitAngle 0.5*2.79*pi/180
    #initialization for x,y,z array coordinates (1 dim)
    x=[]
    y=[]
    z=[]
    u=[]
    v=[]
    w=[]

    #ringHeight = abs(endingHeight-startingHeight)
    #ringWidth = abs(outerRad-innerRad)
    #volElementHeight = ringHeight / ringHeightRes
    #volElementWidth = ringWidth / ringWidthRes


    #possible types of rings, CCHE, CCHO, CCE, CCO, CBHE, CBHO, CBE, CBO
    #          
    
     #T range defines how each line is divided into lineRes number of vectors, is different for different rings because 
    #they have different starting points for ring slitsBBH, BCH, BB, BC
    type = BCType
    if(BCType=="BC__") #if ring is Brass Curvature
        directionCurrent=-1
        t=range(ringSlitAngle,length=lineRes,step=(2*pi-2*ringSlitAngle)/lineRes)

    elseif(BCType=="BB__") #if ring is Brass Bias
        directionCurrent=1
        t=range(-pi/5+ringSlitAngle,length=lineRes,step=(2*pi-2*ringSlitAngle)/lineRes)

    elseif(BCType=="BBH_") #if ring is Bras Bias Bottomside
        directionCurrent=1
        t=range(angHoffBC-pi/5+ringSlitAngle,length=lineRes,step=(2*pi-2*ringSlitAngle)/lineRes)

    elseif(BCType=="BCH_") #if ring is Brass Curvature Bottomside
        directionCurrent=-1
        t=range(angHoffBC+ringSlitAngle,length=lineRes,step=(2*pi-2*ringSlitAngle)/lineRes)

    elseif(BCType=="CBE_" || BCType=="CBO_") #if ring is Copper Bias
        directionCurrent=1
        t=range((-layer-1)*pi/5+ringSlitAngle,length=lineRes,step=(2*pi-2*ringSlitAngle)/lineRes)
        
    elseif(BCType=="CBHE" || BCType=="CBHO") #if ring is Copper Bias Bottomside
        directionCurrent=1
        t=range(angHoffBC+(-layer-1)*pi/5+ringSlitAngle,length=lineRes,step=(2*pi-2*ringSlitAngle)/lineRes)

    elseif(BCType=="CCE_" || BCType=="CCO_") #if ring is Copper Curvature
        directionCurrent=-1
        t=range((layer)*pi/5+ringSlitAngle,length=lineRes,step=(2*pi-2*ringSlitAngle)/lineRes)

    elseif(BCType=="CCHE" || BCType=="CCHO") #if ring is Copper Curvature Bottomside
        directionCurrent=-1
        t=range(angHoffBC+(layer)*pi/5+ringSlitAngle,length=lineRes,step=(2*pi-2*ringSlitAngle)/lineRes)
    else
        print(BCType)
        error("invalid type of BCType")
    end
    


    #for each ring width in j, add another x array with same circle shape with different amplitudes j
    #for j in 1:ringWidthRes
    #    radialCoordVolElement = (volElementWidth * (j - 0.5) + innerRad)
    #    x=cat( x , radialCoordVolElement*cos.(t) ,dims=1)
    #    y=cat( y , radialCoordVolElement*sin.(t) ,dims=1)
    #end

    x=cat( x , Rad*cos.(t) ,dims=1)
    y=cat( y , Rad*sin.(t) ,dims=1)
    z=cat( z , fill(Height,length(x)),dims=1)

    #for each ring ring height in i, define a z value with equaly spaced heights from startingHeight to endingHeight
    #pointsPerRing = length(x)
    #for i in 1:ringHeightRes
    #    heightCoordVolelement = (volElementHeight * (i - 0.5) + startingHeight)
    #    z=cat( z , fill(heightCoordVolelement,pointsPerRing),dims=1)
    #end

    #Adjusting x and y arrays so that length matches number of z entries (copy pasting)
    #numLayers = length(range(startingHeight, stop = endingHeight, length = ringHeightRes))
    #tempX = copy(x)
    #tempY = copy(y)
    #for layer in 1:numLayers-1
    #    x=cat( x , tempX ,dims = 1)
    #    y=cat( y , tempY ,dims = 1)
    #end

    #defines vector directions, u, v are standardized to an ring's current. adjusted by arrowRes parameter. w is always 0**seeissues
    #u,v,w length do not match x,y,z, but loop after being done.

    #for j in range(innerRad, stop = outerRad, length = ringWidthRes)
    #    u=cat( u , directionCurrent*sin.(t) ,dims=1)
    #    v=cat( v , directionCurrent*cos.(t) ,dims=1)
    #end

    u=cat( u , directionCurrent*sin.(t) ,dims=1)
    v=cat( v , directionCurrent*cos.(t) ,dims=1)

    u=u*(-1)*arrowRes
    v=v*arrowRes
    #u=-sin.(t) * 0.5
    #v=cos.(t) * 0.5
    w=fill(0,100)
    
    #=stats
    b=x,y,z,u,v,w
    println("this is lengths of x,y,z,u,v,w: ", length.(b))
    println("This ring has ", ringHeightRes, " vertical layers, ", ringWidthRes, " horizontal layers, and" , lineRes,
     " vectors per line. This results in ", ringHeightRes * ringWidthRes * lineRes, " vectors defined
      in this ring")
    =#


    #returnign ring data as tuple
    return x,y,z,u,v,w,type;
end

"Generates a cylinder, comprised of rigns: (startingHeight::Int,endingHeight::Int,innerRadius::Int,outerRadius::Int, optional: lineRes (10)
, ringWidthRes (2), ringHeightRes(2), ringSlitAngle(0), arrowRes=0.1"
function GenerateRing(startingHeight::Number,endingHeight::Number,innerRad::Number,outerRad::Number,
    lineRes=lineRes, ringWidthRes=ringWidthRes,ringHeightRes=ringHeightRes,ringSlitAngle=0.5*2.79*pi/180;arrowRes=1,layer=0,BCType="CCHE")

    #normal ringSlitAngle 0.5*2.79*pi/180
    #initialization for x,y,z array coordinates (1 dim)
    x=[]
    y=[]
    z=[]
    u=[]
    v=[]
    w=[]

    ringHeight = abs(endingHeight-startingHeight)
    ringWidth = abs(outerRad-innerRad)
    volElementHeight = ringHeight / ringHeightRes
    volElementWidth = ringWidth / ringWidthRes


    #possible types of rings, CCHE, CCHO, CCE, CCO, CBHE, CBHO, CBE, CBO
    #          
    
     #T range defines how each line is divided into lineRes number of vectors, is different for different rings because 
    #they have different starting points for ring slitsBBH, BCH, BB, BC
    type = BCType
    if(BCType=="BC__") #if ring is Brass Curvature
        directionCurrent=-1
        t=range(ringSlitAngle,length=lineRes,step=(2*pi-2*ringSlitAngle)/lineRes)

    elseif(BCType=="BB__") #if ring is Brass Bias
        directionCurrent=1
        t=range(-pi/5+ringSlitAngle,length=lineRes,step=(2*pi-2*ringSlitAngle)/lineRes)

    elseif(BCType=="BBH_") #if ring is Bras Bias Bottomside
        directionCurrent=1
        t=range(angHoffBC-pi/5+ringSlitAngle,length=lineRes,step=(2*pi-2*ringSlitAngle)/lineRes)

    elseif(BCType=="BCH_") #if ring is Brass Curvature Bottomside
        directionCurrent=-1
        t=range(angHoffBC+ringSlitAngle,length=lineRes,step=(2*pi-2*ringSlitAngle)/lineRes)

    elseif(BCType=="CBE_" || BCType=="CBO_") #if ring is Copper Bias
        directionCurrent=1
        t=range((-layer-1)*pi/5+ringSlitAngle,length=lineRes,step=(2*pi-2*ringSlitAngle)/lineRes)
        
    elseif(BCType=="CBHE" || BCType=="CBHO") #if ring is Copper Bias Bottomside
        directionCurrent=1
        t=range(angHoffBC+(-layer-1)*pi/5+ringSlitAngle,length=lineRes,step=(2*pi-2*ringSlitAngle)/lineRes)

    elseif(BCType=="CCE_" || BCType=="CCO_") #if ring is Copper Curvature
        directionCurrent=-1
        t=range((layer)*pi/5+ringSlitAngle,length=lineRes,step=(2*pi-2*ringSlitAngle)/lineRes)

    elseif(BCType=="CCHE" || BCType=="CCHO") #if ring is Copper Curvature Bottomside
        directionCurrent=-1
        t=range(angHoffBC+(layer)*pi/5+ringSlitAngle,length=lineRes,step=(2*pi-2*ringSlitAngle)/lineRes)

    else
        print(BCType)
        error("invalid type of BCType")
    end
    
    #=
    if(type=="brassC")
        t=range(ringSlitAngle,length=lineRes,step=(2*pi-2*ringSlitAngle)/lineRes)
    elseif(type=="brassB")
        t=range(-pi/5+ringSlitAngle,length=lineRes,step=(2*pi-2*ringSlitAngle)/lineRes)
    elseif(type=="brassCH")
        t=range(angHoffBC-pi/5+ringSlitAngle,length=lineRes,step=(2*pi-2*ringSlitAngle)/lineRes)
    elseif(type=="brassBH")
        t=range(angHoffBC+ringSlitAngle,length=lineRes,step=(2*pi-2*ringSlitAngle)/lineRes)
    else
        t=range((layer)*pi/5+ringSlitAngle,length=lineRes,step=(2*pi-2*ringSlitAngle)/lineRes)
    end
    =#

    #for each ring width in j, add another x array with same circle shape with different amplitudes j
    for j in 1:ringWidthRes
        radialCoordVolElement = (volElementWidth * (j - 0.5) + innerRad)
        x=cat( x , radialCoordVolElement*cos.(t) ,dims=1)
        y=cat( y , radialCoordVolElement*sin.(t) ,dims=1)
    end

    #for each ring ring height in i, define a z value with equaly spaced heights from startingHeight to endingHeight
    pointsPerRing = length(x)
    for i in 1:ringHeightRes
        heightCoordVolelement = (volElementHeight * (i - 0.5) + startingHeight)
        z=cat( z , fill(heightCoordVolelement,pointsPerRing),dims=1)
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


    for j in range(innerRad, stop = outerRad, length = ringWidthRes)
        u=cat( u , directionCurrent*sin.(t) ,dims=1)
        v=cat( v , directionCurrent*cos.(t) ,dims=1)
    end

    u=u*(-1)*arrowRes
    v=v*arrowRes
    #u=-sin.(t) * 0.5
    #v=cos.(t) * 0.5
    w=fill(0,100)
    
    #=stats
    b=x,y,z,u,v,w
    println("this is lengths of x,y,z,u,v,w: ", length.(b))
    println("This ring has ", ringHeightRes, " vertical layers, ", ringWidthRes, " horizontal layers, and" , lineRes,
     " vectors per line. This results in ", ringHeightRes * ringWidthRes * lineRes, " vectors defined
      in this ring")
    =#


    #returnign ring data as tuple
    return x,y,z,u,v,w,type;
end


"Generate Current carrying rectangle"
function GenerateRectangle(centerOfMass::Tuple, dimensionsXYZ::Tuple, currentDirection::Tuple, ScrewType="ScrewB")

    #normal ringSlitAngle 0.5*2.79*pi/180
    #initialization for x,y,z array coordinates (1 dim)
    x=[]
    y=[]
    z=[]
    u=[]
    v=[]
    w=[]

    XSANumPoints = recRes * recRes
    totalPoints = XSANumPoints * recHeightRes
    volElementWidth = 5/recRes
    volElementHeight = 5/recRes

    if(ScrewType=="ScrewB") #if ring is Brass Curvature

    elseif(ScrewType=="ScrewC") #if ring is Brass Bias
    elseif(ScrewType=="ScrewBH") #if ring is Bras Bias Bottomside
    elseif(ScrewType=="ScrewCH") #if ring is Brass Curvature Bottomside  
    elseif(ScrewType=="SpacerC") #if ring is Bras Bias Bottomside
    elseif(ScrewType=="SpacerB") #if ring is Brass Curvature Bottomside   
    elseif(ScrewType=="SpacerCH") #if ring is Bras Bias Bottomside
    elseif(ScrewType=="SpacerBH") #if ring is Brass Curvature Bottomside

    else
        print(ScrewType)
        error("invalid type of ScrewType")
    end
    
    if(recRes == 1)
        x = centerOfMass[1]
        y = centerOfMass[2]
    #for XSA
    else

        #x values
        for i in 1:recRes
            for j in range( (-1)(recRes-1), stop = (recRes-1), length = recRes )
                #println("j = ",j)
                if (recRes % 2 == 0)
                    x=cat( x , centerOfMass[1] + (dimensionsXYZ[1] / (2 * recRes) * j),dims=1)  
                    #println(x)  
                elseif (recRes % 2 != 0) #if ringRes is odd
                    x=cat( x , centerOfMass[1] + (dimensionsXYZ[1] / (2 * recRes) * j), dims = 1)
                    #println(x) 
                end
                #copy x values to repeat 
            end
        end



        #y values
        #pointsPerRing = length(x)
        for i in range( (-1)(recRes-1), stop = (recRes-1), length = recRes )

            if (recRes % 2 == 0)
                for l in 1:recRes
                    y=cat( y , centerOfMass[2] + (dimensionsXYZ[2] / (2 * recRes) * i),dims=1) 
                end   
            elseif (recRes % 2 != 0) #if ringRes is odd
                for l in 1:recRes
                    y=cat( y , centerOfMass[2] + (dimensionsXYZ[2] / (2 * recRes) * i), dims = 1)
                end
            end

            #copy x values to repeat 

        end

        #z values
        for i in range( (-1)(recHeightRes-1), stop = (recHeightRes-1), length = recHeightRes )

            if (recHeightRes % 2 == 0)
                for l in 1:XSANumPoints
                    z=cat( z , centerOfMass[3] + (dimensionsXYZ[3] / (2 * recHeightRes) * i),dims=1) 
                end   
            elseif (recHeightRes % 2 != 0) #if ringHeightRes is odd
                for l in 1:XSANumPoints
                    z=cat( z , centerOfMass[3] + (dimensionsXYZ[3] / (2 * recHeightRes) * i), dims = 1)
                end
            end

            #copy x values to repeat 

        end

    end
    #Adjusting x and y arrays so that length matches number of z entries (copy pasting)
    numLayers = length(z)/length(x)
    tempX = copy(x)
    tempY = copy(y)
    for layer in 1:numLayers-1
        x=cat( x , tempX ,dims = 1)
        y=cat( y , tempY ,dims = 1)
    end

    #defines vector directions, u, v are standardized to an ring's current. adjusted by arrowRes parameter. w is always 0**seeissues
    #u,v,w length do not match x,y,z, but loop after being done.

    lengthXYZ = length(x)
    u = fill(currentDirection[1],length(x))
    v = fill(currentDirection[2],length(x))
    w = fill(currentDirection[3],length(x))

    #for j in range(innerRad, stop = outerRad, length = ringWidthRes)
    #    u=cat( u , directionCurrent*sin.(t) ,dims=1)
    #    v=cat( v , directionCurrent*cos.(t) ,dims=1)
    #end

    #u=u*(-1)*arrowRes
    #v=v*arrowRes
    #u=-sin.(t) * 0.5
    #v=cos.(t) * 0.5
    #w=fill(0,100)
    
    #=stats
    b=x,y,z,u,v,w
    println("this is lengths of x,y,z,u,v,w: ", length.(b))
    println("This ring has ", ringHeightRes, " vertical layers, ", ringWidthRes, " horizontal layers, and" , lineRes,
     " vectors per line. This results in ", ringHeightRes * ringWidthRes * lineRes, " vectors defined
      in this ring")
    =#


    #returnign ring data as tuple
    return x,y,z,u,v,w,ScrewType;
end

begin #BuildBC Methods
    "Function BUILBC accepts a tupple of x,y,z,u,v,w values for a ring and superimposes ring onto plot
    optional: specify rin gtype as copper, brass or copperEven
    which determines coloration of render. "
    function BuildBC(ring::Tuple,BCType::String)

        x,y,z,u,v,w=ring

        if(BCType=="CBHE" || BCType=="CBE_") # Copper Biases on Even layer
            quiver!(x,y,z,quiver=(u,v,w),color=:blue)
        elseif(BCType=="CBHO" || BCType=="CBO_") #Copper biases on odd layer
            quiver!(x,y,z,quiver=(u,v,w),color=:red)
        elseif(BCType=="CCHE"|| BCType=="CCE_") #Copper curavture on even layer
            quiver!(x,y,z,quiver=(u,v,w),color=:orange) 
        elseif(BCType=="CCHO" ||BCType=="CCO_") #Copper Curvature on odd layer
            quiver!(x,y,z,quiver=(u,v,w),color=:purple) 
        elseif(BCType=="BCH_" || BCType=="BC__") #Brass Curvature
            quiver!(x,y,z,quiver=(u,v,w),color=:black) 
        elseif(BCType=="BBH_" || BCType=="BB__") #Brass Bias
            quiver!(x,y,z,quiver=(u,v,w),color=:black)
        elseif(BCType=="ScrewBH") #Brass Bias
            #quiver!(x,y,z,quiver=(u,v,w),color=:black)
            VisualizeRec(ring)
        elseif(BCType=="ScrewB") #Brass Bias
            VisualizeRec(ring)
            #quiver!(x,y,z,quiver=(u,v,w),color=:red)
        elseif(BCType=="ScrewCH") #Brass Bias
            #quiver!(x,y,z,quiver=(u,v,w),color=:blue)
            #print("done")
            VisualizeRec(ring)
        elseif(BCType=="ScrewC") #Brass Bias
            VisualizeRec(ring)
            #quiver!(x,y,z,quiver=(u,v,w),color=:purple)
        else
            error("invalid type of BCType")
        end
    end

    "Function BUILBC accepts a RECTANGLE of x,y,z,u,v,w values for a ring and superimposes ring onto plot
    optional: specify rin gtype as copper, brass or copperEven
    which determines coloration of render. "
    function BuildBCScrews(rec::Tuple,BCType::String)

        x,y,z,u,v,w=rec

        if(BCType=="ScrewB") # Copper Biases on Even layer
            quiver!(x,y,z,quiver=(u,v,w),color=:blue)
            #print("done1")
        elseif(BCType=="ScrewBH") #Copper biases on odd layer
            quiver!(x,y,z,quiver=(u,v,w),color=:red)
            #print("done2")
        elseif(BCType=="ScrewC") #Copper curavture on even layer
            quiver!(x,y,z,quiver=(u,v,w),color=:orange) 
            #print("done3")
        elseif(BCType=="ScrewCH") #Copper Curvature on odd layer
            quiver!(x,y,z,quiver=(u,v,w),color=:purple) 
            #print("done4")
        elseif(BCType=="SpacerC") #Copper Curvature on odd layer
            quiver!(x,y,z,quiver=(u,v,w),color=:blue) 
            #print("done4")
        elseif(BCType=="SpacerB") #Copper Curvature on odd layer
            quiver!(x,y,z,quiver=(u,v,w),color=:red) 
            #print("done4")
        elseif(BCType=="SpacerCH") #Copper Curvature on odd layer
            quiver!(x,y,z,quiver=(u,v,w),color=:orange) 
            #print("done4")
        elseif(BCType=="SpacerBH") #Copper Curvature on odd layer
            quiver!(x,y,z,quiver=(u,v,w),color=:purple) 
            #print("done4")
        
        else
            error("invalid type of BCType")
        end
    end

    "Function BuildBC_2D is 2D render of ring given two axes"
    function BuildBC(ring::Tuple,BCType::String,axes::String)

        x,y,z,u,v,w=ring
 
        if(axes=="xz"||axes=="zx")
            a=x
            b=z
            c=u
            d=w
        elseif(axes=="xy"||axes=="yx")
            a=x
            b=y
            c=u
            d=v
        else #zy or yz case
            a=y
            b=z
            c=v
            d=w
        end

        if(BCType=="CBHE" || BCType=="CBE_") # Copper Biases on Even layer
            quiver!(a,b,quiver=(c,d),color=:blue)
        elseif(BCType=="CBHO" || BCType=="CBO_") #Copper biases on odd layer
            quiver!(a,b,quiver=(c,d),color=:red)
        elseif(BCType=="CCHE"|| BCType=="CCE_") #Copper curavture on even layer
            quiver!(a,b,quiver=(c,d),color=:orange)
        elseif(BCType=="CCHO" ||BCType=="CCO_") #Copper Curvature on odd layer
            quiver!(a,b,quiver=(c,d),color=:purple)
        elseif(BCType=="BCH_" || BCType=="BC__") #Brass Curvature
            quiver!(a,b,quiver=(c,d),color=:black)
        elseif(BCType=="BBH_" || BCType=="BB__") #Brass Bias
            quiver!(a,b,quiver=(c,d),color=:black)
        else
            error("invalid type of BCType")
        end

    end

    "2D VERSION!!!! Function BUILBC accepts a RECTANGLE of x,y,z,u,v,w values for a ring and superimposes ring onto plot
    optional: specify rin gtype as copper, brass or copperEven
    which determines coloration of render. "
    function BuildBCScrews(rec::Tuple,BCType::String,axes::String)
        x,y,z,u,v,w=rec
 
        if(axes=="xz"||axes=="zx")
            a=x
            b=z
            c=u
            d=v
            e=w
        elseif(axes=="xy"||axes=="yx")
            a=x
            b=y
            c=u
            d=v
            e=w
        else #zy or yz case
            a=y
            b=z
            c=v
            d=w
        end

        if(BCType=="ScrewB") # Copper Biases on Even layer
            quiver!(a,b,quiver=(c,d,e),color=:blue)
        elseif(BCType=="ScrewC") #Copper biases on odd layer
            quiver!(a,b,quiver=(c,d,e),color=:red)
        elseif(BCType=="ScrewBH") #Copper curavture on even layer
            quiver!(a,b,quiver=(c,d,e),color=:orange)
        elseif(BCType=="ScrewCH") #Copper Curvature on odd layer
            quiver!(a,b,quiver=(c,d,e),color=:purple)
        elseif(BCType=="SpacerC") #Copper curavture on even layer
            quiver!(a,b,quiver=(c,d,e),color=:blue)
        elseif(BCType=="SpacerB") #Copper Curvature on odd layer
            quiver!(a,b,quiver=(c,d,e),color=:red)
        elseif(BCType=="SpacerCH") #Copper curavture on even layer
            quiver!(a,b,quiver=(c,d,e),color=:purple)
        elseif(BCType=="SpacerBH") #Copper Curvature on odd layer
            quiver!(a,b,quiver=(c,d,e),color=:orange)
            
        else
            error("invalid type of BCType")
        end
    end

end


"Pass in a tuple of x y z coordinates of points and their directions for vectors with u v w, pass three arrays as tuples
optional: rotate::bool"
function VisualizeRing_rotate(ring::Tuple)

    @gif for frame in range(0, stop = 2pi, length = 50)
        print("frame:", Int(round(frame/(2pi/50))), "/50 ")
        VisualizeRing(ring,frame=frame)
    end

end

"GenerateBC returns array of dimensions of Copper Layers for BC
args: 
numberCuLayers::Int, defines number of layers of copper on each side 
BrWidth::Float, defines how wide Brass coils are
Gap::Float, defines how seperated top and bottom Brass coils are"
function GenerateBCDims(numberCuLayers, gap; brWidth = tBrassBC, cuWidth=tCuBC, spacer=tSpacerBC,curvatureInRad=rinC, curvatureOutRad=routC, biasInRad=rinB, biasOutRad=routB)
    gap = gap/2
    brEnd = gap+brWidth

    #initialize four brass rings
    CenterBrass = gap + tBrassBC/2
    
    BrDims = 
    [
        [gap,gap+brWidth,curvatureInRad,curvatureOutRad],
        [gap,gap+brWidth,biasInRad,biasOutRad],
        [-gap,-(gap+brWidth),curvatureInRad,curvatureOutRad],
        [-gap,-(gap+brWidth),biasInRad,biasOutRad],
    ]

    #initialize first top layer of Copper
    CuCDims=[[brEnd+spacer,brEnd+spacer+cuWidth,curvatureInRad,curvatureOutRad]]
    CuBDims=[[brEnd+spacer,brEnd+spacer+cuWidth,biasInRad,biasOutRad]]

    if(numberCuLayers>1)
        for n in 2:numberCuLayers
            #for each nth layer, add a new entry in CuCDims that describes a layer with a higher start and end
            CuCDims=vcat( CuCDims, [ [ brEnd+(n*spacer)+(n-1)cuWidth , brEnd+n*(spacer+cuWidth) , curvatureInRad, curvatureOutRad ] ] )
            CuBDims=vcat( CuBDims, [ [ brEnd+(n*spacer)+(n-1)cuWidth , brEnd+n*(spacer+cuWidth) , biasInRad, biasOutRad ] ] )
        end
    end

    #copy top copper and flip to bottom
    
    CuCDimsBottom=deepcopy(CuCDims)
    CuBDimsBottom=deepcopy(CuBDims)
    for i in 1:numberCuLayers
        for j in 1:2
            CuCDimsBottom[i][j]=CuCDimsBottom[i][j]* (-1)
            CuBDimsBottom[i][j]=CuBDimsBottom[i][j]* (-1)
        end
    end

    return BrDims, CuCDims, CuBDims, CuCDimsBottom, CuBDimsBottom
end

#issues:
#top and bottom don't go opposite directions?

#ISSSUEEESS

#can't see direction of arrows
#Why does visualization of vectors fail if w is filled with less zeroes than 100
#magnitudes are increasing slightly?

#lineRes determines how much points per line, number of vectors in a ring is:
# lineRes * ringWidthRes * ringHeightRes

#For book keeping::::
#=
"Function BuildBC_2D is 2D render of ring given two axes"
function BuildBC_2D(ring::Tuple,BCType="CBE"::String,axes="xz")
    x,y,z,u,v,w=ring

    if(axes=="xz"||axes=="zx")
        a=x
        b=z
        c=u
        d=w
    elseif(axes=="xy"||axes=="yx")
        a=x
        b=y
        c=u
        d=v
    else #zy or yz case
        a=y
        b=z
        c=v
        d=w
    end

    if(ringType=="brass")
        quiver!(a,b,quiver=(c,d),color=:black)
    elseif(ringType=="copperEven")
        quiver!(a,b,quiver=(c,d),color=:hsv) 
    else#odd copper rings
        quiver!(a,b,quiver=(c,d),color=:winter) 
    end
end
=#
