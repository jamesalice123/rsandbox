library(quantmod)
library(season)
library(PerformanceAnalytics)

setSymbolLookup(SPY=list(src="csv",format="%Y-%m-%d", dir="data"))
spy <- getSymbols("SPY", auto.assign=FALSE)

spym  = monthlyReturn(spy$SPY.Close)

spy$SPY.CloseL = log(spy$SPY.Close)
spyml = monthlyReturn(spy$SPY.CloseL)
spymlm = format(time(spyml), "%m")
spym = merge(spyml, spymlm)


# there is a lot of periodicity here -- have I added it in?  it must already be taken into account...how?
# how can I expose the periodicity?  FFT of the periodic component?

t0 = 48
n = 36

png(filename="seasonality-spy-_%03d_med.png", width=480, height=480) # can add type="cairo", antialias="subpixel"
plot(stl(ts(head(tail(y, n=t0), n=12), frequency=12), "periodic"), head(tail(x, n=t0), n=12), main="Periodicity in S&P500 returns", sub="first 12 months of last four years")
plot(stl(ts(head(tail(y, n=t0), n=24), frequency=12), "periodic"), head(tail(x, n=t0), n=24), main="Periodicity in S&P500 returns", sub="first 24 months of last four years")
plot(stl(ts(head(tail(y, n=t0), n=36), frequency=12), "periodic"), head(tail(x, n=t0), n=36), main="Periodicity in S&P500 returns", sub="first 36 months of last four years")
plot(stl(ts(head(tail(y, n=t0), n=t0), frequency=12), "periodic"), head(tail(x, n=t0), n=t0), main="Periodicity in S&P500 returns", sub="first 48 months of last four years")
dev.off()
# over varying time scales, it might be possible to visually analyse the trend development and confirm the periodicity; then it might suffice to predict the trend, especially if the trend and the periodic flows seem to change at different speeds...



#http://www.math.mcmaster.ca/peter/s3n03/s3n03_0203/classnotes/tsandlaginr.html
lag.plot(y)


chart.TimeSeries(spyml)



plotCircular(area1=spyml,labels=spymlm,dp=0)

spy$SPY.Month = format(time(spy$SPY.Close), "%m")

plotCircular(area1=spy$SPY.Close,labels=spy$SPY.Month,dp=0)

plot(ts(coredata(spyml)[,1], frequency=12))
plot(stl(ts(coredata(spyml)[,1], frequency=12), "periodic"))


#setDefaults(chartSeries, theme="white")
barChart(spy, theme="white")




# another approach:

spyc <- ts(spy$SPY.Close, f=4)
fit <- ts(rowSums(tsSmooth(StructTS(spyc))[,-2]))
tsp(fit) <- tsp(spyc)
plot(spyc)
plot(spy$SPY.Close)
lines(fit,col=2)

#The idea is to use a basic structural model for the time series,
#which handles the missing value fine using a Kalman filter. Then a
#Kalman smooth is used to estimate each point in the time series,
#including any omitted.
#
#I had to convert your zoo object to a ts object with frequency 4 in
#order to use StructTS. You may want to change the fitted values back
#to zoo again.



# primitive plotCircular example
#daysoftheweek<-c('Monday','Tuesday','Wednesday','Thursday','Friday', 'Saturday','Sunday')
#weekfreq<-table(round(runif(100,min=1,max=7)))
#plotCircular(area1=weekfreq,labels=daysoftheweek,dp=0)



# other ideas
#from http://www.designandanalytics.com/recession-beard-time-series-in-R-part-2

library(XML)         # read.zoo
library(xts)         # our favorite time series
library(tis)         # recession shading.
library(ggplot2)     # artsy plotting
library(gridExtra)   # for adding a caption
library(timeDate)    # for our prediction at the end

# Get the data from the web as a zoo time series
URL <- 'http://robjhyndman.com/tsdldata/roberts/beards.dat'
beard <- read.zoo(URL,
    header=FALSE,
    index.column=0,
    skip=4,
    FUN=function(x) as.Date(as.yearmon(x) + 1865))
# Last line is tricky, check here:
#http://stackoverflow.com/questions/10730685/possible-to-use-read-zoo-to-read-an-unindexed-time-series-from-html-in-r/10730827#10730827

# Put it into xts, which is a more handsome time series format.
beardxts <- as.xts(beard)
names(beardxts) <- "Full Beard"

# Make into a data frame, for ggplotting
beard.df <- data.frame(
    date=as.Date(index(beardxts),format="%Y"),
    beard=as.numeric(beardxts$'Full Beard'))

# Make the plot object
bplot <- ggplot(beard.df, aes(x=date, y=beard)) +
    theme_bw() +
    geom_point(aes(y = beard), colour="red", size=2) +
    ylim(c(0,100)) +
    geom_line(aes(y=beard), size=0.5, linetype=2) +
    xlab("Year") +
    ylab("Beardfulness (%)") +
    opts(title="Percentage of American Men Fully Bearded")
print(bplot)

# Add recession shading
bplot2 <- nberShade(bplot,
    fill = "#C1C1FF",
    xrange = c("1866-01-01", "1911-01-01"),
    openShade = TRUE) # looks weird when FALSE

#Plot it
print(bplot2)
