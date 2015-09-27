## Load the required libraries
library(data.table)
library(dplyr)
library(tidyr)

initial.dir <- getwd()

## Check if dataset exists, else download and unzip it
if(file.exists("UCI HAR Dataset"))
        setwd("./UCI HAR Dataset") else{
                file_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
                download.file(file_url, destfile = "./UCI HAR Dataset.zip")
                unzip("UCI HAR Dataset.zip")
        }


## Read the directory names as a list to avoid typing the file names in the script
location <- list.dirs("./", full.names = TRUE)


## Finding the common, test, and train files
common_files <- list.files(location[1], full.names = TRUE)
test_files <- list.files(location[grep("/test", location)], full.names = TRUE)
train_files <- list.files(location[grep("/train", location)], full.names = TRUE)


## Get the "test" data table and set the column names using the variable names
## from the features.txt dataset
test_data <- read.table(test_files[12])
features <- read.table(common_files[3])
setnames(test_data, (as.character(features$V2))) 


## ----------------------------REQUIREMENT 2 PART A-----------------------------
## This requirement has been achieved in 2 parts

## Filtering for only the required mean and std measurements
required_test_data <- test_data[, grep("mean|std", names(test_data))]


## Now add the activity and subjects columns, and name them
required_test_data <- cbind(read.table(test_files[11]), read.table(test_files[13]), required_test_data)
setnames(required_test_data, 1:2, c("subject_id", "activity"))


## test_data is no longer required, remove it to clear memory
rm(test_data)


## Perform the same set of operations to create the trainING data table
train_data <- read.table(train_files[12])
setnames(train_data, (as.vector(features$V2)))


## ----------------------------REQUIREMENT 2 PART B-----------------------------

required_train_data <- train_data[, grep("mean|std", names(train_data))]
required_train_data <- cbind(read.table(train_files[11]), read.table(train_files[13]), required_train_data)
setnames(required_train_data, 1:2, c("subject_id", "activity"))
rm(train_data)


## --------------------------------REQUIREMENT 1--------------------------------

## Combine test and train data
raw_data <- rbind(required_test_data, required_train_data)

## --------------------------------REQUIREMENT 3--------------------------------

## Adding the activity descriptions to the dataset
activity_labels <- read.table(common_files[1])
setnames(activity_labels, 1:2, c("activity", "activity_description"))
raw_data <- inner_join(raw_data, activity_labels, by = 'activity')
raw_data <- data.table(raw_data)
setcolorder(raw_data, c(1, 2, length(raw_data), 3:(length(raw_data)-1)))


## --------------------------------REQUIREMENT 4--------------------------------

## Cleaning the column names by removing "()", replacing "-" with "_", and
## correcting the "BodyBody" naming of the few end variables to "Body"
setnames(raw_data, (gsub("[()]", "", names(raw_data)))) %>%
        setnames(gsub("[-]", "_", names(raw_data))) %>%
        setnames(gsub("BodyBody", "Body", names(raw_data)))


## --------------------------------REQUIREMENT 5--------------------------------

## Group the data by subject id and activity
grouped_data <- group_by(raw_data, subject_id, activity)


## Getting the average of each variable for each activity and subject
tidy_galaxy_data <- summarize_each(grouped_data, "mean")


## Creating the second independent dataset
setwd(initial.dir)
write.table(tidy_galaxy_data, paste("tidy_galaxy_data_",Sys.Date(),".txt", sep = ""), col.names = TRUE, row.names = FALSE)

detach("package:data.table")
detach("package:dplyr")
detach("package:tidyr")

print("Your tidy data file has been created in your working directory!")