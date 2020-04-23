#Pull data set
#SV Scarpino
#Feb. 27 2020

###########
#libraries#
###########
library(googlesheets4)

#########
#Globals#
#########
sheets_auth()

######
#Data#
######
spread_data <- sheets_get(ss = "1W39TY6qMns4EOJ-3C3tvYjvzMye7q2mmGD4Mq-gIhgY") %>%
  read_sheet(sheet = "Sheet1")

saveRDS(spread_data, "../data/disease_data.rds")
