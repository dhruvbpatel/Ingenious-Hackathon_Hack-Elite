library(shiny)
require(shinydashboard)
library(ggplot2)
library(dplyr)
library(reshape2)
library(plotly)
    


data <- read.csv('dt.csv',stringsAsFactors = F,header=T)



#Dashboard header carrying the title of the, dashboard

header <- dashboardHeader(title = "COVID19 Dashboard",
                          
                          ## notification items
                          dropdownMenu(type = "message",
                                       messageItem(from = " Update",message = "we are on threshold"),
                                       messageItem(from=" Update",message = "data analysis 50% done",icon=icon("bar-chart"),time="22:00"),
                                       messageItem(from=" Update",message = "data update at 15:00 monday",time="15:00",icon = icon("handshake-o"))
                          ),
                          dropdownMenu(type="notifications",
                                       notificationItem(
                                           text="2 new tabs added to the dashboard",
                                           icon = icon("dashboard"),
                                           status="success"
                                       ),
                                       notificationItem(text="server is currently running at 95% load",
                                                        icon = icon("warning"),
                                                        status = "warning"
                                       )  
                          ),
                          
                          dropdownMenu(type="tasks",
                                       taskItem(
                                           value=80,
                                           color = "red",
                                           "Dashboard Tasks "
                                       ),
                                       
                                       taskItem(
                                           value = 60,
                                           color = "blue",
                                           "Health Status"
                                       )
                                       
                          )
                          
                          )  


#Sidebar content of the dashboard
sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
        menuSubItem("Visualize",tabName="visualize",icon=icon("chart-pie")),
        menuSubItem("Predict",tabName="predict",icon=icon("chart-line")),
        menuItem("Visit-us", icon = icon("send",lib='glyphicon'), 
                 href = "https://github.com/dhruvbpatel/Ingenious-Hackathon_Hack-Elite")
    )
)


frow1 <- fluidRow(
    valueBoxOutput("value1")
    ,valueBoxOutput("value2")
    ,valueBoxOutput("value3")
)

frow2 <- fluidRow(
        
    box(
        title = "Total Cases"
        ,status = "primary"
        ,solidHeader = TRUE 
        ,collapsible = TRUE 
        ,plotlyOutput("tc_plot", height = "400px",width="400px")
    )
    
    ,box(
        title = "Total Deaths"
        ,status = "primary"
        ,solidHeader = TRUE
        ,collapsible = TRUE
        ,plotlyOutput("td_plot", height = "400px",width = "400px")
    )
    
)



# combine the two fluid rows to make the body
body <- dashboardBody(frow1, frow2,
                      tabItems(
                      tabItem( 
                          tabName = "visualize",h1("Practicals "),
                          verbatimTextOutput("dhruv"),
                          fileInput("file1","Choose CSV file",
                                    multiple = FALSE,
                                    accept = c("text/csv",
                                               "text/comma-seperated-values,text/plain"
                                               ,".csv")
                          )
                          
                          
                          
                      ), tabItem(
                          tabName = "predicr",h1("Finance Dashboard"),
                          plotlyOutput("plot"),
                          verbatimTextOutput("event")
                          
                      ))
                      
                      
                      
                      
                      
                      )

#completing the ui part with dashboardPage
ui <- dashboardPage(title = 'covid19 Prediction', header, sidebar, body, skin='green')

# create the server functions for the dashboard  
server <- function(input, output) { 
    
    #some data manipulation to derive the values of KPI boxes
    #total.cases <- sum(recommendation$TotalCases)
    #sales.account <- recommendation %>% group_by(Account) %>% summarise(value = sum(Revenue)) %>% filter(value==max(value))
    #prof.prod <- recommendation %>% group_by(Product) %>% summarise(value = sum(Revenue)) %>% filter(value==max(value))
    #sum.total <- sum(recommendation$TotalCases)
    
    #creating the valueBoxOutput content
    output$value1 <- renderValueBox({
        valueBox(
            formatC(data$value, format="d", big.mark=',')
            ,paste('Total Active Cases:',(data$TotalCases))
            ,icon = icon("stats",lib='glyphicon')
            ,color = "purple")
        
        
    })
    
    
    
    output$value2 <- renderValueBox({
        
        valueBox(
            formatC(data$value, format="d", big.mark=',')
            ,paste('Total Active Cases:',data$TotalCases)
            ,icon = icon("stats",lib='glyphicon')
            ,color = "red")
        
    })
    
    
    
    output$value3 <- renderValueBox({
        
        valueBox(
            formatC(data$value, format="d", big.mark=',')
            ,paste('Total Active Cases:',data$TotalCases)
            ,icon = icon("stats",lib='glyphicon')
            ,color = "orange")
        
    })
    
    #creating the plotOutput content
    
    output$tc_plot <- renderPlotly({
# 
#         ggplot(data = recommendation,
#                aes(x=TotalCases,y=id))+ geom_point()+
#             geom_smooth(se = F)+ ylab("Country") +xlab("TotalCases") + theme(legend.position="bottom"
#                                     ,plot.title = element_text(size=15, face="bold")) +
#             ggtitle("Revenue by Product")
            y1 <- (data$TotalCases)
        
    plot_ly(data,x=~Country, y=y1,type="scatter")
        

          
    })
    

    output$td_plot <- renderPlotly({
        
        # ggplot(data = recommendation,
        #        aes(x=TotalCases,y=id))+ geom_point()+
        #     geom_smooth(se = F)+ ylab("Country") +xlab("TotalCases") + theme(legend.position="bottom"
        #                                                                      ,plot.title = element_text(size=15, face="bold")) +
        #     ggtitle("Revenue by Product")
        #
        plot_ly(data, x =~TotalDeaths,y=~Active_Cases)
        
    })

    
    
}


shinyApp(ui, server)