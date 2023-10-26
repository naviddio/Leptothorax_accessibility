###### Import data 
library(rio)

RN1<-read.csv("activity_MLD_RN1.csv", header=T)
RN2<-read.csv("activity_MLD_RN2.csv", header=T)
RN3<-read.csv("activity_MLD_RN3.csv", header=T)
RN5<-read.csv("activity_MLD_RN5.csv", header=T)
RN6<-read.csv("activity_MLD_RN6.csv", header=T)
RN7<-read.csv("activity_MLD_RN7.csv", header=T)
RN8<-read.csv("activity_MLD_RN8.csv", header=T)
RN10<-read.csv("activity_MLD_RN10.csv", header=T)
RN11<-read.csv("activity_MLD_RN11.csv", header=T)
RN12<-read.csv("activity_MLD_RN12.csv", header=T)
RN13<-read.csv("activity_MLD_RN13.csv", header=T)
RN14<-read.csv("activity_MLD_RN14.csv", header=T)
RN17<-read.csv("activity_MLD_RN17.csv", header=T)
RN18<-read.csv("activity_MLD_RN18.csv", header=T)
RN19<-read.csv("activity_MLD_RN19.csv", header=T)
RN20<-read.csv("activity_MLD_RN20.csv", header=T)
RN21<-read.csv("activity_MLD_RN21.csv", header=T)
RN22<-read.csv("activity_MLD_RN22.csv", header=T)
RN23<-read.csv("activity_MLD_RN23.csv", header=T)


RN19_lf <- as.data.frame(t(read.csv("larval_tending_smoothed.csv", header=F)))

RN23_of <- read.csv("Optical_flow_in_nest_RN23.csv", header=T)

RN22_of <- import_list("Optical_flow_in_nest_RN22.xls")

all_colonies_of <- import_list("Optical_flow_in_nest_all_colonies_1min.xls")

table_s1<-read.csv("Table_S1.csv", header=T)

all_colonies_bpc<-import_list("Optical_flow_brood_pile_coverage.xls")

all_colonies_bpa<-import_list("Optical_flow_brood_pile_barrier.xls")

simulation1 <- read.csv("MLD_activity_simulation_R0.5_1.csv", header=T)

simulation2 <- read.csv("MLD_activity_simulation_R0.5_2.csv", header=T)

simulation3 <- read.csv("MLD_activity_simulation_R0.csv", header=T)


###### Calculate mean and standard deviation of colonies' period of oscillation

L_retractus<-subset(table_s1, Species == "L. retractus")
L_canadensis<-subset(table_s1, Species == "L. AF-can")

mean(L_retractus$Dominant.Period..min.)
sd(L_retractus$Dominant.Period..min.)

mean(L_canadensis$Dominant.Period..min.)
sd(L_canadensis$Dominant.Period..min.)

###### Test if cycles of larval tending are synchronized with colony locomotor activity 

ccor<-ccf(RN19$activity[1:360],RN19_lf$V1, lag.max = 1000) # Cross-correlation is maximized at zero lag. 
cor.test(RN19$activity[1:360],RN19_lf$V1)


###### Test if inactive ants block active ants

wilcox.test(RN23_of$Inactive_ants,RN23_of$Random_locations) # 2.8-min segment from colony RN23

wt_p<-NULL # 20, 1-min segments from colony RN22
wt_w<-NULL
for (i in 1:20){
  
  segment_flow<-RN22_of[[i]]
  
  wt<-wilcox.test(segment_flow$Inactive_ants,segment_flow$Random_locations)
  
  wt_p[i]<-wt$p.value
  wt_w[i]<-wt$statistic
  
}

wta_p<-NULL # 1-min segments from all 19 colonies
wta_w<-NULL
diffm<-NULL
for (i in 1:19){
  
  segment_flow<-all_colonies_of[[i]]
  
  wta<-wilcox.test(segment_flow$Inactive_ants,segment_flow$Random_locations)
  
  wta_p[i]<-wta$p.value
  wta_w[i]<-wta$statistic
  
  diffm[i]<-mean(segment_flow$Inactive_ants)-mean(segment_flow$Random_locations)
  
}

bpc_p<-NULL # Brood pile coverage during 30-second intervals from all 19 colonies (1 chosen cycle per colony)
bpc_r<-NULL
for (i in 1:19){
  
  segment_flow<-all_colonies_bpc[[i]]
  
  bpc<-cor.test(segment_flow$No_of_inactive_ants,segment_flow$Brood_coverage)
  
  bpc_p[i]<-bpc$p.value
  bpc_r[i]<-bpc$estimate
  
}

bpa_p<-NULL # Activity associated with inactive ants vs. adjacent locations during 30-second intervals from all 19 colonies (1 chosen cycle per colony)
bpa_v<-NULL
for (i in 1:19){
  
  segment_flow<-all_colonies_bpa[[i]]
  
  bpa<-wilcox.test(segment_flow$Inactive_ants, segment_flow$Adjacent_locations, paired = TRUE, alternative = "two.sided")
  
  bpa_p[i]<-bpa$p.value
  bpa_v[i]<-bpa$statistic
  
}

###### Test if the spatial accessibility metric (MLD) is correlated with collective activity in the empirical data

cor.test(RN1$MLD,RN1$activity)
cor.test(RN2$MLD,RN2$activity)
cor.test(RN3$MLD,RN3$activity)
cor.test(RN5$MLD,RN5$activity)
cor.test(RN6$MLD,RN6$activity)
cor.test(RN7$MLD,RN7$activity)
cor.test(RN8$MLD,RN8$activity)
cor.test(RN10$MLD,RN10$activity)
cor.test(RN11$MLD,RN11$activity)
cor.test(RN12$MLD,RN12$activity)
cor.test(RN13$MLD,RN13$activity)
cor.test(RN14$MLD,RN14$activity)
cor.test(RN17$MLD,RN17$activity)
cor.test(RN18$MLD,RN18$activity)
cor.test(RN19$MLD,RN19$activity)
cor.test(RN20$MLD,RN20$activity)
cor.test(RN21$MLD,RN21$activity)
cor.test(RN22$MLD,RN22$activity)
cor.test(RN23$MLD,RN23$activity)

###### Test if the slope of the accessibility metric (MLD) vs. collective activity is correlated with colony size

cor.test(table_s1$No..of.adults,table_s1$Pearson.r..MLD.vs..Activity)


###### Test if the spatial accessibility metric (MLD) is correlated with collective activity in the model simulations

cor.test(simulation1$Total_active_ants,simulation1$MLD)
cor.test(simulation2$Total_active_ants,simulation2$MLD)
cor.test(simulation3$Total_active_ants,simulation3$MLD)
