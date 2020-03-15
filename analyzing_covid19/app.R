library(shiny)
require(shinydashboard)
library(ggplot2)
library(dplyr)
library(reshape2)
library(plotly)
library(shiny)
library(jtools)


    


data <- read.csv('dt.csv',stringsAsFactors = F,header=T)



# Define UI for application that draws a histogram
ui <- shinyUI(
    dashboardPage(title = "COVID19 dashboard",skin="green",
                  dashboardHeader(title = "COVID19 Dashboard",
                                  
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
                                  
                  )  ,
                  
                  dashboardSidebar(
                      br(),
                      sidebarMenu(
                          menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
                                 menuSubItem("Visualize",tabName="visualize",icon=icon("chart-pie")),
                          menuSubItem("Predict",tabName="predict",icon=icon("chart-line")),
                          menuItem("Visit-us", icon = icon("send",lib='glyphicon'), 
                                   href = "https://github.com/dhruvbpatel/Ingenious-Hackathon_Hack-Elite")
                      )
                  ),
                  
                  dashboardBody(
                      
                      
                      
                      
                      
                      tabItems(
                          
                          tabItem(
                              tabName="dashboard",
                              fluidRow(
                                  valueBoxOutput("value1")
                                  ,valueBoxOutput("value2")
                                  ,valueBoxOutput("value3")
                              )
                              
                              ,fluidRow(
                                  
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
                              
                              
                              
                          ),
                          
                          tabItem( 
                              tabName = "predict",h1("predictions "),
                              fluidRow(
                                  
                                  
                                  mainPanel(
                                      tableOutput("tableData"),
                                      
                                      verbatimTextOutput("sum"),
                                      verbatimTextOutput("sum2"),
                                      verbatimTextOutput("pred"),
                                      verbatimTextOutput("print")
                                  ), box(
                                      title = "Plots"
                                      ,status = "primary"
                                      ,solidHeader = TRUE
                                      ,collapsible = TRUE,
                                      dev.new(width=550,height=300,unit="10px")
                                      ,plotOutput("visual_plot", height = "200px",width = "200px")
                                     
                                      
                                  )
                                  
                              )
                              # verbatimTextOutput("visual_output"),
                              # fileInput("file1","Choose CSV file",
                              #           multiple = FALSE,
                              #           accept = c("text/csv",
                              #                      "text/comma-seperated-values,text/plain"
                              #                      ,".csv")
                              # )
                              
                              
                              
                          )
                          
                          , tabItem(
                              tabName = "visualize",
                              h1("Visualizations"),
                              
                              fluidRow(
                                  
                                  sidebarPanel(
                                      selectInput('xcol','X Variable', names(data)),
                                      selectInput('ycol','Y Variable', names(data)),
                                      selected = names(data)[[2]])
                                  
                              ,
                                  box(
                                      
                                      title = "Plots"
                                      ,status = "primary"
                                      ,solidHeader = TRUE
                                      ,collapsible = TRUE
                                      ,plotlyOutput("predict_plot", height = "400px",width = "400px")
                                  )
                              )
                              # ,plotlyOutput("plot")
                              


                          )
                          
                          )
                      
                      
                      
                      
                      
                  )
                  
                  
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    
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
            ,paste('Total Deaths :',data$TotalDeaths)
            ,icon = icon("stats",lib='glyphicon')
            ,color = "red")
        
    })
    
    
    
    output$value3 <- renderValueBox({
        
        valueBox(
            formatC(data$value, format="d", big.mark=',')
            ,paste('Total Recoverd :',data$Total_Recovered)
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
        
        
        plot_ly(data,x=~Country, y=~TotalCases,type="scatter")
        
        
        
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
    
    
    x <- reactive({
        data[,input$xcol]
    })
    
    y <- reactive({
        data[,input$ycol]
    })
    
    
    
    output$predict_plot <- renderPlotly(
        plot1 <- plot_ly(
            x = x(),
            y = y(), 
            type = 'scatter',
            mode = 'markers')
    )
    
    output$tableData <- renderTable({
        data
    })
    output$visual_plot<- renderPlot({
        x1 <- c(1:151)
        ggplot(data = data, aes(x =x1, y = TotalDeaths)) +
            geom_point() +
            stat_smooth(method = "lm", col = "dodgerblue3") +
            theme(panel.background = element_rect(fill = "white"),
                  axis.line.x=element_line(),
                  axis.line.y=element_line()) +
            ggtitle("Linear Model Fitted to Data")
        
        # regr <- lm(data$id~data$TotalDeaths)
        # effect_plot(   data=data,regr,pred=TotalDeaths,interval = T,plot.points = T     )
        # 
        # plot_ly(data,x=data$id,y=data$TotalDeaths,mode="lines")
        # abline(regr)
    })
    
    
    output$pred<- renderPrint({
        
        
        predict.lm(lm(data$id~data$TotalDeaths),data.frame(id=2))
        
        
        # regr <- lm(data$id~data$TotalDeaths)
        # effect_plot(   data=data,regr,pred=TotalDeaths,interval = T,plot.points = T     )
        # 
        # plot_ly(data,x=data$id,y=data$TotalDeaths,mode="lines")
        # abline(regr)
    })
    
    output$sum <- renderPrint({
        regr <- lm(data$id~data$TotalDeaths)
        summary(regr)
    })
    
    output$sum2 <- renderPrint({
        summary(data)
    })
    
    output$print <- renderPrint({
        regr <- lm(data$id~data$TotalDeaths,na.rm=T)
        print(regr)
    })
    
    
}



# Run the application 
shinyApp(ui = ui, server = server)
