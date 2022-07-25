
def outsideBox(pos, lowerx, upperx, lowery, uppery): #Function to determine if an ant's tentative new position will take it outside the bounds of the simulation arena
    if pos[0] < lowerx or pos[0] >= upperx or pos[1] < lowery or pos[1] >= uppery:
        return True
    else: return False

def antDistance(ant1, ant2): #Function to calculate distance between the centers of two ants
    distance = np.sqrt((ant2[1]-ant1[1])**2 + (ant2[0]-ant1[0])**2)
    return distance

def proximityAlert(targetAnt, allAnts): #Function to detect if two ants are overlapping in space 
    for a in range(len(allAnts)):
        if antDistance(targetAnt, allAnts[a].position)<1:
            return a
        
import numpy as np
class Ant:
    def __init__(self,  ID, isAwake, A, position, header, ticker, pphase, sector):
        self.ID = ID # The ID of an ant
        self.isAwake = isAwake #A Boolean variable indicating whether an ant is active or inactive 
        self.position = position # the coordinates of an ant in the simulation arena. 
        self.header = header #The heading or an ant 
        self.ticker = ticker #Timer each ant uses to make sure it remains active for A time steps
        self.A = A #The parameter A, which is the number of time steps that an ant remains in the active state   
        self.pphase = pphase #The phase of an ant 
        self.sector = sector #The sector that an ant is currently in 
        
        
            
    def checkSector(self, partGrid, bp, countingPartitions): #Function to find what sector an ant is currently in (used for calculating the MLD metric). 
        for m in range(countingPartitions):
            if self.position[0] <= partGrid[m][0] + bp and self.position[0] >= partGrid[m][0] and self.position[1] <= partGrid[m][2] + bp and self.position[1] >= partGrid[m][2]:
                self.sector = m
            
    def moveAnt(self, gridSize, antList): #The rules for moving an ant (these are run each time step of the simulation), and noting if it touches another ant. This prevents two ants from overlapping, which would be when their centers are less than 1 unit apart.  
        booplist = []
        self.pphase += 1 #All ants advance their phase by 1 degree each time step of the simulation
        if self.isAwake == 1: #For awake ants
            
            oldLoc = self.position
            newLoc = np.asarray(oldLoc)+np.asarray([np.cos(self.header),np.sin(self.header)]) #possible new location
            
            a = 0
            
            bonk = proximityAlert(newLoc, antList)
            while outsideBox(newLoc, 0, gridSize, 0, gridSize) == True or bonk != None :
                if a == 60: #if the ant gets stuck and there is no open location for it to move.
                    newLoc = oldLoc
                    print('SAD')
                    break 
                elif outsideBox(newLoc, 0, gridSize, 0, gridSize) == True:  #checks if outside arena, resets direction to prevent leaving the bounds of the arena
                    self.header = np.random.rand()*2*np.pi
                    #print(self.header)
                    newLoc = np.asarray(self.position)+np.asarray([np.cos(self.header),np.sin(self.header)])
                else:
                    booplist.append(bonk) #ant moves to a new location that is unoccupied by another ant 
                    
                    oldheader = self.header
                    self.header = oldheader+(np.random.rand()-0.5)*np.pi/2
                    
                    newLoc = np.asarray(self.position)+np.asarray([np.cos(self.header),np.sin(self.header)])
                    bonk = proximityAlert(newLoc, antList)
                    
                    
                    
                    a += 1
                
            
            
                
            self.position = newLoc  #Update ant's location
            oldheader = self.header
            self.header = oldheader+((np.pi/2)*(np.random.random()-0.5))
            self.ticker += 1
            if self.ticker > self.A: #If the ant has been awake for A time steps, this makes it sleep
                self.isAwake = 0
                self.ticker = 0

                
            return []

        else: #This wakes up individual inactive ants according to their internal phases
            booplist = []
            if self.pphase % 360 > 350:
                self.isAwake = 1
                self.ticker = 0
        return booplist
        
