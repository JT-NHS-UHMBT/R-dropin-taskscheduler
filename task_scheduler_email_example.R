library(NHSRdatasets)
library(dplyr)
library(ggplot2)
library(sendmailR)

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
ggplot2::ggsave('ae_plot.png', plot = ae_plot, width = 8, height = 6)
  


# Specify email properties
subject <- paste("A&E metrics - ", format(Sys.time(), "%e %b %Y"))
sender <- c("DataSci_Bot@mbhci.nhs.uk")
receiver_emails <- c("Jake.Tufts@mbhci.nhs.uk")

# Attach image of accuracy over time
images_path <- ('ae_plot.png')
images_inline <- sendmailR::mime_part(x=images_path, name='ae_plot.png')


# Write email content
string_msg <- ('
<html>
<body>
<p>Data Scientists,</p>
<p>The current outlook of the NHS-R A&E attendances are:</p>
<img src="ae_plot.png" style=\"width:50.0%\">
<p>Best regards,</p>
<p>Data Sci bot.</p>
</body>
</html>'
)


# Create an inline HTML MIME Part
msg <- sendmailR::mime_part_html(string_msg)

# Add images as attachment
body <- list(msg, images_inline)

# Email details
smtp_server <- "edgemail.uhmb.nhs.uk"
smtp_port <- 25

# Send email
sendmailR::sendmail(from = sender,
         to = receiver_emails,
         subject = subject,
         msg = body,
         control = list(smtpServer = smtp_server, port = smtp_port))
