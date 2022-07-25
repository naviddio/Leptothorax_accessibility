RN19<-read.csv("activity_MLD_RN19.csv", header=T)
RN22<-read.csv("activity_MLD_RN22.csv", header=T)
RN23<-read.csv("activity_MLD_RN23.csv", header=T)
RN6<-read.csv("activity_MLD_RN6.csv", header=T)
RN19_lf <- as.data.frame(t(read.csv("larval_tending_smoothed.csv", header=F)))


###### Test if cycles of larval tending are synchronized with colony locomotor activity 

ccor<-ccf(RN19$activity[1:360],RN19_lf$V1, lag.max = 1000) # Cross-correlation is maximized at zero lag. 
cor.test(RN19$activity[1:360],RN19_lf$V1)


###### Test if inactive ants block active ants

dat <- read.csv("Optical_flow_in_nest.csv", header=T)
wilcox.test(dat$Inactive_ants,dat$Random_locations)


###### Test if the spatial accessibility metric (MLD) is correlated with collective activity in the empirical data

cor.test(RN22$MLD,RN22$activity)
cor.test(RN23$MLD,RN23$activity)
cor.test(RN19$MLD,RN19$activity)
cor.test(RN6$MLD,RN6$activity)

###### Test if the spatial accessibility metric (MLD) is correlated with collective activity in the model simulation

simulation <- read.csv("MLD_activity_simulation.csv", header=T)

cor.test(simulation$Total_active_ants,simulation$MLD)
