library(shiny)
require(shinydashboard)
library(ggplot2)
library(dplyr)
library(reshape2)
library(plotly)



recommendation <- read.csv('dt.csv',stringsAsFactors = F,header=T)



#Dashboard header carrying the title of the, dashboard
header <- dashboardHeader(title = "COVID19 Dashboard",
                          
                          ## notification items
                          dropdownMenu(type = "message",
                                       messageItem(from = "Finance Update",message = "we are on threshold"),
                                       messageItem(from="Sales Update",message = "Sales are at 50%",icon=icon("bar-chart"),time="22:00"),
                                       messageItem(from="Sales Update",message = "sales meeting at 15:00 monday",time="15:00",icon = icon("handshake-o"))
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
        menuItem("Visualize",tabName="visualize",icon=icon("chart-pie")),
        menuItem("Predict",tabName="predict",icon=icon("chart-line")),
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
        ,plotOutput("revenuebyPrd", height = "300px")
    )
    
    ,box(
        title = "Total Deaths"
        ,status = "primary"
        ,solidHeader = TRUE 
        ,collapsible = TRUE 
        ,plotOutput("revenuebyRegion", height = "300px")
    ) 
    
)



# combine the two fluid rows to make the body
body <- dashboardBody(frow1, frow2)

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
            formatC(recommendation$value, format="d", big.mark=',')
            ,paste('Total Active Cases:',(recommendation$TotalCases))
            ,icon = icon("stats",lib='glyphicon')
            ,color = "purple")
        
        
    })
    
    
    
    output$value2 <- renderValueBox({
        
        valueBox(
            formatC(recommendation$value, format="d", big.mark=',')
            ,paste('Total Active Cases:',recommendation$TotalCases)
            ,icon = icon("stats",lib='glyphicon')
            ,color = "red")
        
    })
    
    
    
    output$value3 <- renderValueBox({
        
        valueBox(
            formatC(recommendation$value, format="d", big.mark=',')
            ,paste('Total Active Cases:',recommendation$TotalCases)
            ,icon = icon("stats",lib='glyphicon')
            ,color = "orange")
        
    })
    
    #creating the plotOutput content
    
    output$revenuebyPrd <- renderPlot({
        # ggplot(data = recommendation, 
        #        aes(x=TotalCases, y=TotalDeaths )) + geom_point() +
        #     geom_smooth(se=F)+ ylab("Country") + 
        #     xlab("TotalCases") + theme(legend.position="bottom" 
        #                             ,plot.title = element_text(size=15, face="bold")) + 
        #     ggtitle("Revenue by Product")
       
            plot_ly(data=recommendation, x = ~TotalCases, y = ~Country)
       
    })
    
    
    output$revenuebyRegion <- renderPlot({
        ggplot(data = recommendation, 
               aes(x=Account, y=Revenue, fill=factor(Region))) + 
            geom_bar(position = "dodge", stat = "identity") + ylab("Revenue (in Euros)") + 
            xlab("Account") + theme(legend.position="bottom" 
                                    ,plot.title = element_text(size=15, face="bold")) + 
            ggtitle("Revenue by Region") + labs(fill = "Region")
    })
    
    
    
}


shinyApp(ui, server)