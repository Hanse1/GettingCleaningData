#Make sure the source data for the project is extracted in your working directory
#This R script will create a text file called "tidy_data_set" in your working directory
if (!require("reshape2")) {
  install.packages("reshape2")
}

if (!require("data.table")) {
  install.packages("data.table")
}

require("data.table")
require("reshape2")

#Load the X & Y test data
load_X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
load_y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")

#Load activity labels and features
load_activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]
load_features <- read.table("./UCI HAR Dataset/features.txt")[,2]

#Load the train and test subject labels
load_subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
load_subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

#Load the X & Y train data
load_y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
load_X_train <- read.table("./UCI HAR Dataset/train/x_train.txt")

#Extract the mean and standard deviation for each feature
names(load_X_test) = load_features
extract_features <- grepl("mean|std", load_features)
load_X_test = load_X_test[,extract_features]
names(load_X_train) = load_features
load_X_train = load_X_train[,extract_features]

#Load activity labels for Y test and train
load_y_test[,2] = load_activity_labels[load_y_test[,1]]
names(load_y_test) = c("Activity_ID", "Activity_Label")
names(load_subject_test) = "subject"
load_y_train[,2] = load_activity_labels[load_y_train[,1]]
names(load_y_train) = c("Activity_ID", "Activity_Label")
names(load_subject_train) = "subject"

#Column bind the test and train data
bind_test_data <- cbind(as.data.table(load_subject_test), load_y_test, load_X_test)
bind_train_data <- cbind(as.data.table(load_subject_train), load_y_train, load_X_train)
bind_test_train = rbind(bind_test_data, bind_train_data)

#Melt the combined test/train data set
id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_test_train      = melt(bind_test_train, id = id_labels, measure.vars = data_labels)

#Apply mean function to dataset grouping subject and activity labels
tidy_data_set = dcast(melt_test_train, subject + Activity_Label ~ variable, mean)

#Write the tidy data set to a text file
write.table(tidy_data_set, file = "./tidy_data_set.txt", row.names = FALSE)
