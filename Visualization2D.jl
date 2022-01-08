"Similar function to above but limitting to 2 dimensional view"

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
end

#Issues, 
#arrow head size doesn't change, jarring in 2D view
#add upto function
