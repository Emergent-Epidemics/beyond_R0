#Calculate final outbreak sizes
#SV Scarpino
#Feb. 27 2020

###########
#libraries#
###########
library(reticulate)
library(googlesheets4)
library(RColorBrewer)
library(lamW)

#########
#Globals#
#########
sheets_auth()

######
#Data#
######
spread_data <- sheets_get(ss = "1W39TY6qMns4EOJ-3C3tvYjvzMye7q2mmGD4Mq-gIhgY") %>%
  read_sheet(sheet = "Sheet1")

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
points(((lambertW0(-exp(-spread_data$R0[ord]))*spread_data$R0[ord])+spread_data$R0[ord])/spread_data$R0[ord], bp[,1], col = "#4d4d4d", pch = 17, cex = 1.5)

R0s <- seq(1, 4, length.out = 1000)
plot(R0s, 1-(1/R0s), col = "red", type = "l", ylim = c(0,1))
points(R0s, 1-exp(-R0s), col = "blue", type = "l")
points(R0s, ((lambertW0(-exp(-R0s))*R0s)+R0s)/R0s, col = "green", type = "l")
