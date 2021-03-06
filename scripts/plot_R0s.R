#Calculate final outbreak sizes
#SV Scarpino
#Feb. 27 2020

###########
#libraries#
###########
library(reticulate)
library(RColorBrewer)
library(lamW)

#########
#Globals#
#########


######
#Data#
######
spread_data <- readRDS("../data/disease_data.rds")

diseases <- paste(spread_data$Disease, spread_data$Location, spread_data$Year, sep = "-")

#######
#Model#
#######
source_python('compute_final_p.py')

Z_mean <- rep(NA, nrow(spread_data))
Z_min <- Z_mean
Z_max <- Z_mean
for(i in 1:nrow(spread_data)){
  Z.mean.i <- solve_for_z(spread_data$R0[i], spread_data$k[i])
  Z_mean[i] <- Z.mean.i
  
  Z.min.i <- solve_for_z(spread_data$R0_min[i], spread_data$k_min[i])
  Z_min[i] <- Z.min.i
  
  Z.max.i <- solve_for_z(spread_data$R0_max[i], spread_data$k_max[i])
  Z_max[i] <- Z.max.i
}

cols <- brewer.pal(n = 9, name = "Blues")
col_val <- round((Z_mean/max(Z_mean, na.rm = TRUE) * 10)-1)
col_val[which(col_val < 1)] <- 1
fill <- cols[col_val]

ord <-rev(c(4, 6, 7, 10, 8, 2,1))
quartz()
par(mar = c(5, 10, 4, 2))
bp <- barplot(Z_mean[ord], names = diseases[ord], col = fill[ord], las = 2, horiz = TRUE, cex.names = 0.8, xlim = c(0, 1), xlab = "Proportion of susceptible individuals infected", main = "")
segments(x0 = Z_min[ord], y0 = bp[,1], x1 = Z_max[ord], y1 = bp[,1])
points(spread_data$`Prop I`[ord], bp[,1], col = "#b2182b", pch = 16, cex = 1.5)
points(1-(1/spread_data$R0[ord]), bp[,1], col = "#bababa", pch = 15, cex = 1.5)
points(lambertW0(-exp(-spread_data$R0[ord])*spread_data$R0[ord])/spread_data$R0[ord]+1, bp[,1], col = "#4d4d4d", pch = 17, cex = 1.5)