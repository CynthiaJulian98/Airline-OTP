setwd("~/Desktop/BUAN 6356/Project")
flights_df <- read.delim("flights_with_weather_trimmed.txt", header = TRUE, sep = "\t")
flights_df$DOT_late_flag = as.factor(flights_df$DOT_late_flag)
flights_df$late_flag = as.factor(flights_df$late_flag)
# View(flights_df)

library(dplyr)
library(sqldf)
library(ggplot2)
library(corrplot)

####################################################################################################
####################################################################################################
# What does OTP (% of on-time flights) look like throughout the day? 
# Group by marketing airline

chart_df <-
sqldf("SELECT 
      marketingairline
      , 100-SUM(100.0*DOT_late_flag)/COUNT(100.0*DOT_late_flag) AS OTP
      , hour_out from flights_df 
      GROUP BY marketingairline, hour_out 
      ORDER BY marketingairline, hour_out") # Use sql syntax to munge dataframe. Nice!

ggplot(data=chart_df, aes(x=hour_out, y=OTP, group=marketingairline)) +
  geom_line(aes(color=marketingairline))+
  geom_point(aes(color=marketingairline))+
  ggtitle("Airline OTP Throughout the Day")+
  theme(plot.title = element_text(hjust = 0.5))+
  xlab("Hour of Departure")+
  ylab("On-Time Performance")

####################################################################################################
# What does OTP (% of on-time flights) look like by day of week? 
# Group by marketing airline

chart_df <-
  sqldf("SELECT 
      marketingairline
      , 100-SUM(100.0*DOT_late_flag)/COUNT(100.0*DOT_late_flag) AS OTP
      , DoW 
      FROM flights_df 
      GROUP BY marketingairline, DoW 
      ORDER BY marketingairline, DoW") # Use sql syntax to munge dataframe. Nice!

ggplot(data=chart_df, aes(x=DoW, y=OTP, group=marketingairline)) +
  geom_line(aes(color=marketingairline))+
  geom_point(aes(color=marketingairline))+
  ggtitle("Airline OTP Throughout the Week")+
  theme(plot.title = element_text(hjust = 0.5))+
  xlab("Day of Week")+
  ylab("On-Time Performance")

####################################################################################################
####################################################################################################
# Create boxplots of arrival-time-delta (actual - scheduled) group by airline
# just late

chart_df <- flights_df[c('marketingairline', 'arrvariance', 'late_flag')]

ggplot(data=chart_df[chart_df$arrvariance < 60,], aes(x=marketingairline, y=arrvariance)) + 
  geom_boxplot()+
  ggtitle("Airline Arrival Variance")+
  theme(plot.title = element_text(hjust = 0.5))+
  xlab("Airline")+
  ylab("Variance")

####################################################################################################
# Create boxplots of arrival-time-delta (actual - scheduled) group by airline
# just late

chart_df <- flights_df[c('marketingairline', 'arrvariance', 'late_flag')]

ggplot(data=chart_df[chart_df$arrvariance < 60,], aes(x=marketingairline, y=arrvariance, fill=late_flag)) + 
  geom_boxplot()+
  ggtitle("Airline Arrival Variance")+
  theme(plot.title = element_text(hjust = 0.5))+
  xlab("Airline")+
  ylab("Variance")

####################################################################################################
# Create boxplots of arrival-time-delta (actual - scheduled) group by airline 
# DOT late

chart_df <- flights_df[c('marketingairline', 'arrvariance', 'DOT_late_flag')]

ggplot(data=chart_df[chart_df$arrvariance < 60,], aes(x=marketingairline, y=arrvariance, fill=DOT_late_flag)) + 
  geom_boxplot()+
  ggtitle("Airline Arrival Variance")+
  theme(plot.title = element_text(hjust = 0.5))+
  xlab("Airline")+
  ylab("Variance")


####################################################################################################
####################################################################################################

market_df <- sqldf("SELECT CASE WHEN origin < dest THEN origin||'-'||dest ELSE dest||'-'||origin END AS market FROM flights_df")
chart_df <- cbind(flights_df, market_df)
chart_df <- sqldf("SELECT 
      100-SUM(100.0*DOT_late_flag)/COUNT(100.0*DOT_late_flag) AS OTP
      , market from chart_df 
      GROUP BY market 
      ORDER BY market")
View(chart_df)

####################################################################################################
####################################################################################################
# What does OTP look like grouped by weather category (broken down by airline)? 

chart_df <- sqldf("SELECT 
      ROUND(100-SUM(100.0*DOT_late_flag)/COUNT(100.0*DOT_late_flag), 1) AS OTP
      , marketingairline
      , originskycondition1 
      from flights_df 
      GROUP BY originskycondition1")
chart_df <- chart_df[order(-chart_df$OTP),]
View(chart_df)

ggplot(data=chart_df, aes(x=reorder(originskycondition1, -OTP), y=OTP)) +
  geom_bar(stat="identity", fill="steelblue")+
  geom_text(aes(label=OTP), vjust=1.6, color="white", size=3.5)+
  ggtitle("On-Time Performance by Weather Origin Condition")+
  theme(plot.title = element_text(hjust = 0.5))+
  xlab("Sky Condition")+
  ylab("OTP")+
  ylim(0,100)

####################################################################################################
####################################################################################################
# Does windspeed correlate with OTP?

chart_df <- flights_df[c('marketingairline', 'originwindspeed', 'destwindspeed' ,'DOT_late_flag')]

ggplot(data=chart_df, aes(x=marketingairline, y=originwindspeed, fill=DOT_late_flag)) + 
  geom_boxplot()+
  ggtitle("Blah")+
  theme(plot.title = element_text(hjust = 0.5))+
  xlab("Airline")+
  ylab("Origin Wind Speed (knotts)")

ggplot(data=chart_df, aes(x=marketingairline, y=destwindspeed, fill=DOT_late_flag)) + 
  geom_boxplot()+
  ggtitle("Destination Station Wind Speed Effects on On-Time Performance")+
  theme(plot.title = element_text(hjust = 0.5))+
  xlab("Airline")+
  ylab("Dest. Wind Speed (knotts)")

####################################################################################################
####################################################################################################

chart_df <- select_if(flights_df, is.numeric)

M <- cor(chart_df)
# corrplot(M, method="color")
corrplot(M, diag = FALSE, order = "FPC",
         tl.pos = "td", tl.cex = 0.5, method = "color", type = "upper", addgrid.col="grey",
         title="Correlation Plot for Airline Data", mar=c(0,0,1,0))
