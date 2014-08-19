shinyUI(fluidPage(
    titlePanel("Time Series Analysis"),
    sidebarLayout(
        sidebarPanel(
            navbarPage("Toolbar",
                tabPanel("Data",
                    selectInput("dataset", "Data set:",
                        choices = c("airmiles", "airpass", "beersales", "co2", "CREF", "cref.bond",
                            "electricity", "flow", "gold", "google", "hare", "JJ", "larain", "milk",
                            "oil.price", "oilfilters", "prescrip", "retail", "robot", "SP", "spots",
                            "star", "tempdub", "wages", "winnebago")),
                    sliderInput("ratio", "Ratio of the training set:", min = 0, max = 1, step = 0.01, value = 0.8),
                    sliderInput("power", "Power transformation:", min = 0, max = 10, step = 0.1, value = 1),
                    br()
                ),
                tabPanel("Analysis",
                    h5("Trend Component"),
                    sliderInput("degree", "Degree of the polynomial:", min = 0, max = 30, value = 0),
                    br(),
                    h5("Seasonal Component"),
                    sliderInput("period", "Period:", min = 0, max = 200, step = 1, value = 0),
                    sliderInput("pdegree", "Degree of the trigonometric polynomial:", min = 0, max = 30, value = 0),
                    br(),
                    h5("Irregular Component: ARIMA(p, d, q)"),
                    sliderInput("d", "Degree of differencing (d):", min = 0, max = 10, value = 0),
                    sliderInput("p", "AR order (p):", min = 0, max = 20, value = 0),
                    sliderInput("q", "MA order (q):", min = 0, max = 20, value = 0),
                    br()
                ),
                tabPanel("Instructions",
                    p("The application is a visualization of time series analysis with ARIMA model."),
                    h5("Data"),
                    p("The data sets are from the R package TSA. You can select the ratio of training set
                        which is used to fit the model. The power transformation is very useful when the
                        model does not fits well, and notice that power of zero actually means the log
                        transformation."),
                    br(),
                    h5("Analysis"),
                    p("The time series can be decomposes into three components: the trend component, the
                        seasonal component and the irregular component. The trend component is a polynomial,
                        while the seasonal component is a trigonometric polynomial. Anaylizing the irregular
                        component is more difficult. Here we use a model called ARIMA, which is one of the
                        most popular models in time series analysis. You can easily change the parameters of
                        the model to see the results."),
                    br(),
                    h5("Plot"),
                    p("There are two plots: the time series and the residuals. The green lines divide the
                        data into the training set and the test set. The oranges line represent the period.
                        The red line in the first plot is the fitted values and the predictions. The blue
                        lines are the 95% confidence intervals.")
                )
            )
        ),
        mainPanel(
            plotOutput("plotAll"),
            plotOutput("plotRes")
        )
    )
))
