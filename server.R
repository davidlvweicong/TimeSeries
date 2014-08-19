library(shiny)
library(TSA)

shinyServer(function(input, output) {
    dataset <- reactive({
        eval(parse(text = paste0("data(", input$dataset, ")")))
        data <- as.numeric(eval(parse(text = input$dataset)))
        if (input$power == 0)
            if (min(data) == 0)
                log(1 + data)
            else
                log(data)
        else
            data ^ input$power
    })
    dataLen <- reactive({
        length(dataset())
    })
    trainLen <- reactive({
        round(input$ratio * dataLen())
    })
    testLen <- reactive({
        dataLen() - trainLen()
    })
    trainset <- reactive({
        dataset()[1: trainLen()]
    })
    testset <- reactive({
        dataset()[-(1: trainLen())]
    })
    fitTrend <- reactive({
        y <- trainset()
        x <- 1: trainLen()
        expr <- "y~1"
        for (k in seq_len(input$degree))
            expr <- paste0(expr, "+I(x^", k, ")")
        if (input$period != 0) {
            const <- 2 * pi / input$period
            for (k in seq_len(input$pdegree))
                expr <- paste0(expr, "+I(sin(", const * k, "*x))", "+I(cos(", const * k, "*x))")
        }
        eval(parse(text = paste0("lm(", expr, ")")))
    })
    fitARIMA <- reactive({
        f <<- fitTrend()
        arima(f$residuals, c(input$p, input$d, input$q))
    })
    testX <- reactive({
        trainLen() + (1: testLen())
    })
    pred <- reactive({
        predict(fitARIMA(), testLen())$pred
    })
    se <- reactive({
        predict(fitARIMA(), testLen())$se
    })
    conf <- reactive({
        predict(fitTrend(), data.frame(x = testX()), interval = "prediction")
    })
    res <- reactive({
        testset() - (conf()[, "fit"] + pred())
    })
    fit <- reactive({
        trend <- c(fitTrend()$fitted.values, conf()[, "fit"])
        arima <- c(fitted(fitARIMA()), pred())
        trend + arima
    })
    output$plotAll <- renderPlot({
        plot(dataset(), type = "o", xlab = "T", ylab = "Y", main = "Time Series")
        abline(v = trainLen(), col = "green3")
        if (input$period != 0)
            abline(v = input$period, col = "orange")
        points(fit(), type = "l", lty = 2, col = "red")
        points(testX(), conf()[, "fit"] + pred() + 1.96 * se(), type = "l", lty = 2, col = "blue")
        points(testX(), conf()[, "fit"] + pred() - 1.96 * se(), type = "l", lty = 2, col = "blue")
    })
    output$plotRes <- renderPlot({
        plot(dataset() - fit(), type = "o", xlab = "T", ylab = "e", main = "Residuals")
        abline(h = 0, col = "red")
        abline(v = trainLen(), col = "green3")
        if (input$period != 0)
            abline(v = input$period, col = "orange")
        points(testX(), res() + 1.96 * se(), type = "l", lty = 2, col = "blue")
        points(testX(), res() - 1.96 * se(), type = "l", lty = 2, col = "blue")        
    })
})
