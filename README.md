# README

## Raw Data Information

The Raw Data is a collection of data obtained from experiments using the Samsung Galaxy S phone's accelerometer and gyroscope readings. The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. 

## Steps Required to Create the Tidy Dataset
1. Download the [run_analysis.R](https://github.com/Sahil-yp/Getting_and_Cleaning_Data_Project.git) script.
2. Place it in the working directory, where the data folder is located.
3. Execute the script in Rstudio.
4. The tidy dataset file will be available in the working directory.

## Steps Performed in the *run_analysis.R* script file

* The script utilizes the *data.table, dplyr, and tidyr* libraries. Therefore, the first steps it performs is loading these required libraries.  

```r
library(data.table)
library(dplyr)
library(tidyr)
```

* It then stores the current working directory path as a variable to be utilized later

```r
initial.dir <- getwd()
```

* It checks if the unzipped dataset folder already exists in the working directory, and downloads and unzips it if the folder doesn't exist. If the file exists, it changes the workind directory to the datset folder, for ease of performing the next step.

```r
if(file.exists("UCI HAR Dataset"))
        setwd("./UCI HAR Dataset") else{
                file_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
                download.file(file_url, destfile = "./UCI HAR Dataset.zip")
                unzip("UCI HAR Dataset.zip")
        }
```

* To avoid typing the dataset file names manually into the script, and thus avoiding typos or any other human errors, the script reads all the file names in the folder and stores it as a list.

```r
location <- list.dirs("./", full.names = TRUE)


common_files <- list.files(location[1], full.names = TRUE)
test_files <- list.files(location[grep("/test", location)], full.names = TRUE)
train_files <- list.files(location[grep("/train", location)], full.names = TRUE)
```

* Since the raw data is divided into 2 parts as test and training data, the script collects both data parts individually, before combining them.  
The first step in this process, involves reading all the test data from the *X_test.txt* data file and naming the variables using the *features.txt* data file.

```r
test_data <- read.table(test_files[12])
features <- read.table(common_files[3])
setnames(test_data, (as.character(features$V2))) 
```

* One of the requirements of the output tidy data is to only consist of the measurements on the mean and standard deviation for each measurement. Therefore, the scripts seeks all the columns meeting this condition and retains only those columns for the _test_data_ DF.


```r
required_test_data <- test_data[, grep("mean|std", names(test_data))]
```

* The tidy data also requires the activity and subject information. 

```r
required_test_data <- cbind(read.table(test_files[11]), read.table(test_files[13]), required_test_data)
setnames(required_test_data, 1:2, c("subject_id", "activity"))
```


*The same operations are repeated on the training data set

```r
train_data <- read.table(train_files[12])
setnames(train_data, (as.vector(features$V2)))


required_train_data <- train_data[, grep("mean|std", names(train_data))]
required_train_data <- cbind(read.table(train_files[11]), read.table(train_files[13]), required_train_data)
setnames(required_train_data, 1:2, c("subject_id", "activity"))
rm(train_data)
```

* The test and training data can now be combined to create a single data frame with all the required data.

```r
raw_data <- rbind(required_test_data, required_train_data)
```

* Another one of the specifed tidy data requirement is the availability of the activity descriptions. The following steps read the _activity_labels_ file and add a column to the combined dataset, based on the existing activity column.

```r
activity_labels <- read.table(common_files[1])
setnames(activity_labels, 1:2, c("activity", "activity_description"))
raw_data <- inner_join(raw_data, activity_labels, by = 'activity')
raw_data <- data.table(raw_data)
setcolorder(raw_data, c(1, 2, length(raw_data), 3:(length(raw_data)-1)))
```

*The column names need to be cleaned for better readability. The elements in the names that need to be removed, replaced or standardized are **()**, **-**, and the double occurences of **Body**, i.e. **BodyBody**, in certain variables.

```r
setnames(raw_data, (gsub("[()]", "", names(raw_data)))) %>%
        setnames(gsub("[-]", "_", names(raw_data))) %>%
        setnames(gsub("BodyBody", "Body", names(raw_data)))
```

* The final requirement of the output data is that it be grouped and present the average of the each variable for each activity and subject. Therefore, the following steps group the data according to the *subject_id* and *activity*. The grouping allows the script to tidy the data such that the final output then provides the average each variable for the 6 different activities for each of the subject.

```r
grouped_data <- group_by(raw_data, subject_id, activity)


tidy_galaxy_data <- summarize_each(grouped_data, "mean")
```

*Once the tidy data has been created, the script creates an independent tidy dataset as a txt file.

```r
setwd(initial.dir)
write.table(tidy_galaxy_data, paste("tidy_galaxy_data_",Sys.Date(),".txt", sep = ""), col.names = TRUE, row.names = FALSE)
```

* Once all the requirements are achieved, the script detaches the library packages called at the begining, and prints a success statement.

```r
detach("package:data.table")
detach("package:dplyr")
detach("package:tidyr")

print("Your tidy data file has been created in your working directory!")
```
