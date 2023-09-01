library(NHSRdatasets)
library(dplyr)
library(ggplot2)
library(RDCOMClient)


# Load environment variables
PLOT_PATH <- Sys.getenv("PLOT_PATH")
RECEIVER_EMAIL <- Sys.getenv("RECEIVER_EMAIL")

# Loading NHS-R A&E attendances dataset
ae_attendances <- NHSRdatasets::ae_attendances

# Filter for organisations with code starting with R and find sums of metrics
ae_attendances_R <- ae_attendances %>%
  dplyr::mutate(org_code = as.character(org_code),
         first_letter = substr(org_code, 1, 1)) %>%
  dplyr::filter(first_letter == 'R') %>% 
  dplyr::summarise(attendances = sum(attendances),
            breaches = sum(breaches),
            admissions = sum(admissions),
            .by = c(period, first_letter))

# Plot metrics over time
ae_plot <- ggplot2::ggplot(ae_attendances_R, aes(x = period)) +
  geom_line(aes(y = attendances, color = 'Attendances'), linewidth=1.2) +
  geom_line(aes(y = breaches, color = 'Breaches'), linewidth=1.2) +
  geom_line(aes(y = admissions, color = 'Admissions'), linewidth=1.2) +
  labs(title = 'A&E metrics for organisation codes beginnign with R',
       x = 'Date',
       y = 'Number of patients',
       colour = 'Metrics') +
  scale_color_manual(values = c('Attendances' = 'blue', 'Breaches' = 'red', 'Admissions' = 'orange')) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, NA)) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(size = 18, hjust = 0.5, color = "#333333"),
    axis.title = element_text(size = 14, color = "black"),
    axis.text = element_text(size = 12, color = "black"),
    axis.line = element_line(color = "black"),
    panel.grid.major = element_line(color = "#DDDDDD"),
    panel.grid.minor = element_blank(),
    legend.text = element_text(size = 12, color = "black"),
    legend.position = "right",
    legend.box = "horizontal",
    plot.background = element_rect(fill = "white"),
  )

# Save plot
ggplot2::ggsave(PLOT_PATH, plot = ae_plot, width = 8, height = 6)
  


# Specify email properties
subject <- paste("A&E metrics - ", format(Sys.time(), "%e %b %Y"))
receiver_emails <- c(RECEIVER_EMAIL)

# Attach image of accuracy over time
image_path <- (PLOT_PATH)


### Sending the email
# devtools::install_github("omegahat/RDCOMClient")

# init com api
OutApp <- COMCreate("Outlook.Application")

# create an email 
outMail = OutApp$CreateItem(0)

# configure  email parameter 
outMail[["To"]] = receiver_emails
outMail[["subject"]] = "Test"

# Add attachment
outMail[["attachments"]]$Add(image_path) 

# Refer to the attachment with a cid - "basename" returns the file name without the directory.
image_inline <- paste0( "<img src='cid:",
                             basename(image_path),
                             "' width = '400' height = '400'>")

# Write email content
msg <- paste0('
<html>
<body>
<p>Data Scientists,</p>
<p>The current outlook of the NHS-R A&E attendances are:</p>',
image_inline,
'<p>Best regards,</p>
<p>Data Sci bot.</p>
</body>
</html>'
)

# Put the text and plot together in the body of the email.
outMail[["HTMLBody"]] <- msg

# send it                     
outMail$Send()


# For task log
print(paste0('Task completed succesfully! At time:', Sys.time()))