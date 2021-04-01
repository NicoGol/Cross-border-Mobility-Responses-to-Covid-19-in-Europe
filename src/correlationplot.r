library(corrplot)
library(tidyverse)
M<-read.csv("../data/features_traffic.csv")
M <- M %>% 
  rename(
    "New Covid cases" = new_cases_per_million,
    "New Covid deaths" = new_deaths_per_million,
    "C1 School closing" = c1_schoolclosing,
    "C2 Workplace closing" = c2_workplaceclosing,
    "C3 Cancel public events" = c3_cancel_events,
    "C4 Restrictions gatherings" = c4_restr_gather,
    "C5 Close public transport" = c5_closepublictransport,
    "C6 Stay home requirements" = c6_stay_home,
    "C7 Restr. Internal movement" = c7_restr_internal_move,
    "C8 Inter. travel controls" = c8_int_trvl_controls,
    "H2 Testing policy" = h2_testingpolicy,
    "H3 Contact tracing" = h3_contacttracing,
    "Traffic growth rate" = traffic
  )
M<-cor(M)
dev.new(width=20, height=20)
col1 <- colorRampPalette(c("yellow","#F28500", "#A020F0","#00008B"))
corrplot(M,method='circle',type='lower',tl.col = "black",col=col1(100),tl.pos='l')
