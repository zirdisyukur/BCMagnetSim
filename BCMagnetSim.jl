#This is the master file to run BC Magnet Sim simulations
#First compile: MagnetSim.jl, functions.kl, radFld.jl

BC, Spacers, Screws, allObj = BCgroup();
BBC=GenerateBBC(plotWidth=20,step=10); #Generates BC and then calculates the B field it produces
Stats=BCStats(); #Generates same BC and then calculates the gradient and curvature of the B-field at (0,0,0)
PlotBBC(BBC,Stats); #Plots the information calculated above