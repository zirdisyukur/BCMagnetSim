#This visualization test uses plots as opposed to Makie. It is the chosen package or visualization usage because Makie is insufficient.
#This julia code Defines the numerical parameters of the BC coil such as the current running through it, its resolution of simulation, physical constants for calculation
#, dimensions of the BC coil, and prints out the final BC coil statistics that can be computed before B-field simulation.

using Plots: axes
using Base: replace_with_centered_mark
import Plots
using Plots
import Dates
using Dates
gr()

currents2 = (-195, 195, 10, -10, 0, 0, 185) #currents for (MOT, MOTH, Bias, BiasH, Curv, CurvH, ZS in A)
currents = (0, 0, 440, 440, -170, -170, 0)

#initialization
    const nSeg = 50
    const CmpPrcn = 10^4
#constants
    const hbar = 1.054571800*10^-34
    const h = hbar * 2 * pi
    const amu = 1.66051 * 10^-27
    const kB = 1.380648*10^-23
    const c = 2.9979 * 10^8
    const muB = 9.274 * 10^-24
    const μ0 = 4pi*10^-7
    const hbareV = 4.13566766 * 10^-15
    const heV = hbareV * 2pi
    const kBeV = 8.61733034 * 10^-5
    const Na = 6.022 * 10^23
    const eVJ = 1.60218 * 10^-19
    const mLi = 6 * amu
    const ΓLi = 2 * pi * 5.87 * 10^6
    const λLi = 671 *10^-9
    const ρCu = 1.7 *10^-8
    const ρBrass = 9 *10^-8
#currents
    currents = [-195, 195, 10, -10, 0, 0, 185]
    currents = [0, 0, 440, 440, -170, -170, 0]
#zposBC function
    zposBC(layer) = sepBC/2 + tBrassBC + (layer-1)*(tCuBC+tSpacerBC)
#variables dimensions of BC 
    nlayersBC=26
    iangBC = 0.5 * 2.79 * pi/180
    sepBC = 31.012
    tBrassBC = 6.35
    tCuBC = 1.02
    tSpacerBC = 0.25
    HdirBC = 1
    xtScrew = 5
    ytScrew = 5
    ztScrew = 30 #zposBC(nlayersBC) - zposBC(1) 

    #for GenerateRingResolution
    lineRes = 15
    ringWidthRes = 5
    ringHeightRes = 5
    recRes = 3
    recHeightRes = 11
#calculated variables

    #currents for Bias and Curvature coils
    IB = currents[3]
    IBH = currents[4]
    IC = currents[5]
    ICH = currents[6]

    #radii for Bias and Curvature coils
    rinC = 18
    routC = 31
    rinB = 33
    routB = 46.5
    
    #resistances
    RBrassC = ρBrass * (2pi)/(tBrassBC*log(routC/rinC))                                     #resistance of brass curvature coils
    RCuC = ρCu * (2pi)/(10^-3*tCuBC*log(routC/rinC))                                        #resistance of one copper curvature coil
    RspacerC = ρCu * (tSpacerBC*10^-3)/( pi*(routC^2-rinC^2)*10^-6/(10) )                   #resistance of one curvature spacer 
    RBrassB =  ρBrass * (2pi)/(10^-3*tBrassBC*log(routB/rinB))                              #resistance of brass bias coil
    RCuB = ρCu * (2pi)/(10^-3*tCuBC*log(routB/rinB))                                        #resistance of one copper bias coil
    RspacerB = ρCu * (tSpacerBC*10^-3)/(pi*(routB^2-rinB^2)*10^-6/(10))                     #resistance of one bias spacer 
    Rscrew = ρBrass * ( ( zposBC(nlayersBC) - zposBC(1) + 4 )*10^-3 ) / (pi*2.5^2*10^-6)    #resistance of one screw

    RC = Rscrew + RBrassC + nlayersBC * (RCuC + RspacerC)                                   #resistance of entire curvature assembly on one side
    RB = Rscrew + RBrassB + nlayersBC * (RCuB + RspacerB)                                   #resistance of entire bias assembly on one side

    VC = IC * 2 * RC            #voltage drop for both curvature coils
    VB = IB * 2 * RB            #voltage drop for both bias coils
    PC = IC^2 * 2 * RC          #power dissipated in both curvature coils
    PB = IB^2 * 2 * RB          #power dissipated in both curvature coils

    LC = μ0 / 4pi * (1+nlayersBC)^2 * rinC * 0.001 * 30         #self inductance of one side of curvature coils
    LB = μ0 / 4pi * (1+nlayersBC)^2 * rinB * 0.001 * 30         #self inductance of one side of bias coils

    τC = LC / RC
    τB = LB / RB

    lenBC = 2 * (zposBC(nlayersBC) - zposBC(1)) * 0.001         #length of water tube in m

    ReBC = ( 6 * 10^-7 * (2 * 10 * tSpacerBC)/(10+tSpacerBC) * 10^-3 )  /  (8.9 * 10^-7 * (10*tSpacerBC) * 10^-6)       #reynolds number for cooling water

    flowBC = 3.8 * 10^-3 / 60 #flow rate in gpm --> m^3/s #THERE IS ANOTHER DEFINITION OF THIS COMMENTED OUT IN MATHEMATICA VERSION, ASK PROF

    dTC = PC / (998 * flowBC * 4186)       #change in water temperature flowing through curvature coils
    dTB = PB / (998 * flowBC * 4186)       #change in water temperature flowing through bias coils

#Print summary stats

    R,G,B=255,0,0
    reportPrec = 9

    #comments are whether the number agree with mathematica simulation values
    println("Summary stats: Curvature")
    println("R_coil / Ω: " * string(round(RC,digits=reportPrec))) #good
    println("L_coil / H: " * string(round(LC,digits=reportPrec))) #good
    println("τ / s: " * string(round(τC,digits=reportPrec))) #good
    println("I / A: " * string(round(IC,digits=reportPrec))) #good
    println("V_tot / V: " * string(round(VC,digits=reportPrec))) #good
    println("P_tot / W: " * string(round(PC,digits=reportPrec))) #good
    println("Re: " * string(round(ReBC,digits=reportPrec))) #good
    println("dV/dt / gpm: " * string(round(flowBC / 0.00006309,digits=reportPrec))) #good
    println("dV/dt / m^3/s: " * string(round(flowBC,digits=reportPrec))) #good
    println("dV/dt / l/m: " * string(round(flowBC * 60 * 1000,digits=reportPrec))) #good
    println("ΔT / K: " * string(round(dTC,digits=reportPrec))) #good
    println("l / m: " * string(round(lenBC,digits=reportPrec))) #good

    println()


    println("Summary stats: Bias")
    println("R_coil / Ω: " * string(round(RB,digits=reportPrec))) #good
    println("L_coil / H: " * string(round(LB,digits=reportPrec))) #good
    println("τ / s: " * string(round(τB,digits=reportPrec))) #good
    println("I / A: " * string(round(IB,digits=reportPrec))) #good
    println("V_tot / V: " * string(round(VB,digits=reportPrec))) #good
    println("P_tot / W: " * string(round(PB,digits=reportPrec))) #good
    println("Re: " * string(round(ReBC,digits=reportPrec))) #good
    println("dV/dt / gpm: " * string(round(flowBC / 0.00006309,digits=reportPrec))) #good
    println("dV/dt / m^3/s: " * string(round(flowBC,digits=reportPrec))) #good
    println("dV/dt / l/m: " * string(round(flowBC * 60 * 1000,digits=reportPrec))) #good 
    println("ΔT / K: " * string(round(dTB,digits=reportPrec))) #good
    println("l / m: " * string(round(lenBC,digits=reportPrec))) #good