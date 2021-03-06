setwd("~/Desktop/BUAN 6356/Project")

####################################################################################################

library(caret)
library(varhandle)
library(data.table)
library(rpart)
library(randomForest)
library(ROCR)
library(pROC)

####################################################################################################

# Pull in data
flights_df <- read.delim("flights_with_weather_trimmed.txt", header = TRUE, sep = "\t")
flights_df$DOT_late_flag = as.factor(flights_df$DOT_late_flag)
flights_df$late_flag = as.factor(flights_df$late_flag)

# Drop unnecessary columns
drop_columns <- c('arrvariance', 'late_flag', 'blockvariance')
flights_df <- flights_df[ , !(names(flights_df) %in% drop_columns)]

# Convert to factors
factor_columns <- c('DoW', 'marketingairline', 'origin', 'dest', 'originskycondition1', 'destskycondition1')

# Conver to numeric
flights_df["timeongatevariance"] <- unfactor(flights_df["timeongatevariance"])
flights_df ["timeongatevariance"] <- as.numeric(flights_df["timeongatevariance"])
# flights_df['timeongatevariance'] <- as.numeric(unlist(flights_df['timeongatevariance']))
numeric_columns <- c('timeongatevariance')
flights_df[numeric_columns] <- as.numeric(unlist(flights_df[numeric_columns]))

# Fill n/a in column
flights_df[is.na(flights_df$timeongatevariance), "timeongatevariance"] <- 0

####################################################################################################

# Manual dealing with categorical data
# One-hot encoding

flights_cat_df <- setDF(one_hot(as.data.table(flights_df[,factor_columns])))

# Drop categorical columns from original dataframe
trsf <- flights_df[ , !(names(flights_df) %in% factor_columns)]
trsf <- cbind(flights_cat_df, trsf)

####################################################################################################

# Partition data
set.seed(12345)
train.index <- sample(c(1:dim(trsf)[1]), dim(trsf)[1]*0.6)
#train.index <- createDataPartition(new_df, times = 1, p = 0.75, list=F)
#train.index <- createDataPartition(paste(sample_df$marketingairline,sample_df$origin, sample_df$dest, sample_df$originskycondition1, sample_df$destskycondition1))$Resample
train.df <- trsf[train.index, ]
valid.df <- trsf[-train.index, ]

####################################################################################################

# Tree
class.tree <- rpart(DOT_late_flag ~ ., data = train.df, control = rpart.control(maxdepth = 2), method = "class")

## Random Forest
rf <- randomForest(DOT_late_flag ~ ., data = train.df, ntree = 500, mtry = 4, nodesize = 5, importance = TRUE)  

## Variable importance plot
varImpPlot(rf, type = 1)

####################################################################################################

# Make predictions
rf.pred <- predict(rf, valid.df)
rf.prob <-predict(rf, valid.df, type="prob")[,2]

# Summarize accuracy
table(rf.pred, valid.df$DOT_late_flag)

# Make confusion matrix
confusionMatrix(rf.pred, as.factor(valid.df$DOT_late_flag))
cm = as.matrix(table(Actual = valid.df$DOT_late_flag, Predicted = rf.pred)) # create the confusion matrix

n = sum(cm) # number of instances
nc = nrow(cm) # number of classes
diag = diag(cm) # number of correctly classified instances per class 
rowsums = apply(cm, 1, sum) # number of instances per class
colsums = apply(cm, 2, sum) # number of predictions per class
p = rowsums / n # distribution of instances over the actual classes
q = colsums / n # distribution of instances over the predicted classes

accuracy = sum(diag) / n # 99.4%

precision = diag / colsums # Specificity
recall = diag / rowsums # Sensitivity
f1 = 2 * precision * recall / (precision + recall)

data.frame(precision, recall, f1)

####################################################################################################
# Colorful ROC curve

ROCRpred = prediction(rf.prob, valid.df$DOT_late_flag)

# Performance function
ROCRperf = performance(ROCRpred, "tpr", "fpr")
# Plot ROC curve
plot(ROCRperf)
# Add colors
plot(ROCRperf, colorize=TRUE)
# Add threshold labels
# plot(ROCRperf, colorize=TRUE, print.cutoffs.at=seq(0,1,by=0.1), text.adj=c(-0.2,1.7))

auc <- performance(ROCRpred,"auc")
auc <- unlist(slot(auc, "y.values")) 
auc # 0.9431559

####################################################################################################

# ROC Curve

#sensitivity <- sensitivity(factor(round(probabilities)),factor(valid.df$DOT_late_flag))
#specificity <- specificity(factor(round(probabilities)),factor(valid.df$DOT_late_flag))
flights_roc<-roc(response=rf.pred, predictor=as.numeric(valid.df$DOT_late_flag)-1 ,ci=FALSE, plot=TRUE, auc.polygon=FALSE, max.auc.polygon=TRUE, grid=FALSE, print.auc=TRUE, show.thres=TRUE)
# plot(flights_roc, col="red", lwd=3, main="ROC Curve")

# IF CI = TRUE
#flights.ci <- ci.se(flights_roc)
#plot(flights.ci, type='shape')
#plot(flights.ci, type='bars')

####################################################################################################
# Save/Read Model
# saveRDS(rf, "./random_forest_model.rds")
# rf <- readRDS("./random_forest_model.rds")






