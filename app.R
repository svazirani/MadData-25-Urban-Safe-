library(shiny)
library(ggplot2)
library(dplyr)
library(bslib)
library(readr)
library(leaflet)
library(lubridate)
library(leaflet.extras)

# Read the crime data
crime_data <- read_csv("updated_crime_data.csv")

# Convert Date column to POSIXct (ensure correct format)
crime_data$Date <- as.POSIXct(crime_data$Date, format = "%d-%m-%Y %H:%M")

# Extract month and hour from the Date column
crime_data$Month <- format(crime_data$Date, "%Y-%m")
crime_data$Hour <- hour(crime_data$Date)

# Ensure Latitude and Longitude are numeric
crime_data <- crime_data %>%
  mutate(Latitude = as.numeric(Latitude),
         Longitude = as.numeric(Longitude))

# Remove NA values from important columns
crime_data <- na.omit(crime_data)

# Define UI ----
ui <- fluidPage(
  theme = bs_theme(bootswatch = "darkly", bg = "#29354a", fg = "white"),
  titlePanel(tags$h1("UrbanSafe", style = "color: #ccaff0; font-size: 100px")),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      style = "padding: 25px; background-color: #1e2736; border-radius: 10px",
      selectInput("crimeCategory", "Select Crime Category:",
                  choices = unique(crime_data$Crime_Category),
                  selected = unique(crime_data$Crime_Category)[1], multiple = TRUE),
      selectInput("district", "Select District:",
                  choices = sort(unique(crime_data$District)),
                  selected = sort(unique(crime_data$District))[1],
                  multiple = TRUE),
      selectInput("month", "Select Month:",
                  choices = sort(unique(crime_data$Month)),
                  selected = sort(unique(crime_data$Month))[1],
                  multiple = TRUE),
      actionButton("cumulativeButton", "Show Cumulative Data"),
      checkboxInput("showHeatmap", "Show Heatmap", FALSE)
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Crime Map", leafletOutput("crimeMap", height = "600px")),
        tabPanel("Crime Patterns by Hour",
                 fluidRow(
                   column(6, selectInput("district_hour", "Select District for Hourly Patterns:",
                                         choices = sort(unique(crime_data$District)),
                                         selected = sort(unique(crime_data$District))[1],
                                         multiple = TRUE)),
                   column(6, sliderInput("hour_range", "Select Hour Range:",
                                         min = 0, max = 23, value = c(0, 23), step = 1))
                 ),
                 fluidRow(
                   column(6, plotOutput("violent_plot", height = "400px")),
                   column(6, plotOutput("assault_plot", height = "400px"))
                 ),
                 fluidRow(
                   column(6, plotOutput("robbery_plot", height = "400px")),
                   column(6, plotOutput("intimidation_plot", height = "400px"))
                 )
        )
      )
    )
  )
)

# Define server logic ----
server <- function(input, output) {
  cumulative_mode <- reactiveVal(FALSE)
  
  observeEvent(input$cumulativeButton, {
    cumulative_mode(!cumulative_mode())
  })
  
  map_data <- reactive({
    req(input$crimeCategory)
    filtered_data <- crime_data %>%
      filter(Crime_Category %in% input$crimeCategory)
    
    if (!cumulative_mode()) {
      filtered_data <- filtered_data %>%
        filter(District %in% input$district, Month %in% input$month)
    }
    
    filtered_data <- filtered_data %>% filter(!is.na(Latitude) & !is.na(Longitude))
    
    if (nrow(filtered_data) == 0) {
      return(data.frame(Longitude = -87.6298, Latitude = 41.8781, Crime_Category = "No Data"))
    }
    
    return(filtered_data)
  })
  
  output$crimeMap <- renderLeaflet({
    data <- map_data()
    
    leaflet(data) %>%
      addTiles() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = -87.6298, lat = 41.8781, zoom = 10) %>%
      { if (nrow(data) == 1 && data$Crime_Category == "No Data")
        addPopups(., -87.6298, 41.8781, "No data available for selected category")
        else if (input$showHeatmap)
          addHeatmap(., lng = ~Longitude, lat = ~Latitude, intensity = ~1, blur = 20, max = 0.05, radius = 15)
        else
          addMarkers(., lng = ~Longitude, lat = ~Latitude, clusterOptions = markerClusterOptions(), popup = ~paste("Crime:", Crime_Category, "<br>", "Date:", Date))
      }
  })
  
  filtered_data <- reactive({
    req(input$district_hour)
    crime_data %>%
      filter(District %in% input$district_hour)
  })
  
  get_crime_data <- function(crime_type) {
    df <- filtered_data() %>%
      filter(Crime_Category == crime_type, Hour >= input$hour_range[1], Hour <= input$hour_range[2]) %>%
      group_by(District, Hour) %>%
      summarise(Count = n(), .groups = "drop")
    
    all_districts <- expand.grid(District = unique(crime_data$District), Hour = 0:23)
    df <- merge(all_districts, df, by = c("District", "Hour"), all.x = TRUE)
    df$Count[is.na(df$Count)] <- 0
    return(df)
  }
  
  render_crime_plot <- function(crime_type, title) {
    renderPlot({
      df <- get_crime_data(crime_type)
      if (nrow(df) == 0) return(NULL)
      ggplot(df, aes(x = Hour, y = Count, fill = as.factor(District))) +
        geom_bar(stat = "identity") +
        labs(title = title, x = "Hour", y = "Count") +
        theme_minimal() +
        theme(legend.position = "none", axis.text.x = element_text(angle = 90, hjust = 1))
    })
  }
  
  output$violent_plot <- render_crime_plot("Violent Crimes", "Violent Crimes by Hour")
  output$assault_plot <- render_crime_plot("Assault & Sexual Offenses", "Assault & Sexual Offenses by Hour")
  output$robbery_plot <- render_crime_plot("Robbery & Theft", "Robbery & Theft by Hour")
  output$intimidation_plot <- render_crime_plot("Intimidation & Other", "Intimidation & Other by Hour")
}

# Run the app ----
shinyApp(ui = ui, server = server)