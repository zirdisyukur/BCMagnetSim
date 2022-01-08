using Base: Tuple
#add linear algebra package
import LinearAlgebra
import StatsBase
using StatsBase
using LinearAlgebra
using Plots.PlotMeasures



#=
Need to implement:

Ring spacers and their current htat goes upwards
-done?-figure out whether top and H rigns have differeing directions and differing ring split angles
figure out how to make the currents work, going from current density to vector current's magnitude
are we sure that the convolution coefficents are correct?

=#

#OUTDATED FUNCTIONS, CLEANED UP FORM WORKSPACE BUT KEEPING IT JUST IN CASE

#=
"calculates distance between points"
function Distance(p1::Tuple,p2::Tuple)    
    return sqrt((p2[1]-p1[1])^2 + (p2[2]-p1[2])^2 + (p2[3]-p1[3])^2)
end

"calculates distance between points"
function Distance(p1::Tuple,p2::Tuple{Array{Any,1},Array{Any,1},Array{Any,1}})    
    #return sqrt((p2[1]-p1[1])^2 + (p2[2]-p1[2])^2 + (p2[3]-p1[3])^2)

    toReturn=[]
    for i in 1:length(p2[1])
        iDistance = sqrt((p2[1][i]-p1[1])^2 + (p2[2][i]-p1[2])^2 + (p2[3][i]-p1[3])^2 )
        toReturn = vcat(toReturn, iDistance)
    end
    return toReturn
end
=#

#"calculates magnitude of a vector"
#function Distance(v::Vector)
 #   println("yes")
##    return sqrt( (v[1])^2 + (v[2])^2 + (v[3])^2)
#end


#method for distance for R's magnitude calculation
"calculates magnitude of an array of vectors"
function Distance(v::Array{Array{Float64,1},1})
    toReturn=[]
    for i in 1:length(v[1])
        iDistance = sqrt(v[1][i]^2 + v[2][i]^2 + v[3][i]^2 )
        toReturn = vcat(toReturn, iDistance)
    end
    return toReturn
end

#method for distance for Bxyz_inx and others
"calculates magnitude of an array of vectors"
function Distance(v::Array{Any,1})
    toReturn=[]
    for i in 1:length(v)
        iDistance = sqrt(v[i][1]^2 + v[i][2]^2 + v[i][3]^2 )
        toReturn = vcat(toReturn, iDistance)
    end
    return toReturn
end

#method for distance for calulcatin gmagnitude of B fields grad and curvs
function Distance(x,y,z)
    return sqrt(x^2+y^2+z^2)
end

"transforms arrays of x y z coordinates into arrays of vectors, also returns xyzuvw with standardized legnths"
function GenerateVector(ring::Tuple)

    x,y,z,u,v,w=ring

    #making u,v,w same dimensiosn as x,y,z by copying interest
    numRepeatXY = length(x)/length(u)-1
    numRepeatW = length(z)-length(w) #how many entries need to be added
    tempU = deepcopy(u)
    tempV = deepcopy(v)
    tempW = deepcopy(w)
 
    for i in 1:numRepeatXY
        u=vcat(u,tempU)
        v=vcat(v,tempV)
    end
    
    for i in 1:numRepeatW
        w=vcat(w,w[1])
    end

    vectorsMatrix = []
    for i in 1:length(x)
        vectorsMatrix = vcat(vectorsMatrix,[[ u[i] , v[i], w[i] ]])
    end
 
    return Tuple([vectorsMatrix,x,y,z,u,v,w])
    
end

"Method of GenerateVector used for IUnitDir's vector formatting"
function GenerateVector(ring::Array{Array{Any,1},1})
    x,y,z=ring

    #assuming x y z are same dimensions, convert frmo [xArray,yArray,zArray] into [vecArray1, vecArray2, vecArray3]
    
    vectorsMatrix = []
    for i in 1:length(x)
        vectorsMatrix = vcat(vectorsMatrix,[[ x[i] , y[i], z[i] ]])
    end

    return vectorsMatrix
    
end

"Method of GenerateVector necessary for R's vector formatting"
function GenerateVector(ring::Array{Array{Float64,1},1})
    x,y,z=ring

    #assuming x y z are same dimensions, convert frmo [xArray,yArray,zArray] into [vecArray1, vecArray2, vecArray3]
    
    vectorsMatrix = []
    for i in 1:length(x)
        vectorsMatrix = vcat(vectorsMatrix,[[ x[i] , y[i], z[i] ]])
    end

    return vectorsMatrix
    
end

"Returns the B field vector at a test point: tesPos::Tuple under magnetic field produced by a single ring::Tuple of type BCType::String."
function BiotSavart(ring::Tuple,BCType::String,testPos=(0,0,0)::Tuple)

    #Changes current depending on what type of ring it is
    if(BCType=="BC__") #Brass Curvature
        
        ringWidth = abs(routB-rinB) 
        ringHeight = tBrassBC
        volElementHeight = ringHeight / ringHeightRes
        volElementWidth = ringWidth / ringWidthRes

        I = abs(IC / (tBrassBC * (routC-rinC)) ) * volElementHeight * volElementWidth #units cancel out as everything is in mm

        #println("BC has I of ", I)

    elseif(BCType=="BCH_") #Brass Curvature H
    
        ringWidth = abs(routB-rinB)
        ringHeight = tBrassBC
        volElementHeight = ringHeight / ringHeightRes
        volElementWidth = ringWidth / ringWidthRes

        I = abs(ICH / (tBrassBC * (routC-rinC)) ) * volElementHeight * volElementWidth

        #println("BCH has I of ", I)

    elseif(BCType=="CCE_" || BCType=="CCO_") #Copper Curvature
        
        ringWidth = abs(routC-rinC)
        ringHeight = tCuBC
        volElementHeight = ringHeight / ringHeightRes
        volElementWidth = ringWidth / ringWidthRes

        I = abs(IC / (tCuBC * (routC-rinC)) ) * volElementHeight * volElementWidth
        
        #println("CC has I of ", I)

    elseif(BCType=="CCHE" || BCType=="CCHO") #Copper Curvature H
        
        ringWidth = abs(routC-rinC)
        ringHeight = tCuBC
        volElementHeight = ringHeight / ringHeightRes
        volElementWidth = ringWidth / ringWidthRes

        I = abs(ICH / (tCuBC * (routC-rinC)) ) * volElementHeight * volElementWidth
        
        #println("CCH has I of ", I)

    elseif(BCType=="BBH_" ) #Brass Bias H
    
        ringWidth = abs(routB-rinB)
        ringHeight = tBrassBC
        volElementHeight = ringHeight / ringHeightRes
        volElementWidth = ringWidth / ringWidthRes

        I = abs(IB / (tBrassBC * (routB-rinB)) ) * volElementHeight * volElementWidth

        #println("BB has I of ", I)

    elseif(BCType=="BB__" ) #Brass Bias 
    
        ringWidth = abs(routB-rinB)
        ringHeight = tBrassBC
        volElementHeight = ringHeight / ringHeightRes
        volElementWidth = ringWidth / ringWidthRes

        I = abs(IBH / (tBrassBC * (routB-rinB)) ) * volElementHeight * volElementWidth

        #println("BBH has I of ", I)

    elseif(BCType=="CBE_" || BCType=="CBO_") #Copper Bias
        
        ringWidth = abs(routB-rinB)
        ringHeight = tCuBC
        volElementHeight = ringHeight / ringHeightRes
        volElementWidth = ringWidth / ringWidthRes

        I = abs(IB / (tCuBC * (routB-rinB)) ) * volElementHeight * volElementWidth

        #println("CB has I of ", I)

    elseif(BCType=="CBHE" || BCType=="CBHO") #Copper Bias  H
        
        ringWidth = abs(routB-rinB)
        ringHeight = tCuBC
        volElementHeight = ringHeight / ringHeightRes
        volElementWidth = ringWidth / ringWidthRes

        I = abs(IBH / (tCuBC * (routB-rinB)) ) * volElementHeight * volElementWidth

        #println("CBH has I of ", I)

    elseif(BCType=="ScrewC") #Copper Bias  H
        
        volElementHeight = xtScrew / recRes
        volElementWidth = ytScrew / recRes

        I = abs(IC/ (xtScrew * ytScrew) ) * volElementHeight * volElementWidth


    elseif(BCType=="ScrewB") #Copper Bias  H
        
        volElementHeight = xtScrew / recRes
        volElementWidth = ytScrew / recRes

        I = abs(IB/ (xtScrew * ytScrew) ) * volElementHeight * volElementWidth

    elseif(BCType=="ScrewCH") #Copper Bias  H
        
        volElementHeight = xtScrew / recRes
        volElementWidth = ytScrew / recRes

        I = abs(IC/ (xtScrew * ytScrew) ) * volElementHeight * volElementWidth

    elseif(BCType=="ScrewBH") #Copper Bias  H
        
        volElementHeight = xtScrew / recRes
        volElementWidth = ytScrew / recRes

        I = abs(IB/ (xtScrew * ytScrew) ) * volElementHeight * volElementWidth

    elseif(BCType=="SpacerC") #Spacer Curvature
        
        volElementHeight = xtScrew / recRes
        volElementWidth = ytScrew / recRes

        I = abs(IC / (routC-rinC)^2 ) * volElementHeight * volElementWidth

    elseif(BCType=="SpacerB") #Spacer Bias
        
        volElementHeight = xtScrew / recRes
        volElementWidth = ytScrew / recRes

        I = abs(IB / (routB-rinB)^2 ) * volElementHeight * volElementWidth

    elseif(BCType=="SpacerCH") #Spacer Curvature H
        
        volElementHeight = xtScrew / recRes
        volElementWidth = ytScrew / recRes

        I = abs(ICH / (routC-rinC)^2 ) * volElementHeight * volElementWidth

    elseif(BCType=="SpacerBH") #Spacer Bias H
        
        volElementHeight = xtScrew / recRes
        volElementWidth = ytScrew / recRes

        I = abs(IBH / (routB-rinB)^2 ) * volElementHeight * volElementWidth



    else
        print(BCType)
        error("invalid type of BCType")
    end

    #stadnardizes lengths of arrays I believe
    vectorsArray,x,y,z,u,v,w=GenerateVector(ring);

    #Position of current element with respect to (0,0,0)
    #pos = (x,y,z) 
 
    #unit direction vector of current element
    IUnitDir = [u,v,w]

    #position vector of current element with respect to the test position
    R = -1 * [x.-testPos[1],y.-testPos[2],z.-testPos[3]]
   
    #magnitude of position vector (distance of current element to test position)
    r = Distance(R) #distances from current element to (0,0,0) , calculates magnitudes of array of vectors R

    #computing dB's scalar value
    dB = (μ0 / 4pi) * (I / r.^2)

    #formatting of vectors to be cross productable
    IUnitDir = GenerateVector(IUnitDir)
    R = GenerateVector(R)
    dB_vec = cross.(IUnitDir,R)

    B = dB .* dB_vec
    #display(quiver!(pos,quiver=dB*cross(IUnitDir,dL))) quiver won't work with only showing one vector
    return transpose(sum(B)) #dB * cross(IUnitDir,R)
end

"Not Needed, just use BiotSavartObj. Returns the B field vector at a test point: tesPos::Tuple under magnetic field produced by an entire BC magnet (collection of rings) of type BCType::String."
function BiotSavartRec(screws::Array,testPos=(0,0,0)::Tuple)
    toReturn=[]
    for i in 1:length(screws)
        #print(i, " ")
        toReturn = vcat(toReturn, [BiotSavart(screws[i][1:6],screws[i][7],testPos)])
    end
    return sum(toReturn)
end

"Returns the B field vector at a test point tesPos::Tuple
 under magnetic field produced by an Object defined by an array(tuple(x,y,x,u,v,w,type))." #this redundancy in obj definition needs to be fixed?
function BiotSavartObj(Obj::Array,testPos=(0,0,0)::Tuple)
    toReturn=[]
    for i in 1:length(Obj)
        #print(i, " ")
        toReturn = vcat(toReturn, [BiotSavart(Obj[i][1:6],Obj[i][7],testPos)]) #For every object (index) in in Obj, calculate the B field with tesPos
    end
    return sum(toReturn)
end

"Returns the B field vector at multiple test points varying in x, y, and z directions under B field produced by entire BC magnet BC::Array,
type::String specifies whether the magnetic field is to calculated in all three directions or just one (not yet implemented)."
function GenerateBBC(type="b"::String;plotWidth=100::Int,step=10)
    
    #Generates BC Components, inclusive of BC coils, spacrs, and screws
    BC, Spacers, Screws, allObj = BCgroup();


    if(plotWidth % step != 0) error("range must be divisible by steps") end

    if(type=="b") #calculating all directions of magnetic field

        x = range(-plotWidth/2,stop=plotWidth/2,step=step)
        y = range(-plotWidth/2,stop=plotWidth/2,step=step)
        z = range(-plotWidth/2,stop=plotWidth/2,step=step)

        Bxyz_inx = []
        Bxyz_iny = []
        Bxyz_inz = []

        println("Calculating BBC as x,y,z changes. printing layers:")
        for i in 1:length(x)
            println(x[i], " ")
            @time Bxyz_inx = vcat(Bxyz_inx,[BiotSavartObj(allObj,(x[i],0,0))]) #Calculating B vector of  for a range of x positions
            @time Bxyz_iny = vcat(Bxyz_iny,[BiotSavartObj(allObj,(0,y[i],0))]) #Calculating B vector for a range of y positions
            @time Bxyz_inz = vcat(Bxyz_inz,[BiotSavartObj(allObj,(0,0,z[i]))]) #Calculating B vector for a range of z positions
        end

    end

    #calculates the magnitude of B vector for different variable directions
    Bmag_inx = Distance(Bxyz_inx)
    Bmag_iny = Distance(Bxyz_iny)
    Bmag_inz = Distance(Bxyz_inz)


    return x, y, z, Bxyz_inx, Bxyz_iny, Bxyz_inz, Bmag_inx, Bmag_iny, Bmag_inz
end

"Method of GenerateBBC that has a BC passed in as an argument. Returns the B field vector at multiple test points varying in x, y, and z directions under B field produced by entire BC magnet BC::Array,
type::String specifies whether the magnetic field is to calculated in all three directions or just one (not yet implemented)."
function GenerateBBC(BCgroup::Array{Any,1};type="b"::String,plotWidth=100::Int,step=10)
    println("this")
    #Generates BC Components, inclusive of BC coils, spacrs, and screws
    BC, Spacers, Screws, allObj = BCgroup


    if(plotWidth % step != 0) error("range must be divisible by steps") end

    if(type=="b") #calculating all directions of magnetic field

        x = range(-plotWidth/2,stop=plotWidth/2,step=step)
        y = range(-plotWidth/2,stop=plotWidth/2,step=step)
        z = range(-plotWidth/2,stop=plotWidth/2,step=step)

        Bxyz_inx = []
        Bxyz_iny = []
        Bxyz_inz = []

        println("Calculating BBC as x,y,z changes. printing layers:")
        for i in 1:length(x)
            println(x[i], " ")
            @time Bxyz_inx = vcat(Bxyz_inx,[BiotSavartObj(allObj,(x[i],0,0))]) #Calculating B vector of  for a range of x positions
            @time Bxyz_iny = vcat(Bxyz_iny,[BiotSavartObj(allObj,(0,y[i],0))]) #Calculating B vector for a range of y positions
            @time Bxyz_inz = vcat(Bxyz_inz,[BiotSavartObj(allObj,(0,0,z[i]))]) #Calculating B vector for a range of z positions
        end

    end

    #calculates the magnitude of B vector for different variable directions
    Bmag_inx = Distance(Bxyz_inx)
    Bmag_iny = Distance(Bxyz_iny)
    Bmag_inz = Distance(Bxyz_inz)


    return x, y, z, Bxyz_inx, Bxyz_iny, Bxyz_inz, Bmag_inx, Bmag_iny, Bmag_inz
end


"Plotting the B-Field of the obj"
function PlotBBC(BBC::Tuple, Stats::Tuple; disableMag=false)
    sigfig=4
    Bx, By, Bz, gradBCx,  gradBCy, gradBCz, curvBCx, curvBCy, curvBCz = Stats

    #conversion of units into G, G/cm, G/cm^2 from T and mm. Also summarizing components of grad and curv/
    B = Distance(Bx,By,Bz) * 10^4 
    Bx = Bx * 10^4 
    By = By * 10^4 
    Bz = Bz * 10^4 
    BgradX = Distance(gradBCx[1],gradBCx[2],gradBCx[3]) * 10^4 * 10
    BgradY = Distance(gradBCy[1],gradBCy[2],gradBCy[3]) * 10^4 * 10
    BgradZ = Distance(gradBCz[1],gradBCz[2],gradBCz[3]) * 10^4 * 10
    BcurvX = Distance(curvBCx[1],curvBCx[2],curvBCx[3]) * 10^4 * 10^2
    BcurvY = Distance(curvBCx[1],curvBCx[2],curvBCx[3]) * 10^4 * 10^2
    BcurvZ = Distance(curvBCx[1],curvBCx[2],curvBCx[3]) * 10^4 * 10^2

    xplotAnnotation = string("B = ",floor.(B,sigdigits=sigfig) ," G\nBx = ", floor.(Bx,sigdigits=sigfig) ," G\n∂B/∂x = ", floor.(BgradX,sigdigits=sigfig) , " G/cm\n∂²B/∂x² = ", floor.(BcurvX,sigdigits=sigfig), " G/cm²" )
    yplotAnnotation = string("B = ",floor.(B,sigdigits=sigfig) ," G\nBy = ", floor.(By,sigdigits=sigfig) ," G\n∂B/∂y = ", floor.(BgradY,sigdigits=sigfig) , " G/cm\n∂²B/∂y² = ", floor.(BcurvY,sigdigits=sigfig), " G/cm²" )
    zplotAnnotation = string("B = ",floor.(B,sigdigits=sigfig) ," G\nBz = ", floor.(Bz,sigdigits=sigfig) ," G\n∂B/∂z = ", floor.(BgradZ,sigdigits=sigfig) , " G/cm\n∂²B/∂z² = ", floor.(BcurvZ,sigdigits=sigfig), " G/cm²" )

    if(!disableMag)
        #pointNum = 1:length(Bxyz_inx)
        x, y, z, Bxyz_inx, Bxyz_iny, Bxyz_inz, Bmag_inx, Bmag_iny, Bmag_inz = BBC 

        #converting units to G and mm
        #x *= 10
        #y *= 10
        #z *= 10
        Bxyz_inx *= 10^4
        Bxyz_iny *= 10^4
        Bxyz_inz *= 10^4
        Bmag_inx *= 10^4
        Bmag_iny *= 10^4
        Bmag_inz *= 10^4

        inxPlot = plot(x, [ hcat(permutedims(reshape(collect(Iterators.flatten(Bxyz_inx)),3,length(Bxyz_inx))),collect(Iterators.flatten(Bmag_inx))) ] , title="B as x changes",
            label=["Bx" "By" "Bz" "|B|"],xlabel="x [mm]",ylabel="B-field strength [G]")
            annotate!(0,1.5,text(xplotAnnotation,:center,8))

        inyPlot = plot(y,[ hcat(permutedims(reshape(collect(Iterators.flatten(Bxyz_iny)),3,length(Bxyz_iny))),collect(Iterators.flatten(Bmag_iny))) ],title="B as y changes",
            label=["Bx" "By" "Bz" "|B|"],xlabel="y [mm]", ylabel="B-field strength [G]")
            annotate!(0,1.5,text(yplotAnnotation,:center,8))

        inzPlot = plot(z,[ hcat(permutedims(reshape(collect(Iterators.flatten(Bxyz_inz)),3,length(Bxyz_inz))),collect(Iterators.flatten(Bmag_inz))) ],title="B as z changes",
            label=["Bx" "By" "Bz" "|B|"],xlabel="z [mm]", ylabel = "B-field strength [G]")
            annotate!(0,1.5,text(zplotAnnotation,:center,8))

        l = @layout [a; b ;c]

        plot(inxPlot, inyPlot, inzPlot, layout = l, size=(800,1000),margin=5mm, linewidth=3)
        time = Dates.format(now(),"yyy-mm-dddTHH-MM-SS")    
        filename = "/Users/zirdisyukur/Julia/Research/WithPlots/figures/PlotBBC/PlotBBC_"*time*".png"
        println("saved to " * filename)
        savefig(filename)

    else #if disable magnitude is enabled
        x, y, z, Bxyz_inx, Bxyz_iny, Bxyz_inz, Bmag_inx, Bmag_iny, Bmag_inz = BBC 
        inxPlot = plot(x, [ permutedims(reshape(collect(Iterators.flatten(BBC[4])),3,length(BBC[4]))) ] , title="B as x changes",
        label=["Bx" "By" "Bz" "|B|"],xlabel="x [mm]",ylabel="B [T]")
        inyPlot = plot(y,[ permutedims(reshape(collect(Iterators.flatten(BBC[5])),3,length(BBC[5]))) ],title="B as y changes",
            label=["Bx" "By" "Bz"],xlabel="y [mm]", ylabel="B [T]")
        inzPlot = plot(z,[ permutedims(reshape(collect(Iterators.flatten(BBC[6])),3,length(BBC[6]))) ],title="B as z changes",
            label=["Bx" "By" "Bz" "|B|"],xlabel="z [mm]", ylabel = "B [T]")
        l = @layout [a; b ;c]

        plot(inxPlot, inyPlot, inzPlot, layout = l, size=(800,1000),margin=5mm,linewidth=3)

        time = Dates.format(now(),"yyy-mm-dddTHH-MM-SS")    
        filename = "/Users/zirdisyukur/Julia/Research/WithPlots/figures/PlotBBC/PlotBBC_"*time*".png"
        println("saved to " * filename)
        savefig(filename)
    end
    
    return  
end

"Plot BBC function that generates the BBC and then plots, rather than being passed the BBC that was generated with GenerateBBC()"
function PlotBBC(;disableMag=false,plotWidth=200::Int,step=10)

    plotWidth=plotWidth
    step=step

    if(!disableMag)
        BBC = GenerateBBC(plotWidth=plotWidth,step=step);
        x, y, z, Bxyz_inx, Bxyz_iny, Bxyz_inz, Bmag_inx, Bmag_iny, Bmag_inz = BBC

        inxPlot = plot(x, [ hcat(permutedims(reshape(collect(Iterators.flatten(BBC[4])),3,length(BBC[4]))),collect(Iterators.flatten(BBC[7]))) ] , title="B as x changes",
            label=["Bx" "By" "Bz" "|B|"],xlabel="x []",ylabel="Bx []")
        inyPlot = plot(y,[ hcat(permutedims(reshape(collect(Iterators.flatten(BBC[5])),3,length(BBC[5]))),collect(Iterators.flatten(BBC[8]))) ],title="B as y changes",
            label=["Bx" "By" "Bz" "|B|"],xlabel="y []", ylabel="By []")
        inzPlot = plot(z,[ hcat(permutedims(reshape(collect(Iterators.flatten(BBC[6])),3,length(BBC[6]))),collect(Iterators.flatten(BBC[9]))) ],title="B as z changes",
            label=["Bx" "By" "Bz" "|B|"],xlabel="z []", ylabel = "Bz []")
        l = @layout [a; b ;c]

        plot(inxPlot, inyPlot, inzPlot, layout = l, size=(600,800),margin=5mm)

        time = Dates.format(now(),"yyy-mm-dddTHH-MM-SS")    
        filename = "/Users/zirdisyukur/Julia/Research/WithPlots/figures/PlotBBC/PlotBBC_"*time*".png"
        println("saved to " * filename)
        savefig(filename)
        
    else #disabled Magntidue
        BBC = GenerateBBC(plotWidth=plotWidth,step=step);
        x, y, z, Bxyz_inx, Bxyz_iny, Bxyz_inz, Bmag_inx, Bmag_iny, Bmag_inz = BBC

        inxPlot = plot(x, [ permutedims(reshape(collect(Iterators.flatten(BBC[4])),3,length(BBC[4]))) ] , title="B as x changes",
        label=["Bx" "By" "Bz" "|B|"],xlabel="x []",ylabel="B []")
        inyPlot = plot(y,[ permutedims(reshape(collect(Iterators.flatten(BBC[5])),3,length(BBC[5]))) ],title="B as y changes",
            label=["Bx" "By" "Bz"],xlabel="y []", ylabel="B []")
        inzPlot = plot(z,[ permutedims(reshape(collect(Iterators.flatten(BBC[6])),3,length(BBC[6]))) ],title="B as z changes",
            label=["Bx" "By" "Bz" "|B|"],xlabel="z []", ylabel = "B []")
        l = @layout [a; b ;c]

        plot(inxPlot, inyPlot, inzPlot, layout = l, size=(600,800),margin=5mm)

        time = Dates.format(now(),"yyy-mm-dddTHH-MM-SS")    
        filename = "/Users/zirdisyukur/Julia/Research/WithPlots/figures/PlotBBC/PlotBBC_"*time*".png"
        println("saved to " * filename)
        savefig(filename)
    end
    
    return  
end

"Computes gradients and curvature of BC magnetic fields at (0,0,0) using savitsky-golay derivative approximations"
function BCStats()

    #Generates BC Components, inclusive of BC coils, spacrs, and screws
    BC, Spacers, Screws, allObj = BCgroup();

    #cacluating B field of entire object
    print("B-field ...")
    @time BBC = BiotSavartObj(allObj)

    #small change used to estimate gradient and curvatures
    dstep=0.1

    #partials for gradiants and curvature, gives x y and z components    
    print("gradBCx ...")
    @time gradBCx = ( (1/12)*BiotSavartObj(allObj,(-2dstep,0,0)) + (-2/3)*BiotSavartObj(allObj,(-dstep,0,0))
                 + (2/3)*BiotSavartObj(allObj,(dstep,0,0)) + (-1/12)*BiotSavartObj(allObj,(2dstep,0,0))   ) / dstep
    print("curvBCx ...")
    @time curvBCx = ( (-1/12)*BiotSavartObj(allObj,(-2dstep,0,0)) + (4/3)*BiotSavartObj(allObj,(-dstep,0,0))
                 + (-5/2)*BiotSavartObj(allObj,(0,0,0)) + (4/3)*BiotSavartObj(allObj,(2dstep,0,0)) + (1/12)*BiotSavartObj(allObj,(2dstep,0,0))  ) / dstep


    print("gradBCy ...")
    @time gradBCy = ( (1/12)*BiotSavartObj(allObj,(0,-2dstep,0)) + (-2/3)*BiotSavartObj(allObj,(0,-dstep,0))
                + (2/3)*BiotSavartObj(allObj,(0,dstep,0)) + (-1/12)*BiotSavartObj(allObj,(0,2dstep,0))   ) / dstep
    print("curvBCy ...")
    @time curvBCy = ( (-1/12)*BiotSavartObj(allObj,(0,-2dstep,0)) + (4/3)*BiotSavartObj(allObj,(0,-dstep,0))
                + (-5/2)*BiotSavartObj(allObj,(0,0,0)) + (4/3)*BiotSavartObj(allObj,(0,2dstep,0)) + (1/12)*BiotSavartObj(allObj,(0,2dstep,0))  ) / dstep


    print("gradBCz ...")
    @time gradBCz = ( (1/12)*BiotSavartObj(allObj,(0,0,-2dstep)) + (-2/3)*BiotSavartObj(allObj,(0,0,-dstep))
                 + (2/3)*BiotSavartObj(allObj,(0,0,dstep)) + (-1/12)*BiotSavartObj(allObj,(0,0,2dstep))   ) / dstep
    println("curvBCz ...")
    @time curvBCz = ( (-1/12)*BiotSavartObj(allObj,(0,0,-2dstep)) + (4/3)*BiotSavartObj(allObj,(0,0,-dstep))
                 + (-5/2)*BiotSavartObj(allObj,(0,0,dstep)) + (4/3)*BiotSavartObj(allObj,(0,0,2dstep)) + (1/12)*BiotSavartObj(allObj,(2dstep,0,0))  ) / dstep

                 println()

    #specifies reporting precision for stats
    sigfig = 5;

    println("B [T]: ", floor.([BBC[1], BBC[2], BBC[3]],sigdigits=sigfig))
    println()

    println("∂B/∂z [T/mm]:    ", floor.(gradBCz,sigdigits=sigfig))
    println("∂²B/∂z² [T/mm²]: ",floor.(curvBCz,sigdigits=sigfig))
    println("∂B/∂x [T/mm]:    ",floor.(gradBCx,sigdigits=sigfig))
    println("∂²B/∂x² [T/mm²]: ",floor.(curvBCx,sigdigits=sigfig))
    println()

    println("∂B/∂z [G/cm]:    ", floor.(gradBCz * 10^4 * 10,sigdigits=sigfig))
    println("∂²B/∂z² [G/cm²]: ",floor.(curvBCz * 10^4 * 10^2,sigdigits=sigfig))
    println("∂B/∂x [G/cm]:    ",floor.(gradBCx * 10^4 * 10,sigdigits=sigfig))
    println("∂²B/∂x² [G/cm²]: ",floor.(curvBCx * 10^4 * 10^2,sigdigits=sigfig))
    println()

    println("∂B/∂z [μT/m]:    ", floor.(gradBCz * 10^6 * 10^3,sigdigits=sigfig))
    println("∂²B/∂z² [μT/m²]: ",floor.(curvBCz * 10^6 * 10^3,sigdigits=sigfig))
    println()

    return BBC[1], BBC[2], BBC[3], gradBCx,  gradBCy, gradBCz, curvBCx, curvBCy, curvBCz

end

"composites BC parts: BC coils, spacers, and screws, into one array. Not used in normal computation as different parts of BC are needed for computation."
function BCgroup()
    #Generates BC Components, inclusive of BC coils, spacrs, and screws
    print("generating BC...")
    BC=GenerateBC();
    Spacers=GenerateSpacers();
    Screws=GenerateScrews();

    #combines BC components into one array
    allObj = cat(BC,Spacers,Screws,dims=1)
    println("done")

    return (BC), (Spacers), (Screws), (allObj)
end

