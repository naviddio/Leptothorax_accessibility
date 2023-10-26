####Written by Carmen Lee & Grant Navid Doering for Python3 ######

import time
import numpy as np
import winsound #(comment out if running on non-Windows computers)
time1 = time.process_time()
for niteration in range(1): # Number of simulations to run
    for Rd in [0]: # The level of phase synchrony between the ants (i.e., Kurmamoto order parameter) 
        ####################Model parameters###############
        A = 100     #(Active time)
        stepCount = 4000 #Total time steps of simulation
        numberOfAnts = 120 #Number of ants
        gridSize = 30 #gridSizexgridSize arena
        countingPartitions = 16 # Number of grid sectors to use in calculating Maximum local density 


        PlotInterval = 150 # set the number of timesteps in the PlotInterval variable to specify how often to save a plot of the simulation arena

        #############Importing required packages###############
        from matplotlib import cm
        import matplotlib.pyplot as plt
        import numpy as np
        from classAnt import Ant
        import os
        import scipy as sp

        directory = os.getcwd()
        newDir = directory + "//A_" + str(A) + "_" + str(niteration) + '_Rd%i'%(Rd*10) + "_gridsize_" + str(gridSize) + "_population_" + str(numberOfAnts)
        try:
            # Create target Directory to save simulation output
            os.mkdir(newDir)
        except FileExistsError:
            pass

        #######################################################
        #functions:

        def gridPartitions(numberOfPartitions): #Funtion to define the various sector boundaries in the simulation arena
            bp = (gridSize)/numberOfPartitions
            lists = []
            for k in range(numberOfPartitions):
                for i in range(numberOfPartitions):
                    lists.append([bp*k,bp*(k+1),bp*i,bp*(i+1)])
            return lists

        def antDistance(ant1, ant2): #Function to calculate distance between the centers of two ants
            distance = np.sqrt((ant2[1]-ant1[1])**2 + (ant2[0]-ant1[0])**2)
            return distance

        def proximityAlert(targetAnt, allAnts): #Function to detect if two ants are overlapping in space 
            for a in allAnts:
                if antDistance(targetAnt, a.position)<1:
                    return True

        def stateToColour(state): #for plotting inactive and active ants in different colors (active ants are plotted in black, and inactive ants are plotted in red)
            if state == 1:
                return 'k'
            else:
                return 'r'


        ############################################################           
                    
        ##initiating ants ######################
        partGrid = gridPartitions(int(np.sqrt(countingPartitions))) #Define the various sector boundaries in the simulation arena
        bp = (gridSize)/(int(np.sqrt(countingPartitions)))
        origx = []
        origy = []
        antList = []

        #Initialize the phase distribution of the simulated ants so that they conform to the specified order parameter
        Rorder = 2
        spread = 360
        pphase = np.random.randint(0, spread, size=numberOfAnts)
        while not Rd-0.01 <= Rorder <= Rd+0.01:
            for spread in np.arange(start=10, stop=360, step=10):
                pphase = np.random.randint(0, spread, size=numberOfAnts)
                pphaser = np.deg2rad(pphase)
                Rorder = abs(np.sum(np.exp(np.sqrt(-1+0j)*pphaser))/len(pphaser))
                if Rd-0.01 <= Rorder <= Rd+0.01:
                    break

            
            
        for n in range(numberOfAnts):
            Antn = Ant(n,\
                           np.random.randint(0, 1),\
                           A,\
                           [np.random.random()*(gridSize),np.random.random()*(gridSize)],\
                           (np.random.random())*2*np.pi,\
                           np.random.randint(0, 100),\
                           pphase[n], sector = 0)
                           
            for i in range(n): # this starts the sim with no ants overlapping
                if antDistance(Antn.position, antList[i].position) < 1:
                    newLoc = [np.random.random()*(gridSize),np.random.random()*(gridSize)]
                    while proximityAlert(newLoc, antList) == True:
                        newLoc = [np.random.random()*(gridSize),np.random.random()*(gridSize)]
                        
                    Antn.position = newLoc 

            origx.append(Antn.position[0])
            origy.append(Antn.position[1])

            Antn.checkSector(partGrid, bp, countingPartitions)
            antList.append(Antn)


        ##########################Running the sim######################

        #we want to count: number of active ants vs time, and the maximum local density vs time
        k = 0
        activeAnts = []
        pactiveAnts = []
        maxjamming = []
        sector_populations_active = []
        sector_populations_inactive = []
        while k < stepCount:
            print (k)
            if k% PlotInterval == 0:
                fig2, axes = plt.subplots(figsize = (6,6))
                axes.set_xlim(-2, gridSize+2)
                axes.set_ylim(-2, gridSize+2)
            
            active = 0
            pactive = 0
            antDensityInactive = [0 for _ in range(countingPartitions)]
            antDensityActive = [0 for _ in range(countingPartitions)]
            
            for b in range(len(antList)):
                
                ant = antList[b]
                if ant.isAwake == 0:
                    ant.checkSector(partGrid, bp, countingPartitions)
                    antDensityInactive[ant.sector]+=1
                
                if ant.isAwake ==1:
                    ant.checkSector(partGrid, bp, countingPartitions)
                    antDensityActive[ant.sector]+=1

                ant.moveAnt(gridSize, antList)
                
                
                active += ant.isAwake
                
                
                
                if k%PlotInterval ==0:
                    state = stateToColour(ant.isAwake)
                    axes.plot(ant.position[0], ant.position[1], marker = 'o', markersize = 10, color = state)            
            
            
            pactive = active/numberOfAnts #Compute the proportion of active ants
            activeAnts.append(active) #Record the proportion of active ants at each time step
            pactiveAnts.append(pactive) #Record the proportion of active ants at each time step
            maxjamming.append(max(antDensityInactive)) #Record maximum local density at each time step
            sector_populations_active.append(antDensityActive) #Record the number of active ants in each sector at each time step
            sector_populations_inactive.append(antDensityInactive) #Record the number of inactive ants in each sector at each time step

                
                
            if k%PlotInterval ==0:   
               plt.savefig(newDir+'/%i.png'%(k))
               plt.close()
            
            
            k +=1

        fig = plt.figure()
        ax = fig.add_subplot(111)
        ax2 = ax.twinx()
        #ax.plot(range(len(activeAnts)), activeAnts, 'k-', label = 'Active ants')
        ax.plot(range(len(pactiveAnts)), pactiveAnts, 'k-', label = 'Proportion active')
        ax.set_ylim(0, 1)
        
        ax2.plot(range(len(maxjamming)), maxjamming, 'r', label ='Inaccessibility  (count)')

        ax.set(xlabel = 'time step', ylabel = 'Prop. of active ants')
        ax2.set(ylabel = 'MLD')
        plt.legend()
        #save simulation data and optional arena figures
        plt.savefig(newDir+'/summary.png')
        np.savetxt(newDir + '/totalActiveAnts.csv', activeAnts)
        np.savetxt(newDir + '/MLD.csv', maxjamming)
        np.savetxt(newDir + '/sector_populations_active.csv', sector_populations_active)
        np.savetxt(newDir + '/sector_populations_inactive.csv', sector_populations_inactive)
        #plt.show()

    time2 = time.process_time()
    print(time2-time1) #print the total time taken to run the simulations

#play a tone to indicate that the simulation has finished (comment out if running on non-Windows computers)
frequency = 440  
duration = 500  
winsound.Beep(frequency, duration)
