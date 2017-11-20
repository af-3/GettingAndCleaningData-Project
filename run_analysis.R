#   SET WORKING DIRECTORY TO THE DOWNLOADED DATA, FOLDER "UCI HAR Dataset"

library("dplyr")
rm(list=ls())
# File names
files<-list.files(recursive=TRUE)

# Read in data
testData <- read.table("test/X_test.txt")
trainData <- read.table("train/X_train.txt")
testDataY <- read.table("test/Y_test.txt")
testSubject <- read.table("test/subject_test.txt")

trainDataY <- read.table("train/Y_train.txt")
trainSubject <- read.table("train/subject_train.txt")
featureNames <- read.table("features.txt")[2]
activityNames <- read.table("activity_labels.txt")
activityNames <- tbl_df(activityNames)

# Rename columns as features

names(testData) <- featureNames[,1]
names(trainData) <- featureNames[,1]
names(testDataY) <- "ActivityCode"
names(trainDataY) <- "ActivityCode"
names(testSubject) <- "Subject"
names(trainSubject) <- "Subject"
names(activityNames) <- list("ActivityCode","ActivityName")

# 1) Merges the training and the test sets to create one data set

# Merge test data
test_all <- cbind(testSubject,testDataY,testData)
# Merge train data
train_all <- cbind(trainSubject,trainDataY,trainData)
# Merge into one data frame
mergedData<-rbind(test_all,train_all)
mergedData <- tbl_df(mergedData)
mergedData <- mergedData[!duplicated(names(mergedData))]

# 2) Extracts only the measurements on the mean and standard deviation for each measurement

# Find features using mean and std
extractedData <- select(mergedData,Subject,ActivityCode,contains("mean"),contains("std"))

# 3) Uses descriptive activity names to name the activities in the data set
extractedData_ActivityName<-merge(extractedData,activityNames,by = "ActivityCode")
extractedData_ActivityName<-arrange(extractedData_ActivityName,Subject)
cleanData<-select(extractedData_ActivityName,Subject,ActivityCode,ActivityName,contains("mean"),contains("std"))

# 4) Appropriately labels the data set with descriptive variable names.
# already labelled the columns/variables appropriately right after import

# 5) From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject
groups<-group_by(cleanData,Subject,ActivityName)
cleanSummaryMeans <- summarize_each(groups,funs(mean))
write.table(cleanSummaryMeans,file="cleanSummaryMeans.txt",row.name=FALSE)
