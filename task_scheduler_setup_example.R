library(taskscheduleR)

# Load environment variables
R_SCRIPT_PATH <- Sys.getenv("R_SCRIPT_PATH")

## Run every day at the same time on 09:10, starting from tomorrow on
## Mark: change the format of startdate to your locale if needed (e.g. US: %m/%d/%Y)
taskscheduler_create(taskname = "ae_metrics_refresh", 
                     rscript = R_SCRIPT_PATH,
                     startdate = format(Sys.Date(), "%d/%m/%Y"),
                     starttime = "09:10", 
                     schedule = "MINUTE", 
                     modifier = 1)
                     # days = c('WED'),
                     # rscript_args = "productxyz 20160101"
                     # at = "12:00:00"

## get a data.frame of all tasks
tasks <- taskscheduler_ls()
str(tasks)

## delete the tasks
taskscheduler_delete(taskname = "ae_metrics_refresh")


# More info at:
# https://cran.r-project.org/web/packages/taskscheduleR/vignettes/taskscheduleR.html