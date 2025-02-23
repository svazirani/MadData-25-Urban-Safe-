# UrbanSafe: Crime Data Analysis and Visualization  

## Overview  
UrbanSafe is an interactive web application that provides users with in-depth crime data analysis, empowering them with insights into crime patterns and trends. The app features interactive visualizations, heatmaps, and filtering options to explore crime data across different categories, districts, and time frames. It also includes an API to access crime data remotely.  

## Features  

- 📍 **Interactive Crime Map** – View crime incidents based on location with heatmap and clustering options.  
- 🔥 **Interactive Heatmap** – Visualize crime density across different areas dynamically.  
- 📊 **Crime Trends Analysis** – Analyze crime occurrences by hour, district, and category.  
- 🔍 **Advanced Filtering** – Select crime categories, districts, and timeframes to refine data exploration.  
- 📱 **Mobile Accessibility** – The Shiny web app can be accessed on mobile via a URL.  

## Tech Stack  

- **Frontend:** Shiny (R) for the web interface  
- **Backend:** R (Shiny) for data processing and API services  
- **Database:** CSV-based crime data storage and analysis  
- **Visualization:** Leaflet, ggplot2, dplyr for interactive data representation  

## Installation & Setup  

### For Web App (Shiny)  

#### 1️⃣ Clone the repository:  
```sh
git clone https://github.com/yourusername/UrbanSafe.git
cd UrbanSafe
install.packages(c("shiny", "ggplot2", "dplyr", "bslib", "readr", "leaflet", "lubridate", "leaflet.extras", "jsonlite", "httpuv"))
shiny::runApp()

## Future Improvements 🚀  

- ✅ **Machine learning-based crime prediction**  
- ✅ **More granular filtering (day-wise, severity, etc.)**  
- ✅ **Live crime data integration**  

## Contributing  

### Current Contributors:  

- **Soham Vazirani** 📧 [sohamvazirani@gmail.com](mailto:sohamvazirani@gmail.com)  
- **Dharmil Savla** 📧 [dsav1306@gmail.com](mailto:dsav1306@gmail.com)  
- **Aryan Goenka** 📧 [avgoeanka@wisc.edu](mailto:avgoeanka@wisc.edu)  
- **Devanshi Jain** 📧 [dsjain3@wisc.edu](mailto:dsjain3@wisc.edu)  
- **Siddarth Sethupathy** 📧 [setupathy@wisc.edu](mailto:setupathy@wisc.edu)  

💡 **Contributions are welcome!** Fork this repository, create a new branch, and submit a pull request.  

## License 📝  

This project is licensed under the **MIT License**.  

