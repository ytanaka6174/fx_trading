#set working directory
path <- "C:/Users/Yoshizo/Desktop/fx_trading"
setwd(path)

#load libraries
library(caret)
library(data.table)
library(xgboost)
library(mlr)
library(cmaes)


#load data
filename = "fx_shift"
filepath = paste0("data/", filename, ".csv")
raw_data <- as.data.frame(read.csv(paste0("data/", filename, ".csv")))

#number of features
feature_num <- ncol(raw_data) - 1 

#convert columns to numeric except signal which should be factor or integer
raw_data[,1:feature_num] <- lapply(raw_data, function(x) as.numeric(as.character(x)))

#scale down non events
zero_class_ratio <- 2
fx_data <- rbind(raw_data[sample(which(raw_data$signal==0), table(raw_data["signal"])[2]*zero_class_ratio),], raw_data[which(raw_data$signal %in% c(1,2)),])

#split train test
train.index <- createDataPartition(raw_data$signal, p = .7, list = FALSE)
train <- raw_data[ train.index,]
test  <- raw_data[-train.index,]

#labels
train_labels <- train$signal
test_labels <- test$signal

#prepare matrix
train_mat <- as.matrix(train[,-which(names(train) == "signal")])
test_mat <- as.matrix(test[,-which(names(train) == "signal")])
dtrain <- xgb.DMatrix(data = train_mat, label = train_labels)
dtest <- xgb.DMatrix(data = test_mat, label = test_labels)

#create tasks
traintask <- makeClassifTask (data=train, target="signal")#, weight=2/zero_class_ratio)
testtask <- makeClassifTask (data=test, target="signal")

#create learner
lrn <- makeLearner("classif.xgboost", predict.type="prob")
lrn$par.vals <- list( objective="multi:softprob", num_class=3, eval_metric="mlogloss", nrounds=120L)

#set parameter space
params <- makeParamSet(
                        makeIntegerParam("max_depth",lower = 5L,upper = 15L)
                        , makeNumericParam("min_child_weight",lower = 1L,upper = 10L)
                        , makeNumericParam("subsample",lower = 0.5,upper = 1)
                        , makeNumericParam("colsample_bytree",lower = 0.5,upper = 1)
                        , makeNumericParam("eta",lower = 0.01,upper = 0.3)      
                        #, makeNumericParam("gamma",lower = 0L,upper = 10L) 
                        )

#set resampling strategy
rdesc <- makeResampleDesc("CV",stratify = T,iters=3L)

#search strategy
ctrl <- makeTuneControlRandom(maxit = 25L)

# tuning hyperparameters
mytune <- tuneParams(learner = lrn, task = traintask, resampling = rdesc, measures = acc, par.set = params, control = ctrl, show.info = F)

#set hyperparameters
lrn_tune <- setHyperPars(lrn, par.vals = mytune$x)

#train model
xgmodel <- mlr::train(learner = lrn_tune,task = traintask)

#predict on test
xgpred <- predict(xgmodel, testtask)

#results
calculateConfusionMatrix(xgpred)

#optional thresholding cost matrix
costs = matrix(c(0,0.1,0.1,.11,0,0,.11,0,0),3)
colnames(costs) = rownames(costs) = getTaskClassLevels(traintask)

# calculate thresholds as 1/(average costs of true classes)
th = 2/rowSums(costs)
names(th) = getTaskClassLevels(traintask)

# predict with threshold
xgpredthresh <- setThreshold(xgpred,threshold=th)

# results threshold
calculateConfusionMatrix(xgpredthresh)

#feature importance
fv = generateFilterValuesData(traintask, method = c("information.gain", "gain.ratio", "chi.squared"))
data_fv <- fv[[2]]
