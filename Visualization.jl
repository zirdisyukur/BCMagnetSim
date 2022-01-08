using Plots: axes
using Base: replace_with_centered_mark, DUMP_DEFAULT_MAXDEPTH
#This visualization test uses plots as opposed to Makie
import Plots
using Plots
import Dates
using Dates
gr()

begin #functions and methods for making gifs
    
    "VisualizeBC version where you can rotate coils optional: rotate::bool"
    function VisualizeBC_rotate(BC::Array;disableBrass=false,disableCopper=false,disableCurvature=false,disableBias=false,disableTop=false,
        disableBot=false,onlyLayer=-1)

        numFrames = 50

        println("Total frames: ", numFrames)
        anim = @animate for frame in range(0, stop = 2pi, length = numFrames)
            print(Int(round(frame/(2pi/50))), " ")
            VisualizeBC(BC,frame)
        end

        time = Dates.format(now(),"yyy-mm-dddTHH-MM-SS")    
        filename = "/Users/zirdisyukur/Julia/Research/WithPlots/figures/VisualizeBC_build_"*time*".gif"

        #gif(anim, filename, fps=50)
        return anim
    end

    "VisualizeBC building up animation 3D version"
    function VisualizeBC_build(BC::Array)

        numRingsBC = length(BC) #108
        numLayers = Int(length(BC)/2) #54
        numFrames = numLayers + numRingsBC #162

        println("Total frames: ", numFrames)
        anim = @animate for frame in range(1, stop = numFrames, step = 1)

            print(frame, " ")
            if(frame > numLayers) #after half way
                specifiedRings = 1:(frame-numLayers)
            else
                specifiedRings = [2*frame-1,2*frame]
            end

            VisualizeBC(BC,pi/2,specifiedRings=specifiedRings)

        end

        time = Dates.format(now(),"yyy-mm-dddTHH-MM-SS")    
        filename = "/Users/zirdisyukur/Julia/Research/WithPlots/figures/gifs/VisualizeBC_build_"*time*".gif"

        #gif(anim, filename, fps=400) 
        return anim
    end

    "VisualizeBC building up animation 2D version"
    function VisualizeBC_build(BC::Array,axes::String;disableBrass=false,disableCopper=false,disableCurvature=false,disableBias=false,
        disableTop=false,disableBot=false,)

        numRingsBC = length(BC) #108
        numLayers = Int(length(BC)/2) #54
        numFrames = numLayers + numRingsBC #162

        println("Total frames: ", numFrames)
        anim = @animate for frame in range(1, stop = numFrames, step = 1)

            print(frame, " ")
            if(frame > numLayers) #after half way
                specifiedRings = 1:(frame-numLayers)
            else
                specifiedRings = [2*frame-1,2*frame]
            end

            VisualizeBC(BC,axes,specifiedRings=specifiedRings,true,
            disableBrass=false,disableCopper=false,disableCurvature=false,disableBias=false,
            disableTop=false,disableBot=false)

        end

        time = Dates.format(now(),"yyy-mm-dddTHH-MM-SS")    
        filename = "/Users/zirdisyukur/Julia/Research/WithPlots/figures/gifs/VisualizeBC_build_"*time*".gif"

        gif(anim, filename, fps=400)

        return anim
    end

    #Work in Progress
    "Colection of animations in one GIF"
    function VisualizeAnimation(BC::Array,axes::String)
        l = @layout([a b c])
        p = plot( plot([sin, cos], 1, ylims = (-1, 1), leg = false),
                  scatter([atan, cos], 1, ylims = (-1, 1.5), leg = false),
                  plot(log, 1, ylims = (0, 2), leg = false), layout = l, xlims = (1, 2π)
            )
        anim = Animation()
        for x = range(1, stop = 2π, length = 20)
            plot(push!(p, x, Float64[sin(x), cos(x), atan(x), cos(x), log(x)]))
            frame(anim)
        end
        gif(anim,"gif.gif",fps=10)
    end

end

begin #Methods for VisualizeBC
    
    #Pass in array BC from Generate BC, defaults to full view, can have certain disabled thigns like copper, brass, bias, and curvature, can also pass in array of which layers you want
    "VisualizeBC optional: rotate::bool"
    function VisualizeBC(BC::Array;disableBrass=false,disableCopper=false,disableCurvature=false,disableBias=false,
        disableTop=false,disableBot=false,angle=pi/2,fullsize=true, specifiedRings=[]::Array)

        #number of rings in BC,
        numRings = length(BC)
        numCuLayers = (numRings - 4) / 2 #number of Copper layers on each side of BC

        #height of BC
        last(BC[1][3]) #BC first layer (bottom), z coordinate, and last entry which is lowest
        last(BC[lastindex(BC)][3]) #BC last layer (top), z coordiante, and last entry which is highest
        height = last(BC[lastindex(BC)][3]) - last(BC[1][3])

        #initializes a camerra and axis settings
        cameraX=40+10*cos(angle)
        cameraY=45-20*cos(angle)
        xlims=(-50,50)
        ylims=(-50,50)

        #initializes plot with varying dimensiosn depending on job
        if(fullsize)
            zlims=(-height/2,height/2)
            display(quiver(0,0,0,quiver=(0,0,0),xlims=xlims,ylims=ylims,zlims=zlims,size=(600,600,10))) 
        else
            display(quiver(0,0,0,quiver=(0,0,0),xlims=xlims,ylims=ylims,size=(600,600,10))) 
        end

        #defines plot camera
        temporary=[0,0,0]
        quiver!(temporary,temporary,temporary,quiver=(temporary,temporary,temporary),camera=(cameraX,cameraY))

        #Displaying rings on plot
        if (specifiedRings == []) #do full view
            #print("Total rings: ", numRings ," \nPlotting ring number: \n")
            for layer in 1:numRings
                #print(layer, " ")
                if(disableBrass && BC[layer][7][1]=='B') continue end
                if(disableCopper && BC[layer][7][1]=='C') continue end
                if(disableCurvature && BC[layer][7][2]=='C') continue end
                if(disableBias && BC[layer][7][2]=='B') continue end
                if(disableTop && BC[layer][7][3]!='H') continue end
                if(disableBot && BC[layer][7][3]=='H') continue end
                BuildBC( BC[layer][1:6] ,BC[layer][7]) #passes in x,y,z,u,v,w for quiver and then BCType for color
            end
        else #do only specifiedRigns view
            numSpecifiedRings = length(specifiedRings)
            #print("Total rings: ", numSpecifiedRings ," \nPlotting ring number: \n")
            for layer in 1:numSpecifiedRings
                #print(specifiedRings[layer], " ") 
                if(disableBrass && BC[layer][7][1]=='B') continue end
                if(disableCopper && BC[layer][7][1]=='C') continue end
                if(disableCurvature && BC[layer][7][2]=='C') continue end
                if(disableBias && BC[layer][7][2]=='B') continue end
                if(disableTop && BC[layer][7][3]!='H') continue end
                if(disableBot && BC[layer][7][3]=='H') continue end
                BuildBC( BC[specifiedRings[layer]][1:6] ,BC[specifiedRings[layer]][7]) #passes in x,y,z,u,v,w for quiver and then BCType for color
            end
        end

        #ensures that whole plot is displayyed after function
        display(quiver!(0,0,0,quiver=(0,0,0),camera = (cameraX,cameraY))) 

        #saving plot to figure
        time = Dates.format(now(),"yyy-mm-dddTHH-MM-SS")    
        filename = "/Users/zirdisyukur/Julia/Research/WithPlots/figures/VisualizeBC_build_"*time*".png"
        println("\nsaved to " * filename)
        savefig(filename)
        
    end

    #Version of above meant for callling in loops like gifs, without saving each frame and printing
    "VisualizeBC for gifs: rotate::bool"
    function VisualizeBC(BC::Array,frame::Number;disableBrass=false,disableCopper=false,disableCurvature=false,disableBias=false,
        disableTop=false,disableBot=false,fullsize=true, specifiedRings=[]::Array)

        #number of rings in BC,
        numRings = length(BC)
        numCuLayers = (numRings - 4) / 2 #number of Copper layers on each side of BC

        #height of BC
        last(BC[1][3]) #BC first layer (bottom), z coordinate, and last entry which is lowest
        last(BC[lastindex(BC)][3]) #BC last layer (top), z coordiante, and last entry which is highest
        height = last(BC[lastindex(BC)][3]) - last(BC[1][3])

        #initializes a camerra and axis settings
        cameraX=40+10*cos(frame)
        cameraY=45-20*cos(frame)
        xlims=(-50,50)
        ylims=(-50,50)

        #initializes plot with varying dimensiosn depending on job
        if(fullsize)
            zlims=(-height/2,height/2)
            quiver(0,0,0,quiver=(0,0,0),xlims=xlims,ylims=ylims,zlims=zlims,size=(600,600,10))
        else
            quiver(0,0,0,quiver=(0,0,0),xlims=xlims,ylims=ylims,size=(600,600,10))
        end

        #defines plot camera
        temporary=[0,0,0]
        quiver!(temporary,temporary,temporary,quiver=(temporary,temporary,temporary),camera=(cameraX,cameraY))

        #Displaying rings on plot
        if (specifiedRings == []) #do full view
            #print("Total rings: ", numRings ," \nPlotting ring number: \n")
            for layer in 1:numRings
                #print(layer, " ")
                if(disableBrass && BC[layer][7][1]=='B') continue end
                if(disableCopper && BC[layer][7][1]=='C') continue end
                if(disableCurvature && BC[layer][7][2]=='C') continue end
                if(disableBias && BC[layer][7][2]=='B') continue end
                if(disableTop && BC[layer][7][3]!='H') continue end
                if(disableBot && BC[layer][7][3]=='H') continue end
                BuildBC( BC[layer][1:6] ,BC[layer][7]) #passes in x,y,z,u,v,w for quiver and then BCType for color
            end
        else #do only specifiedRigns view
            numSpecifiedRings = length(specifiedRings)
            #print("Total rings: ", numSpecifiedRings ," \nPlotting ring number: \n")
            for layer in 1:numSpecifiedRings
                #print(specifiedRings[layer], " ") 
                if(disableBrass && BC[layer][7][1]=='B') continue end
                if(disableCopper && BC[layer][7][1]=='C') continue end
                if(disableCurvature && BC[layer][7][2]=='C') continue end
                if(disableBias && BC[layer][7][2]=='B') continue end
                if(disableTop && BC[layer][7][3]!='H') continue end
                if(disableBot && BC[layer][7][3]=='H') continue end
                BuildBC( BC[specifiedRings[layer]][1:6] ,BC[specifiedRings[layer]][7]) #passes in x,y,z,u,v,w for quiver and then BCType for color
            end
        end

        #ensures that whole plot is displayyed after function
        #display(quiver!(0,0,0,quiver=(0,0,0),camera = (cameraX,cameraY))) 

        #saving plot to figure
        #time = Dates.format(now(),"yyy-mm-dddTHH-MM-SS")    
        #filename = "/Users/zirdisyukur/Julia/Research/WithPlots/figures/VisualizeBC_build_"*time*".png"
        #println("\nsaved to " * filename)
        #savefig(filename)
        return(quiver!(0,0,0,quiver=(0,0,0),camera = (cameraX,cameraY)))
    end

    #Pass in array BC from Generate BC, defaults to full view, can have certain disabled thigns like copper, brass, bias, and curvature, can also pass in array of which layers you want
    "2D visualize"
    function VisualizeBC(BC::Array,axes::String;disableBrass=false,disableCopper=false,disableCurvature=false,disableBias=false,
        disableTop=false,disableBot=false,fullsize=true, specifiedRings=[]::Array)

        #number of rings in BC,
        numRings = length(BC)
        numCuLayers = (numRings - 4) / 2 #number of Copper layers on each side of BC

        #height of BC
        last(BC[1][3]) #BC first layer (bottom), z coordinate, and last entry which is lowest
        last(BC[lastindex(BC)][3]) #BC last layer (top), z coordiante, and last entry which is highest
        height = last(BC[lastindex(BC)][3]) - last(BC[1][3])
        
        if(axes=="xy")
            plotDimensions = (600,600)
            display(quiver(0,0,quiver=(0,0),size=plotDimensions))
        else
            plotDimensions = (400,800)
            display(quiver(0,0,quiver=(0,0),size=plotDimensions,ylims=(-height/2,height/2)))
        end

        #initializes a plot
        #display(quiver(0,0,quiver=(0,0),size=plotDimensions,ylims=(-height/2,height/2)))

        #number of rings in BC,
        numRings = length(BC)
        numCuLayers = (numRings - 4) / 2 #number of Copper layers on each side of BC

        #height of BC
        last(BC[1][3]) #BC first layer (bottom), z coordinate, and last entry which is lowest
        last(BC[lastindex(BC)][3]) #BC last layer (top), z coordiante, and last entry which is highest
        height = last(BC[lastindex(BC)][3]) - last(BC[1][3])

        #initializes a camerra and axis settings
        #cameraX=40+10*cos(frame)
        #cameraY=45-20*cos(frame)
        xlims=(-80,80)
        ylims=(-80,80)

        #initializes plot with varying dimensiosn depending on job
        #=
        if(fullsize)
            zlims=(-height/2,height/2)
            display(quiver(0,0,0,quiver=(0,0,0),xlims=xlims,ylims=ylims,zlims=zlims,size=(600,600,10))) 
        else
            display(quiver(0,0,0,quiver=(0,0,0),xlims=xlims,ylims=ylims,size=(600,600,10))) 
        end=#

        #defines plot camera
        #temporary=[0,0,0]
        #quiver!(temporary,temporary,temporary,quiver=(temporary,temporary,temporary),camera=(cameraX,cameraY))

        #Displaying rings on plot
        if (specifiedRings == []) #do full view
            #print("Total rings: ", numRings ," \nPlotting ring number: \n")
            for layer in 1:numRings
                #print(layer, " ")
                if(disableBrass && BC[layer][7][1]=='B') continue end
                if(disableCopper && BC[layer][7][1]=='C') continue end
                if(disableCurvature && BC[layer][7][2]=='C') continue end
                if(disableBias && BC[layer][7][2]=='B') continue end
                if(disableTop && BC[layer][7][3]!='H') continue end
                if(disableBot && BC[layer][7][3]=='H') continue end
                BuildBC( BC[layer][1:6] ,BC[layer][7],axes) #passes in x,y,z,u,v,w for quiver and then BCType for color
            end
        else #do only specifiedRigns view
            numSpecifiedRings = length(specifiedRings)
            #print("Total rings: ", numSpecifiedRings ," \nPlotting ring number: \n")
            for layer in 1:numSpecifiedRings
                #print(specifiedRings[layer], " ") 
                if(disableBrass && BC[layer][7][1]=='B') continue end
                if(disableCopper && BC[layer][7][1]=='C') continue end
                if(disableCurvature && BC[layer][7][2]=='C') continue end
                if(disableBias && BC[layer][7][2]=='B') continue end
                if(disableTop && BC[layer][7][3]!='H') continue end
                if(disableBot && BC[layer][7][3]=='H') continue end
                BuildBC( BC[specifiedRings[layer]][1:6] ,BC[specifiedRings[layer]][7], axes) #passes in x,y,z,u,v,w for quiver and then BCType for color
            end
        end

        #ensures that whole plot is displayyed after function
        display(quiver!(0,0,quiver=(0,0),minorticks=25,xlims=xlims,ylims=ylims))

        #saving plot to figure
        time = Dates.format(now(),"yyy-mm-dddTHH-MM-SS")    
        filename = "/Users/zirdisyukur/Julia/Research/WithPlots/figures/VisualizeBC_build_"*time*".png"
        println("\nsaved to " * filename)
        savefig(filename)
        
    end

    #same as above for GIFS
    "2D visualize for GIFS"
    function VisualizeBC(BC::Array,axes::String,GIFS::Bool;disableBrass=false,disableCopper=false,disableCurvature=false,disableBias=false,
        disableTop=false,disableBot=false,fullsize=true, specifiedRings=[]::Array)

        #number of rings in BC,
        numRings = length(BC)
        numCuLayers = (numRings - 4) / 2 #number of Copper layers on each side of BC

        #height of BC
        last(BC[1][3]) #BC first layer (bottom), z coordinate, and last entry which is lowest
        last(BC[lastindex(BC)][3]) #BC last layer (top), z coordiante, and last entry which is highest
        height = last(BC[lastindex(BC)][3]) - last(BC[1][3])


        if(axes=="xy")
            plotDimensions = (600,600)
            display(quiver(0,0,quiver=(0,0),size=plotDimensions))
        else
            plotDimensions = (400,600)
            display(quiver(0,0,quiver=(0,0),size=plotDimensions,ylims=(-height/2,height/2)))
        end

        #number of rings in BC,
        numRings = length(BC)
        numCuLayers = (numRings - 4) / 2 #number of Copper layers on each side of BC

        #height of BC
        last(BC[1][3]) #BC first layer (bottom), z coordinate, and last entry which is lowest
        last(BC[lastindex(BC)][3]) #BC last layer (top), z coordiante, and last entry which is highest
        height = last(BC[lastindex(BC)][3]) - last(BC[1][3])

        #initializes a camerra and axis settings
        xlims=(-50,50)
        ylims=(-50,50)

        #Displaying rings on plot
        if (specifiedRings == []) #do full view
            #print("Total rings: ", numRings ," \nPlotting ring number: \n")
            for layer in 1:numRings
                #print(layer, " ")
                if(disableBrass && BC[layer][7][1]=='B') continue end
                if(disableCopper && BC[layer][7][1]=='C') continue end
                if(disableCurvature && BC[layer][7][2]=='C') continue end
                if(disableBias && BC[layer][7][2]=='B') continue end
                if(disableTop && BC[layer][7][3]!='H') continue end
                if(disableBot && BC[layer][7][3]=='H') continue end
                BuildBC( BC[layer][1:6] ,BC[layer][7],axes) #passes in x,y,z,u,v,w for quiver and then BCType for color
            end
        else #do only specifiedRigns view
            numSpecifiedRings = length(specifiedRings)
            #print("Total rings: ", numSpecifiedRings ," \nPlotting ring number: \n")
            for layer in 1:numSpecifiedRings
                #print(specifiedRings[layer], " ") 
                if(disableBrass && BC[layer][7][1]=='B') continue end
                if(disableCopper && BC[layer][7][1]=='C') continue end
                if(disableCurvature && BC[layer][7][2]=='C') continue end
                if(disableBias && BC[layer][7][2]=='B') continue end
                if(disableTop && BC[layer][7][3]!='H') continue end
                if(disableBot && BC[layer][7][3]=='H') continue end
                BuildBC( BC[specifiedRings[layer]][1:6] ,BC[specifiedRings[layer]][7], axes) #passes in x,y,z,u,v,w for quiver and then BCType for color
            end
        end

        #ensures that whole plot is displayyed after function
        quiver!(0,0,0,quiver=(0,0,0),ylims=(-height/2,height/2))
        
    end

    "Pass in a tuple of x y z coordinates of points and their directions for vectors with u v w, pass three arrays as tuples
    optional: rotate::bool"
    function VisualizeRing(ring::Tuple,axes::String)

        height = ring[3][lastindex(ring[3])] - ring[3][1]
        if(axes=="xy")
            plotDimensions = (600,600)
            display(quiver(0,0,quiver=(0,0),size=plotDimensions))
            x,y,z,u,v,w = ring   
            quiver(x,y,quiver=(u,v))
        else
            plotDimensions = (400,600)
            display(quiver(0,0,quiver=(0,0),size=plotDimensions,ylims=(-height/2,height/2)))
            x,y,z,u,v,w = ring   
            quiver(x,z,quiver=(u,w))
        end

        #x,y,z,u,v,w = ring   
        #quiver(x,y,quiver=(u,v))
    
        #saving plot
    
        display(quiver!(0,0,quiver=(0,0))) 
        
        time = Dates.format(now(),"yyy-mm-dddTHH-MM-SS")    
        filename = "/Users/zirdisyukur/Julia/Research/WithPlots/figures/VisualizeBC_build_"*time*".png"
        println("saved to " * filename)
        savefig(filename)
    
    end

    "Pass in a tuple of rectangles"
    function VisualizeRec(rec::Array;reset::Bool=false)

        #resetplot
        if(reset) quiver() end

        for i in 1:length(rec)
            BuildBCScrews(rec[i],rec[i][7])
            #print(i)
        end
        return(quiver!(0,0,0,quiver=(0,0,0),zlims=(-70,70),camera = (45,45)))
    end

    "2D version!!! Pass in a tuple of rectangles"
    function VisualizeRec(rec::Array, axes::String;reset::Bool=false)
        
        #resetplot
        if(reset) quiver() end
        
        for i in 1:length(rec)
            BuildBCScrews(rec[i],rec[i][7],axes)
            #print(i)
        end

        if(axes=="xy")
            plotDimensions = (600,600)
            return(quiver!(0,0,quiver=(0,0),size=plotDimensions,xlims=(-60,60),ylims=(-60,60)))

        else
            plotDimensions = (400,600)
            return(display(quiver!(0,0,quiver=(0,0),size=plotDimensions,xlims=(-60,60),ylims=(-80,80))))
        end
        #return(quiver!(0,0,0,quiver=(0,0,0),zlims=(-70,70),camera = (45,45)))
    end

end

#Generates array BC that contains a ring for each index that represents a portion of the BC
"Returns array that defines entire BC"
function GenerateBC(;rotate=false,disableBrass=false,disableCopper=false,disableCurvature=false,disableBias=false,
    disableTop=false,disableBot=false,onlyLayer=-1,frame=pi/2,fullsize=false,upto="fillertext")

    #initialized BC array to be returned
    BC=[]
    #defining BC dimensions
    brDims , cuCDims, cuBDims, cuCDimsBot, cuBDimsBot = GenerateBCDims(
        numberCuLayers,sepBC,brWidth=tBrassBC,cuWidth=tCuBC,curvatureInRad=rinC,curvatureOutRad=routC,biasInRad=rinB,biasOutRad=routB)

    #for testing Bfield
    #brDims , cuCDims, cuBDims, cuCDimsBot, cuBDimsBot = GenerateBCDims(numberCuLayers,sepBC,brWidth=tBrassBC,cuWidth=tCuBC,curvatureInRad=rinB,curvatureOutRad=routB,biasInRad=rinB,biasOutRad=routB)

    #error exception for invalid upto parameters
    possibleUpto = ["fillertext", "copperH_", "brassH", "brass", "copper_"]
    if(upto != "fillertext") #if upto is not filltext
        if(!occursin("brass",upto))
            if(!occursin("copper",upto))
                error("invalid upto parameter")
            end
        end
    end

    #defines height from zero
    q,w,height,r,t,y=GenerateRing(cuBDims[numberCuLayers][1],cuBDims[numberCuLayers][2],cuBDims[numberCuLayers][3],cuBDims[numberCuLayers][4])
    height=height[1]+2

    #initializes a camerra and axis settings
    cameraX=40+10*cos(frame)
    cameraY=45-20*cos(frame)
    xlims=(-50,50)
    ylims=(-50,50)

    #initializes plot with varying dimensiosn depending on job
    if(fullsize)
        zlims=(-height,height)
        quiver(0,0,0,quiver=(0,0,0),xlims=xlims,ylims=ylims,zlims=zlims,size=(600,600,10))
    else
        quiver(0,0,0,quiver=(0,0,0),xlims=xlims,ylims=ylims,size=(600,600,10))
    end
    #defines plot camera
    temp=[0,0,0]
    quiver!(temp,temp,temp,quiver=(temp,temp,temp),camera=(cameraX,cameraY))



    #start building from bottom up: build buttom copper layers first, then bottom brass, then top brass, then top copper

    #Building bottom copper layers (top layer to bottom) unless disabled
    if(!disableCopper)
        #push (!) other copper coils to quiver plot
        if(onlyLayer == -1)
            for i in numberCuLayers:-1:1
                if(i%2==0) #even layers
                    if(!disableBot && !disableCurvature)  BC=vcat(BC,[GenerateRing(cuCDimsBot[i][2],cuCDimsBot[i][1],cuCDimsBot[i][3],cuCDimsBot[i][4],layer=i,BCType="CCHE")]) end #Copper Curvature H
                    if(!disableBot && !disableBias) BC=vcat(BC,[GenerateRing(cuBDimsBot[i][2],cuBDimsBot[i][1],cuBDimsBot[i][3],cuBDimsBot[i][4],layer=i,BCType="CBHE")]) end #Copper Bias H
                    if(upto[1]=='c' && upto[1:8]=="copperH_" && parse(Int64,upto[9:end])==i ) #If is of type copperH and digit after copperH is equal to the only layer specified
                        return BC
                    end

                else #odd layers
                    if(!disableBot && !disableCurvature) BC=vcat(BC,[GenerateRing(cuCDimsBot[i][1],cuCDimsBot[i][2],cuCDimsBot[i][3],cuCDimsBot[i][4],layer=i,BCType="CCHO")]) end#Copper Curvature H
                    if(!disableBot && !disableBias) BC=vcat(BC,[GenerateRing(cuBDimsBot[i][1],cuBDimsBot[i][2],cuBDimsBot[i][3],cuBDimsBot[i][4],layer=i,BCType="CBHO")]) end#Copper Bias H

                    if(upto[1]=='c' && upto[1:8]=="copperH_" && parse(Int64,upto[9:end])==i ) #If is of type copperH and digit after copperH is equal to the layer specified
                        return BC
                    end

                end
            end
        else #case if onlyLayer parameter is specified
            if(onlyLayer%2==0) #even layers
                #print("layer", onlyLayer)
                i=onlyLayer
                if(!disableBot && !disableCurvature) BC=vcat(BC,[GenerateRing(cuCDimsBot[i][1],cuCDimsBot[i][2],cuCDimsBot[i][3],cuCDimsBot[i][4],layer=i,BCType="CCHE")]) end #Copper Curvature H
                if(!disableBot && !disableBias) BC=vcat(BC,[GenerateRing(cuBDimsBot[i][1],cuBDimsBot[i][2],cuBDimsBot[i][3],cuBDimsBot[i][4],layer=i,BCType="CBHE")]) end #Copper Bias H
            else #odd layers
                #print("layer", onlyLayer)
                i=onlyLayer
                if(!disableBot && !disableCurvature) BC=vcat(BC,[GenerateRing(cuCDimsBot[i][1],cuCDimsBot[i][2],cuCDimsBot[i][3],cuCDimsBot[i][4],layer=i,BCType="CCHO")]) end #Copper Curvature H
                if(!disableBot && !disableBias) BC=vcat(BC,[GenerateRing(cuBDimsBot[i][1],cuBDimsBot[i][2],cuBDimsBot[i][3],cuBDimsBot[i][4],layer=i,BCType="CBHO")]) end #Copper Bias H
            end
        end
    end

    #Building Brass rings unless disabled
    if(!disableBrass)
        #push (!) other brass coils to quiver plot, unless disabled, building from bottom up
        if((onlyLayer == -1) && !disableBot && !disableCurvature) BC=vcat(BC,[GenerateRing(brDims[3][2],brDims[3][1],brDims[3][3],brDims[3][4],BCType="BCH_")]) end #Build Brass Curvature H
        if((onlyLayer == -1) && !disableBot && !disableBias) BC=vcat(BC,[GenerateRing(brDims[4][2],brDims[4][1],brDims[4][3],brDims[4][4],BCType="BBH_")]) end #Build Brass Bias H
        
        if(upto=="brassH") #If upto is of type brassH
            return BC
        end

        if((onlyLayer == -1) && !disableTop && !disableCurvature) BC=vcat(BC,[GenerateRing(brDims[1][1],brDims[1][2],brDims[1][3],brDims[1][4],BCType="BC__")]) end #Build Brass Curvature
        if((onlyLayer == -1) && !disableTop && !disableBias) BC=vcat(BC,[GenerateRing(brDims[2][1],brDims[2][2],brDims[2][3],brDims[2][4],BCType="BB__")]) end #Build Brass Bias
   
        if(upto=="brass") #If upto is of type brassH
            return BC
        end    
        
    end

    #Building top Copper rings unless disabled
    if(!disableCopper)
        #println("Step 2: Visualizing Copper rings")

        #push (!) other copper coils to quiver plot
        if(onlyLayer == -1)
            #println("layer: ")
            for i in 1:numberCuLayers
                if(i%2==0) #even layers
                    #print(i, " ")
                    if(!disableTop && !disableCurvature) BC=vcat(BC,[GenerateRing(cuCDims[i][1],cuCDims[i][2],cuCDims[i][3],cuCDims[i][4],layer=i,BCType="CCE_")]) end #Copper Curvature
                    if(!disableTop && !disableBias) BC=vcat(BC,[GenerateRing(cuBDims[i][1],cuBDims[i][2],cuBDims[i][3],cuBDims[i][4],layer=i,BCType="CBE_")]) end #Copper Bias

                    if(upto[1]=='c' && upto[1:7]=="copper_" && parse(Int64,upto[8:end])==i ) #If is of type copperH and digit after copperH is equal to the layer specified
                        return BC
                    end

                else #odd layers
                    #print(i, " ")
                    if(!disableTop && !disableCurvature) BC=vcat(BC,[GenerateRing(cuCDims[i][1],cuCDims[i][2],cuCDims[i][3],cuCDims[i][4],layer=i,BCType="CCO_")]) end #Copper Curvature
                    if(!disableTop && !disableBias) BC=vcat(BC,[GenerateRing(cuBDims[i][1],cuBDims[i][2],cuBDims[i][3],cuBDims[i][4],layer=i,BCType="CBO_")]) end #Copper Bias

                    if(upto[1]=='c' && upto[1:7]=="copper_" && parse(Int64,upto[8:end])==i ) #If is of type copperH and digit after copperH is equal to the layer specified
                        return BC
                    end

                end
            end
        else
            if(onlyLayer%2==0) #even layers
                #print("layer", onlyLayer)
                i=onlyLayer
                if(!disableTop && !disableCurvature) BC=vcat(BC,[GenerateRing(cuCDims[i][1],cuCDims[i][2],cuCDims[i][3],cuCDims[i][4],layer=i,BCType="CCE_")]) end #Copper Curvature
                if(!disableTop && !disableBias) BC=vcat(BC,[BuildBC(GenerateRing(cuBDims[i][1],cuBDims[i][2],cuBDims[i][3],cuBDims[i][4],layer=i,BCType="CBE_"))]) end #Copper Bias
            else #odd layers
                #print("layer", onlyLayer)
                i=onlyLayer
                if(!disableTop && !disableCurvature) BC=vcat(BC,[BuildBC(GenerateRing(cuCDims[i][1],cuCDims[i][2],cuCDims[i][3],cuCDims[i][4],layer=i,BCType="CCO_"))]) end #Copper Curvature
                if(!disableTop && !disableBias) BC=vcat(BC,[GenerateRing(cuBDims[i][1],cuBDims[i][2],cuBDims[i][3],cuBDims[i][4],layer=i,BCType="CBO_")]) end #Copper Bias
            end
        end
    end

    #ensures that whole plot is displayyed after function
    #display(quiver!(0,0,0,quiver=(0,0,0),camera = (cameraX,cameraY))) 

    #saving plot
    #time = Dates.format(now(),"yyy-mm-dddTHH-MM-SS")    
    #filename = "/Users/zirdisyukur/Julia/Research/WithPlots/figures/VisualizeBC_build_"*time*".png"
    #println("saved to " * filename)
    #savefig(filename)
    return BC
end


"Generating arrays that define BC spacers"
function GenerateSpacers(;disableSpacerC=false,disableSpacerB=false,disableSpacerCH=false,disableSpacerBH=false)
    spacerC=[]
    spacerB=[]
    spacerCH=[]
    spacerBH=[]

    for layer in 1:nlayersBC
        spacerC = cat(spacerC, GenerateRectangle( ( 0.5(routC + rinC)*cos((layer-1)*pi/5 + pi/10) , 0.5(routC + rinC)*sin((layer-1)*pi/5 + pi/10) , (zposBC(layer) + tSpacerBC/2 )) ,
     (routC-rinC,routC-rinC,tSpacerBC) , (0,0,1), "SpacerC" ),dims=1)

        spacerB = cat(spacerB, GenerateRectangle( ( 0.5(routB + rinB)*cos((-layer-1)*pi/5 + pi/10) , 0.5(routB + rinB)*sin((-layer-1)*pi/5 + pi/10) , (zposBC(layer) + tSpacerBC/2 )) ,
     (routC-rinC,routC-rinC,tSpacerBC) , (0,0,1), "SpacerB" ),dims=1)

        spacerCH = cat(spacerCH, GenerateRectangle( ( 0.5(routC + rinC)*cos(angHoffBC+(-layer-1)*pi/5 + pi/10) , 0.5(routC + rinC)*sin(angHoffBC+(-layer-1)*pi/5 + pi/10) , (-zposBC(layer) - tSpacerBC/2 )) ,
     (routC-rinC,routC-rinC,tSpacerBC) , (0,0,1), "SpacerCH" ),dims=1)

        spacerBH = cat(spacerBH, GenerateRectangle( ( 0.5(routB + rinB)*cos(angHoffBC+(layer-1)*pi/5 + pi/10) , 0.5(routB + rinB)*sin(angHoffBC+(layer-1)*pi/5 + pi/10) , (-zposBC(layer) - tSpacerBC/2 )) ,
     (routC-rinC,routC-rinC,tSpacerBC) , (0,0,1), "SpacerBH" ),dims=1)
    end

    if(disableSpacerC) spacerC=[] end
    if(disableSpacerB) spacerB=[] end
    if(disableSpacerCH) spacerCH=[] end
    if(disableSpacerBH) spacerBH=[] end

    return cat(spacerC,spacerB,spacerCH,spacerBH,dims=1)
end

#Generates array BC that contains a ring for each index that represents a portion of the BC
"Returns array that defines BC's screws?"
function GenerateScrews()

    #initialized BC array to be returned
    BCScrews=[] #will have x y z u v w and screw type 

    BCScrews = cat(BCScrews, GenerateRectangle( ( 0.5(routC + rinC)*cos((0-1)*pi/5 + pi/10) , 0.5(routC + rinC)*sin((0-1)*pi/5 + pi/10) , (zposBC(1) + zposBC(nlayersBC)+4)/2 ) ,
     (xtScrew,ytScrew,ztScrew) , (0,0,1),"ScrewC" ),dims=1)
    BCScrews = cat(BCScrews, GenerateRectangle( ( 0.5(routB + rinB)*cos((0-1)*pi/5 + pi/10) , 0.5(routB + rinB)*sin((0-1)*pi/5 + pi/10) , (zposBC(1) + zposBC(nlayersBC)+4)/2 ) ,
     (xtScrew,ytScrew,ztScrew) , (0,0,1),"ScrewB"  ),dims=1)
    BCScrews = cat(BCScrews, GenerateRectangle( ( 0.5(routC + rinC)*cos(angHoffBC + (0-1)*pi/5 + pi/10) , 0.5(routC + rinC)*sin(angHoffBC+(0-1)*pi/5 + pi/10) , -(zposBC(1) + zposBC(nlayersBC)+4)/2 ) ,
     (xtScrew,ytScrew,ztScrew) , (0,0,-1),"ScrewCH"  ),dims=1)
    BCScrews = cat(BCScrews, GenerateRectangle( ( 0.5(routB + rinB)*cos(angHoffBC + (0-1)*pi/5 + pi/10) , 0.5(routB + rinB)*sin(angHoffBC+(0-1)*pi/5 + pi/10) , -(zposBC(1) + zposBC(nlayersBC)+4)/2 ) ,
     (xtScrew,ytScrew,ztScrew) , (0,0,-1),"ScrewBH"  ),dims=1)
    
    return BCScrews
end

#Issues, 
#arrow head size doesn't change, jarring in 2D view
#make stretch in z direction nicer to view
#plotting doesn't go in order so plot looks weird (still kinda unresolved)

#LEGACY CONTENT FOR BOOKKEEPING~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~``

#makes gif of visualization
#"VisualizeBC optional: rotate::bool"
#=
function VisualizeBC(;rotate=false,disableBrass=false,disableCopper=false,disableCurvature=false,disableBias=false,
    disableTop=false,disableBot=false,onlyLayer=-1,frame=pi/2,fullsize=false,upto="fillertext")

    resetB()

    #error exception for invalid upto parameters
    possibleUpto = ["fillertext", "copperH_", "brassH", "brass", "copper_"]
    if(upto != "fillertext") #if upto is not filltext
        if(!occursin("brass",upto))
            if(!occursin("copper",upto))
                error("invalid upto parameter")
            end
        end
    end

    #defines height from zero
    q,w,height,r,t,y=GenerateRing(cuBDims[numberCuLayers][1],cuBDims[numberCuLayers][2],cuBDims[numberCuLayers][3],cuBDims[numberCuLayers][4])
    height=height[1]+2

    #initializes a camerra and axis settings
    cameraX=40+10*cos(frame)
    cameraY=45-20*cos(frame)
    xlims=(-50,50)
    ylims=(-50,50)

    #initializes plot with varying dimensiosn depending on job
    if(fullsize)
        zlims=(-height,height)
        display(quiver(0,0,0,quiver=(0,0,0),xlims=xlims,ylims=ylims,zlims=zlims,size=(600,600,10))) 
    else
        display(quiver(0,0,0,quiver=(0,0,0),xlims=xlims,ylims=ylims,size=(600,600,10))) 
    end
    #defines plot camera
    temp=[0,0,0]
    quiver!(temp,temp,temp,quiver=(temp,temp,temp),camera=(cameraX,cameraY))



    #start building from bottom up: build buttom copper layers first, then bottom brass, then top brass, then top copper

    #Building bottom copper layers (top layer to bottom) unless disabled
    if(!disableCopper)
        #push (!) other copper coils to quiver plot
        if(onlyLayer == -1)
            for i in numberCuLayers:-1:1
                if(i%2==0) #even layers
                    !disableBot && !disableCurvature && BuildBC(GenerateRing(cuCDimsBot[i][1],cuCDimsBot[i][2],cuCDimsBot[i][3],cuCDimsBot[i][4],layer=i,BCType="curvature"),"copperEven") #Copper Curvature H
                    !disableBot && !disableBias && BuildBC(GenerateRing(cuBDimsBot[i][1],cuBDimsBot[i][2],cuBDimsBot[i][3],cuBDimsBot[i][4],layer=i,BCType="bias"),"copperEven") #Copper Bias H
                    if(upto[1]=='c' && upto[1:8]=="copperH_" && parse(Int64,upto[9:end])==i ) #If is of type copperH and digit after copperH is equal to the only layer specified
                        return display(quiver!(0,0,0,quiver=(0,0,0),camera = (cameraX,cameraY))) #return plot as is
                    end

                else #odd layers
                    !disableBot && !disableCurvature && BuildBC(GenerateRing(cuCDimsBot[i][1],cuCDimsBot[i][2],cuCDimsBot[i][3],cuCDimsBot[i][4],layer=i,BCType="curvature")) #Copper Curvature H
                    !disableBot && !disableBias && BuildBC(GenerateRing(cuBDimsBot[i][1],cuBDimsBot[i][2],cuBDimsBot[i][3],cuBDimsBot[i][4],layer=i,BCType="bias")) #Copper Bias H

                    if(upto[1]=='c' && upto[1:8]=="copperH_" && parse(Int64,upto[9:end])==i ) #If is of type copperH and digit after copperH is equal to the layer specified
                        return display(quiver!(0,0,0,quiver=(0,0,0),camera = (cameraX,cameraY))) #return plot as is
                    end

                end
            end
        else #case if onlyLayer parameter is specified
            if(onlyLayer%2==0) #even layers
                #print("layer", onlyLayer)
                i=onlyLayer
                !disableBot && !disableCurvature && BuildBC(GenerateRing(cuCDimsBot[i][1],cuCDimsBot[i][2],cuCDimsBot[i][3],cuCDimsBot[i][4],layer=i,BCType="curvature"),"copperEven") #Copper Curvature H
                !disableBot && !disableBias && BuildBC(GenerateRing(cuBDimsBot[i][1],cuBDimsBot[i][2],cuBDimsBot[i][3],cuBDimsBot[i][4],layer=i,BCType="bias"),"copperEven") #Copper Bias H
            else #odd layers
                #print("layer", onlyLayer)
                i=onlyLayer
                !disableBot && !disableCurvature && BuildBC(GenerateRing(cuCDimsBot[i][1],cuCDimsBot[i][2],cuCDimsBot[i][3],cuCDimsBot[i][4],layer=i,BCType="curvature")) #Copper Curvature H
                !disableBot && !disableBias && BuildBC(GenerateRing(cuBDimsBot[i][1],cuBDimsBot[i][2],cuBDimsBot[i][3],cuBDimsBot[i][4],layer=i,BCType="bias")) #Copper Bias H
            end
        end
    end

    #Building Brass rings unless disabled
    if(!disableBrass)
        #push (!) other brass coils to quiver plot, unless disabled, building from bottom up
        (onlyLayer == -1) && !disableBot && !disableCurvature && BuildBC(GenerateRing(brDims[3][1],brDims[3][2],brDims[3][3],brDims[3][4],BCType="curvature"),"brass") #Build Brass Curvature H
        (onlyLayer == -1) && !disableBot && !disableBias && BuildBC(GenerateRing(brDims[4][1],brDims[4][2],brDims[4][3],brDims[4][4],BCType="bias"),"brass") #Build Brass Bias H
        
        if(upto=="brassH") #If upto is of type brassH
            return display(quiver!(0,0,0,quiver=(0,0,0),camera = (cameraX,cameraY))) #return plot as is
        end

        (onlyLayer == -1) && !disableTop && !disableCurvature && BuildBC(GenerateRing(brDims[1][1],brDims[1][2],brDims[1][3],brDims[1][4],BCType="curvature"),"brass") #Build Brass Curvature
        (onlyLayer == -1) && !disableTop && !disableBias && BuildBC(GenerateRing(brDims[2][1],brDims[2][2],brDims[2][3],brDims[2][4],BCType="bias"),"brass") #Build Brass Bias
   
        if(upto=="brass") #If upto is of type brassH
            return display(quiver!(0,0,0,quiver=(0,0,0),camera = (cameraX,cameraY))) #return plot as is
        end    
        
    end

    #Building top Copper rings unless disabled
    if(!disableCopper)
        #println("Step 2: Visualizing Copper rings")

        #push (!) other copper coils to quiver plot
        if(onlyLayer == -1)
            #println("layer: ")
            for i in 1:numberCuLayers
                if(i%2==0) #even layers
                    #print(i, " ")
                    !disableTop && !disableCurvature && BuildBC(GenerateRing(cuCDims[i][1],cuCDims[i][2],cuCDims[i][3],cuCDims[i][4],layer=i,BCType="curvature"),"copperEven") #Copper Curvature
                    !disableTop && !disableBias && BuildBC(GenerateRing(cuBDims[i][1],cuBDims[i][2],cuBDims[i][3],cuBDims[i][4],layer=i,BCType="bias"),"copperEven") #Copper Bias

                    if(upto[1]=='c' && upto[1:7]=="copper_" && parse(Int64,upto[8:end])==i ) #If is of type copperH and digit after copperH is equal to the layer specified
                        return display(quiver!(0,0,0,quiver=(0,0,0),camera = (cameraX,cameraY))) #return plot as is
                    end

                else #odd layers
                    #print(i, " ")
                    !disableTop && !disableCurvature && BuildBC(GenerateRing(cuCDims[i][1],cuCDims[i][2],cuCDims[i][3],cuCDims[i][4],layer=i,BCType="curvature")) #Copper Curvature
                    !disableTop && !disableBias && BuildBC(GenerateRing(cuBDims[i][1],cuBDims[i][2],cuBDims[i][3],cuBDims[i][4],layer=i,BCType="bias")) #Copper Bias

                    if(upto[1]=='c' && upto[1:7]=="copper_" && parse(Int64,upto[8:end])==i ) #If is of type copperH and digit after copperH is equal to the layer specified
                        return display(quiver!(0,0,0,quiver=(0,0,0),camera = (cameraX,cameraY))) #return plot as is
                    end

                end
            end
        else
            if(onlyLayer%2==0) #even layers
                #print("layer", onlyLayer)
                i=onlyLayer
                !disableTop && !disableCurvature && BuildBC(GenerateRing(cuCDims[i][1],cuCDims[i][2],cuCDims[i][3],cuCDims[i][4],layer=i),"copperEven") #Copper Curvature
                !disableTop && !disableBias && BuildBC(GenerateRing(cuBDims[i][1],cuBDims[i][2],cuBDims[i][3],cuBDims[i][4],layer=i),"copperEven") #Copper Bias
            else #odd layers
                #print("layer", onlyLayer)
                i=onlyLayer
                !disableTop && !disableCurvature && BuildBC(GenerateRing(cuCDims[i][1],cuCDims[i][2],cuCDims[i][3],cuCDims[i][4],layer=i)) #Copper Curvature
                !disableTop && !disableBias && BuildBC(GenerateRing(cuBDims[i][1],cuBDims[i][2],cuBDims[i][3],cuBDims[i][4],layer=i)) #Copper Bias
            end
        end
    end

    #ensures that whole plot is displayyed after function
    display(quiver!(0,0,0,quiver=(0,0,0),camera = (cameraX,cameraY))) 

    #saving plot
    time = Dates.format(now(),"yyy-mm-dddTHH-MM-SS")    
    filename = "/Users/zirdisyukur/Julia/Research/WithPlots/figures/VisualizeBC_build_"*time*".png"
    println("saved to " * filename)
    savefig(filename)
     
end
=#

#makes gif of visualization
#=
"VisualizeBC version where you can rotate coils optional: rotate::bool"
function VisualizeBC_rotate(rotate=false,disableBrass=false,disableCopper=false,disableCurvature=false,disableBias=false)
    colorBrass = :viridis
    colorCopper = :winter

    #rotate==false ? lengthGif = 1 : lengthGif=50
    @gif for frame in range(0, stop = 2pi, length = 50)

        #Building Brass 

        #if(!disableBrass)
            #first Brass curvature to set up quiver plot
            println("Visualizing first ring (Brass Curvature)")
            x,y,z,u,v,w=GenerateRing(brDims[1][1],brDims[1][2],brDims[1][3],brDims[1][4])
            if(rotate)
                quiver(x,y,z,quiver=(u,v,w),camera = (40+10*cos(frame),45),color=:viridis)
            else
                quiver(x,y,z,quiver=(u,v,w),camera = (45,45),color=:viridis)
            end

            #push (!) other brass coils to quiver plot
            println("Visualizing other Brass rings (BB,BCH,BBH)")
            BuildBC(GenerateRing(brDims[2][1],brDims[2][2],brDims[2][3],brDims[2][4]),"brass") #Build Brass Bias
            BuildBC(GenerateRing(brDims[3][1],brDims[3][2],brDims[3][3],brDims[3][4]),"brass") #Build Brass Bias
            BuildBC(GenerateRing(brDims[4][1],brDims[4][2],brDims[4][3],brDims[4][4]),"brass") #Build Brass Bias
        #end

        #if(!disableCopper)
            #push (!) other copper coils to quiver plot
            println("Visualizing Copper rings")
            for i in 1:numberCuLayers
                if(i%2==0) #even layers
                    BuildBC(GenerateRing(cuCDims[i][1],cuCDims[i][2],cuCDims[i][3],cuCDims[i][4],layer=i),"copperEven")
                    BuildBC(GenerateRing(cuBDims[i][1],cuBDims[i][2],cuBDims[i][3],cuBDims[i][4],layer=i),"copperEven")
                    BuildBC(GenerateRing(cuCDimsBot[i][1],cuCDimsBot[i][2],cuCDimsBot[i][3],cuCDimsBot[i][4],layer=i),"copperEven")
                    BuildBC(GenerateRing(cuBDimsBot[i][1],cuBDimsBot[i][2],cuBDimsBot[i][3],cuBDimsBot[i][4],layer=i),"copperEven")
                else #odd layers
                    BuildBC(GenerateRing(cuCDims[i][1],cuCDims[i][2],cuCDims[i][3],cuCDims[i][4],layer=i))
                    BuildBC(GenerateRing(cuBDims[i][1],cuBDims[i][2],cuBDims[i][3],cuBDims[i][4],layer=i))
                    BuildBC(GenerateRing(cuCDimsBot[i][1],cuCDimsBot[i][2],cuCDimsBot[i][3],cuCDimsBot[i][4],layer=i))
                    BuildBC(GenerateRing(cuBDimsBot[i][1],cuBDimsBot[i][2],cuBDimsBot[i][3],cuBDimsBot[i][4],layer=i))
                end
            end
        #end

        if(!rotate) 
            break
        end
    end
end
=#

#=
"Similar function to above but limitting to 2 dimensional view"
function VisualizeBC_2D(axes="xz")

    arrowResolution=0.05

    #plots first the curvature Brass coil
    x,y,z,u,v,w=GenerateRing(brDims[1][1],brDims[1][2],brDims[1][3],brDims[1][4])
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
    else
        a=y
        b=z
        c=v
        d=w
    end

    quiver(a,b,quiver=(c,d))
   
    #push (!) other brass coils to quiver plot
    BuildBC_2D(GenerateRing(brDims[2][1],brDims[2][2],brDims[2][3],brDims[2][4],arrowRes=arrowResolution),"brass",axes) #Build Brass Bias
    BuildBC_2D(GenerateRing(brDims[3][1],brDims[3][2],brDims[3][3],brDims[3][4],arrowRes=arrowResolution),"brass",axes) #Build Brass Bias
    BuildBC_2D(GenerateRing(brDims[4][1],brDims[4][2],brDims[4][3],brDims[4][4],arrowRes=arrowResolution),"brass",axes) #Build Brass Bias

    #push (!) other copper coils to quiver plot
    #=PUSHIGN WITH LOOPS DOESN"T WORK FOR SOME REASON SO GET RID OF LOOP TEMPORARILY
    for i in 1:numberCuLayers
        if(i%2==0) #even layers
            BuildBC_2D(GenerateRing(cuCDims[i][1],cuCDims[i][2],cuCDims[i][3],cuCDims[i][4]),"copperEven",axes)
            BuildBC_2D(GenerateRing(cuBDims[i][1],cuBDims[i][2],cuBDims[i][3],cuBDims[i][4]),"copperEven",axes)
        else #odd layers
            BuildBC_2D(GenerateRing(cuCDims[i][1],cuCDims[i][2],cuCDims[i][3],cuCDims[i][4]),"copperOdd",axes)
            BuildBC_2D(GenerateRing(cuBDims[i][1],cuBDims[i][2],cuBDims[i][3],cuBDims[i][4]),"copperOdd",axes)
        end
    end
    =#

    BuildBC_2D(GenerateRing(cuCDims[1][1],cuCDims[1][2],cuCDims[1][3],cuCDims[1][4],arrowRes=arrowResolution),"copperEven",axes)
    BuildBC_2D(GenerateRing(cuBDims[1][1],cuBDims[1][2],cuBDims[1][3],cuBDims[1][4],arrowRes=arrowResolution),"copperEven",axes)
    BuildBC_2D(GenerateRing(cuCDimsBot[1][1],cuCDimsBot[1][2],cuCDimsBot[1][3],cuCDimsBot[1][4]),"copperEven",axes)
    BuildBC_2D(GenerateRing(cuBDimsBot[1][1],cuBDimsBot[1][2],cuBDimsBot[1][3],cuBDimsBot[1][4]),"copperEven",axes)
end=#


#=
function VisualizeBC_2D(axes="xy";disableBrass=false,disableCopper=false,disableCurvature=false,disableBias=false,
    disableTop=false,disableBot=false,onlyLayer=-1)

    #variables
    arrowResolution=0.05

    if(axes=="xy")
        plotDimensions = (400,400)
    else
        plotDimensions = (400,600)
    end

    #initializes a plot
    display(quiver(0,0,quiver=(0,0),size=plotDimensions))

    if(!disableBrass)
        println("Step 1: Visualizing Brass rings")
        #push (!) other brass coils to quiver plot
        (onlyLayer == -1) && !disableTop && !disableCurvature && BuildBC_2D(GenerateRing(brDims[1][1],brDims[1][2],brDims[1][3],brDims[1][4],arrowRes=arrowResolution,type="brassC",BCType="curvature"),"brass",axes) #Build Brass Curvature
        (onlyLayer == -1) && !disableTop && !disableBias && BuildBC_2D(GenerateRing(brDims[2][1],brDims[2][2],brDims[2][3],brDims[2][4],arrowRes=arrowResolution,type="brassB",BCType="bias"),"brass",axes) #Build Brass Bias
        (onlyLayer == -1) && !disableBot && !disableCurvature && BuildBC_2D(GenerateRing(brDims[3][1],brDims[3][2],brDims[3][3],brDims[3][4],arrowRes=arrowResolution,type="brassCH",BCType="curvature"),"brass",axes) #Build Brass CurvatureH
        (onlyLayer == -1) && !disableBot && !disableBias && BuildBC_2D(GenerateRing(brDims[4][1],brDims[4][2],brDims[4][3],brDims[4][4],arrowRes=arrowResolution,type="brassBH",BCType="bias"),"brass",axes) #Build Brass Bias
    end

    if(!disableCopper)
        println("Step 2: Visualizing Copper rings")
        #push (!) other copper coils to quiver plot

        if(onlyLayer == -1) #If specific layer isn't specified, plot all layers
            println("layers: ")
            for i in 1:numberCuLayers
                if(i%2==0) #even layers
                    print(i, " ")
                    !disableTop && !disableCurvature && BuildBC_2D(GenerateRing(cuCDims[i][1],cuCDims[i][2],cuCDims[i][3],cuCDims[i][4],layer=i,arrowRes=arrowResolution,BCType="curvature"),"copperEven",axes)
                    !disableTop && !disableBias && BuildBC_2D(GenerateRing(cuBDims[i][1],cuBDims[i][2],cuBDims[i][3],cuBDims[i][4],layer=i,arrowRes=arrowResolution,BCType="bias"),"copperEven",axes)
                    !disableBot && !disableCurvature && BuildBC_2D(GenerateRing(cuCDimsBot[i][1],cuCDimsBot[i][2],cuCDimsBot[i][3],cuCDimsBot[i][4],layer=i,BCType="curvature"),"copperEven",axes)
                    !disableBot && !disableBias && BuildBC_2D(GenerateRing(cuBDimsBot[i][1],cuBDimsBot[i][2],cuBDimsBot[i][3],cuBDimsBot[i][4],layer=i,BCType="bias"),"copperEven",axes)
                else #odd layers
                    print(i, " ")
                    !disableTop && !disableCurvature && BuildBC_2D(GenerateRing(cuCDims[i][1],cuCDims[i][2],cuCDims[i][3],cuCDims[i][4],layer=i,arrowRes=arrowResolution,BCType="curvature"),"copperOdd",axes)
                    !disableTop && !disableBias && BuildBC_2D(GenerateRing(cuBDims[i][1],cuBDims[i][2],cuBDims[i][3],cuBDims[i][4],layer=i,arrowRes=arrowResolution,BCType="bias"),"copperOdd",axes)
                    !disableBot && !disableCurvature && BuildBC_2D(GenerateRing(cuCDimsBot[i][1],cuCDimsBot[i][2],cuCDimsBot[i][3],cuCDimsBot[i][4],layer=i,BCType="curvature"),"copperOdd",axes)
                    !disableBot && !disableBias && BuildBC_2D(GenerateRing(cuBDimsBot[i][1],cuBDimsBot[i][2],cuBDimsBot[i][3],cuBDimsBot[i][4],layer=i,BCType="bias"),"copperOdd",axes)
                end
            end

        else #If a particular layer is specified, only show this layer
            if(onlyLayer%2==0) #even layers
                print("layer", onlyLayer)
                i=onlyLayer
                !disableTop && !disableCurvature && BuildBC_2D(GenerateRing(cuCDims[i][1],cuCDims[i][2],cuCDims[i][3],cuCDims[i][4],layer=i,arrowRes=arrowResolution,BCType="curvature"),"copperEven",axes)
                !disableTop && !disableBias && BuildBC_2D(GenerateRing(cuBDims[i][1],cuBDims[i][2],cuBDims[i][3],cuBDims[i][4],layer=i,arrowRes=arrowResolution,BCType="bias"),"copperEven",axes)
                !disableBot && !disableCurvature && BuildBC_2D(GenerateRing(cuCDimsBot[i][1],cuCDimsBot[i][2],cuCDimsBot[i][3],cuCDimsBot[i][4],layer=i,BCType="curvature"),"copperEven",axes)
                !disableBot && !disableBias && BuildBC_2D(GenerateRing(cuBDimsBot[i][1],cuBDimsBot[i][2],cuBDimsBot[i][3],cuBDimsBot[i][4],layer=i,BCType="bias"),"copperEven",axes)
            else #odd layers
                print("layer", onlyLayer)
                i=onlyLayer
                !disableTop && !disableCurvature && BuildBC_2D(GenerateRing(cuCDims[i][1],cuCDims[i][2],cuCDims[i][3],cuCDims[i][4],layer=i,arrowRes=arrowResolution,BCType="curvature"),"copperOdd",axes)
                !disableTop && !disableBias && BuildBC_2D(GenerateRing(cuBDims[i][1],cuBDims[i][2],cuBDims[i][3],cuBDims[i][4],layer=i,arrowRes=arrowResolution,BCType="bias"),"copperOdd",axes)
                !disableBot && !disableCurvature && BuildBC_2D(GenerateRing(cuCDimsBot[i][1],cuCDimsBot[i][2],cuCDimsBot[i][3],cuCDimsBot[i][4],layer=i,BCType="curvature"),"copperOdd",axes)
                !disableBot && !disableBias && BuildBC_2D(GenerateRing(cuBDimsBot[i][1],cuBDimsBot[i][2],cuBDimsBot[i][3],cuBDimsBot[i][4],layer=i,BCType="bias"),"copperOdd",axes)
            end
        end

    end

    display(quiver!(0,0,quiver=(0,0))) 
    println("")
    println("Step 3: Display plot")   
end =#
 
#Pass in array BC from Generate BC, defaults to full view, can have certain disabled thigns like copper, brass, bias, and curvature, can also pass in array of which layers you want
#=
"rotational Visualize"
function VisualizeBC(BC::Array,rotate=pi;disableBrass=false,disableCopper=false,disableCurvature=false,disableBias=false,
    disableTop=false,disableBot=false,frame=pi/2,fullsize=true, specifiedRings=[]::Array)

    print("This is rotation version")
    #number of rings in BC,
    numRings = length(BC)
    numCuLayers = (numRings - 4) / 2 #number of Copper layers on each side of BC

    #height of BC
    last(BC[1][3]) #BC first layer (bottom), z coordinate, and last entry which is lowest
    last(BC[lastindex(BC)][3]) #BC last layer (top), z coordiante, and last entry which is highest
    height = last(BC[lastindex(BC)][3]) - last(BC[1][3])

    #initializes a camerra and axis settings
    cameraX=40+10*cos(frame)
    cameraY=45-20*cos(frame)
    xlims=(-50,50)
    ylims=(-50,50)

    #initializes plot with varying dimensiosn depending on job
    if(fullsize)
        zlims=(-height/2,height/2)
        display(quiver(0,0,0,quiver=(0,0,0),xlims=xlims,ylims=ylims,zlims=zlims,size=(600,600,10))) 
    else
        display(quiver(0,0,0,quiver=(0,0,0),xlims=xlims,ylims=ylims,size=(600,600,10))) 
    end

    #defines plot camera
    temporary=[0,0,0]
    quiver!(temporary,temporary,temporary,quiver=(temporary,temporary,temporary),camera=(cameraX,cameraY))

    #Displaying rings on plot
    if (specifiedRings == []) #do full view
        print("Total rings: ", numRings ," \nPlotting ring number: \n")
        for layer in 1:numRings
            print(layer, " ")
            BuildBC( BC[layer][1:6] ,BC[layer][7]) #passes in x,y,z,u,v,w for quiver and then BCType for color
        end
    else #do only specifiedRigns view
        numSpecifiedRings = length(specifiedRings)
        print("Total rings: ", numSpecifiedRings ," \nPlotting ring number: \n")
        for layer in 1:numSpecifiedRings
            print(specifiedRings[layer], " ") 
            BuildBC( BC[specifiedRings[layer]][1:6] ,BC[specifiedRings[layer]][7]) #passes in x,y,z,u,v,w for quiver and then BCType for color
        end
    end

    #ensures that whole plot is displayyed after function
    display(quiver!(0,0,0,quiver=(0,0,0),camera = (cameraX,cameraY))) 

    #saving plot to figure
    time = Dates.format(now(),"yyy-mm-dddTHH-MM-SS")    
    filename = "/Users/zirdisyukur/Julia/Research/WithPlots/figures/VisualizeBC_build_"*time*".png"
    println("\nsaved to " * filename)
    savefig(filename)
     
end
=#

#=
"VisualizeBC version where you can see the magnet get built from the ground up"
function VisualizeBC_build(rotate=false,disableBrass=false,disableCopper=false,disableCurvature=false,disableBias=false,disableTop=false,
    disableBot=false,onlyLayer=-1)

    #building layer by layer

    #number of frames for staging
    numFrames=2+2*numberCuLayers
    layersInBC=2+2*numberCuLayers

    #number of frames added for Assembly
    numFrames=numFrames+2+2*numberCuLayers

    anim = @animate for frame in 1:numFrames
        frameNum = frame
        print("frame:", frameNum, "/",numFrames," ")

        #frames
        #1:numberCuLayers is bottom onlyLayer
        #numberCuLayers+1,numberCuLayers+2 are brass
        #numCuLayers+3 to 2*numberCuLayers+2

        #staging portion of animation
        if(1<=frameNum<=numberCuLayers)
            VisualizeBC(disableTop=true,onlyLayer=numberCuLayers-frameNum+1,fullsize=true)
        elseif(frameNum==numberCuLayers+1)
            VisualizeBC(disableTop=true,disableCopper=true,fullsize=true)
        elseif(frameNum==numberCuLayers+2)
            VisualizeBC(disableBot=true,disableCopper=true,fullsize=true)
        elseif(numberCuLayers+2<=frameNum<=2*numberCuLayers+2)
            VisualizeBC(disableBot=true,onlyLayer=frameNum-numberCuLayers-2,fullsize=true)
        end
        
        #assembly portion of animation
        if(1<=frameNum-layersInBC<=numberCuLayers)
            VisualizeBC(upto="copperH_"*string(numberCuLayers-frameNum+layersInBC+1),fullsize=true)
        elseif(frameNum-layersInBC==numberCuLayers+1)
            VisualizeBC(upto="brassH",fullsize=true)
        elseif(frameNum-layersInBC==numberCuLayers+2)
            VisualizeBC(upto="brass",fullsize=true)
        elseif(numberCuLayers+2<=frameNum-layersInBC<=2*numberCuLayers+2)
            VisualizeBC(upto="copper_"*string(frameNum-layersInBC-numberCuLayers-2),fullsize=true)
        end

    end 

    time = Dates.format(now(),"yyy-mm-dddTHH-MM-SS")
    gif(anim,"/Users/zirdisyukur/Julia/Research/WithPlots/figures/VisualizeBC_"*time*".gif", fps=10)
    
end=#