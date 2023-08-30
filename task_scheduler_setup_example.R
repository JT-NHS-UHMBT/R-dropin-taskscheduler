library(taskscheduleR)

## Run every day at the same time on 09:10, starting from tomorrow on
## Mark: change the format of startdate to your locale if needed (e.g. US: %m/%d/%Y)
taskscheduler_create(taskname = "ae_metrics_refresh", 
                     rscript = 'C:/Task Scripts/Model accuracy alerting/task_scheduler_email_example.R',
                     schedule = "MINUTE", 
                     starttime = "16:28", 
                     modifier = 3,
                     startdate = format(Sys.Date(), "%d/%m/%Y"),
                     days = c('WED'),
                     rscript_args = "productxyz 20160101")
                     # at = "12:00:00"

## get a data.frame of all tasks
tasks <- taskscheduler_ls()
str(tasks)

## delete the tasks
taskscheduler_delete(taskname = "ae_metrics_refresh")


# More info at:
# https://cran.r-project.org/web/packages/taskscheduleR/vignettes/taskscheduleR.html