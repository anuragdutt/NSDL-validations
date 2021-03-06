load("/home/nsdl/DATAMART1/client_details_standard_analysis.Rdata")
source("/home/nsdl/LIB/account_age.R")
## load("/home/nsdl/DATAMART1/demo_client_master.Rdata")
## pan.data <- pan.data[1:100000, ]

########################### Non Aggregated
pan.data <- pan.data[!is.na(pan.data$client_id), ]
## pan.data <- pan.data[!duplicated(pan.data$client_id), ]
## save(pan.data, file = "/home/nsdl/DATAMART1/client_details_standard_analysis.Rdata")

## load("/home/nsdl/DATAMART1/demo_client_master.Rdata")
## save(pan.data, file = "/home/nsdl/DATAMART1/demo_client_master.Rdata")

client.type <- as.numeric(table(pan.data$client_type))
names(client.type) <- names(table(pan.data$client_type))
save(client.type,
     file = "/home/nsdl/RESULTS/DEMO_SUMSTATS/client_type_distribution.Rdata")
#########################################################################################
## names(client.type) <- c("Resident", "FI",                                           ##
##                         "FII", "NRI",                                               ##
##                         "Corporate", "Clearing Member",                             ##
##                         "Foreign National", "Mutual Fund",                          ##
##                         "Trust", "Bank", "Qualified Foreign Investor",              ##
##                         "Qualified Foreign Investor", "Foreign Portfolio Investor") ##
#########################################################################################
occupation  <- as.numeric(table(pan.data$occupation))
names(occupation) <- c("Service", "Student",
                       "Housewife", "Landlord",
                       "Business", "Professional",
                       "Agriculture", "Others")
save(occupation,
     file = "/home/nsdl/RESULTS/DEMO_SUMSTATS/occupation_distribution.Rdata")
################################# Only on Non Aggregated accounts
################################ Account opening date
pan.data$account_opening_year <- format(as.Date(pan.data$account_opening_date),
                                        format = "%Y")
opening.year <- as.numeric(table(pan.data$account_opening_year))
names(opening.year) <- 1996:2015
save(opening.year,
     file = "/home/nsdl/RESULTS/DEMO_SUMSTATS/opening_year_distribution.Rdata")
pan.data$account_opening_year_month <- format(as.Date(pan.data$account_opening_date),
                                              format = "%Y-%m")
year.month   <- as.numeric(table(pan.data$account_opening_year_month))
names(year.month) <- format(as.Date(paste0(names(table(pan.data$account_opening_year_month)),
                                           sep = "-01")),
                            format = "%Y-%b")
save(year.month,
     file = "/home/nsdl/RESULTS/DEMO_SUMSTATS/year_month_distribution.Rdata")

pan.data$account_opening_month <- format(as.Date(pan.data$account_opening_date),
                                         format = "%m")
opening.month <- as.numeric(table(pan.data$account_opening_month))
names(opening.month) <- format(as.Date(paste0(sep = "2014-",
                                              names(table(pan.data$account_opening_month)),
                                              sep = "-01")),
                               format = "%b")
save(opening.month,
     file = "/home/nsdl/RESULTS/DEMO_SUMSTATS/opening_month_distribution.Rdata")
################################ Account closing date
account.status <- as.numeric(table(pan.data$account_status)) 
names(account.status) <- c("active", "suspended for all",
                           "suspended for debit", "closed")
save(account.status,
     file = "/home/nsdl/RESULTS/DEMO_SUMSTATS/account_status_distribution.Rdata")

pan.data$account_closing_date <-
    as.Date(as.character(pan.data$account_closing_date),
            format = "%y-%m-%d")
dt.ne      <- pan.data[which(pan.data$account_status == 4), ]
age.closed <- ageClosedAccount(dt.ne)
dt.ex      <- pan.data[which(pan.data$account_status == 1), ]
age.open   <- ageAccount(dt.ex, as.Date(Sys.Date()))

active.accounts <- nrow(dt.ex)
closed.accounts <- nrow(dt.ne)

age.closed$year <- as.numeric(age.closed$age_account,
                              unit = "days")
age.closed$year <- ceiling(age.closed$year/365)
age.closed <- age.closed[!is.na(age.closed$year), ]
age.closed <- age.closed[-which(age.closed$year <= 0), ]

age.open$year <- as.numeric(age.open$age_account,
                              unit = "days")
age.open$year <- ceiling(age.open$year/365)
age.open <- age.open[!is.na(age.open$year), ]
if(length(which(age.open$year <= 0)) > 0) { 
    age.open <- age.open[-which(age.open$year <= 0), ]
}

tenure.cl <- as.numeric(table(age.closed$year))
names(tenure.cl) <- names(table(age.closed$year))
save(tenure.cl,
     file = "/home/nsdl/RESULTS/DEMO_SUMSTATS/active_close_distribution.Rdata")
tenure.op <- as.numeric(table(age.open$year))
names(tenure.op) <- names(table(age.open$year))
save(tenure.op,
     file = "/home/nsdl/RESULTS/DEMO_SUMSTATS/active_open_distribution.Rdata")

############################################ bivariate analysis


open.all <- merge(age.open, pan.data,
                  by = "client_id",
                  all.x = TRUE)
closed.all <- merge(age.closed, pan.data,
                    by = "client_id",
                    all.x = TRUE)

year.client <- as.matrix(table(open.all$account_opening_year, open.all$client_type))
save(year.client,
     file = "/home/nsdl/RESULTS/DEMO_SUMSTATS/clientwise_year_distribution.Rdata")
age.client  <- as.matrix(table(open.all$year, open.all$client_type))
save(age.client,
     file = "/home/nsdl/RESULTS/DEMO_SUMSTATS/clientwise_age_distribution.Rdata")
################################################ district
load("/home/nsdl/CONSTANTS/state_district_mapping.Rdata")

state.data <- state.data[!is.na(state.data$code), ]
colnames(state.data) <- c("district", "district_code", "state")
dat.all    <- rbind(open.all, closed.all)
state.all  <- merge(dat.all, state.data,
                    by ="district_code",
                    all.x = TRUE)
state.dat <- table(state.all$state)
save(state.dat,
     file = "/home/nsdl/RESULTS/DEMO_SUMSTATS/state_distribution.Rdata")
district.dat <- table(state.all$district)
save(district.dat,
     file = "/home/nsdl/RESULTS/DEMO_SUMSTATS/district_distribution.Rdata")

joint.pan2 <- length(which(!is.na(pan.data$pan_2)))
save(joint.pan2,
     file = "/home/nsdl/RESULTS/DEMO_SUMSTATS/joint_pan2_distribution.Rdata")

joint.pan3 <- length(which(!is.na(pan.data$pan_3)))
save(joint.pan3,
     file = "/home/nsdl/RESULTS/DEMO_SUMSTATS/joint_pan3_distribution.Rdata")
joint.pan.both <- length(which(!is.na(pan.data$pan_2) &
                               !is.na(pan.data$pan_3)))
save(joint.pan.both,
     file = "/home/nsdl/RESULTS/DEMO_SUMSTATS/joint_pan_both_distribution.Rdata")




