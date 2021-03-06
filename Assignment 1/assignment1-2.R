setwd('C:\\Users\\ranzhao\\Documents\\Empirical-Asset-Pricing\\Assignment 1')
setwd('D:\\PhD FE\\Empirical-Asset-Pricing\\Assignment 1')


# Data loading
#require(ggplot2)
spx_index_values = read.csv('spx_index_values.csv', header = TRUE)
plot(as.Date(as.character(spx_index_values$Date), "%m/%d/%Y"), spx_index_values$SPX.Index, type='l', 
     main='SPX index levels, from 1954 to 2015',
     xlab='year', ylab='SPX index')

# calculate the return series
spx_index_values$Return = rep(0, dim(spx_index_values)[1])
spx_index_values$Return[2:length(spx_index_values$Return)] = 
  spx_index_values$SPX.Index[2:length(spx_index_values$SPX.Index)] / 
  spx_index_values$SPX.Index[1:(length(spx_index_values$SPX.Index)-1)] - 1

# calculation empirical moments
return.data = spx_index_values$Return
n.length = length(return.data)
emp.moment.1 = mean(return.data)
emp.moment.2 = 1/(n.length-1)*sum((return.data - emp.moment.1)^2)
emp.moment.4 = 1/(n.length-1)*sum((return.data - emp.moment.1)^4)
emp.moment.6 = 1/(n.length-1)*sum((return.data - emp.moment.1)^6)

# optimization function
moment.diff = function(data.input){
  mu = data.input[1]
  sigma.square = data.input[2]
  lambda = data.input[3]
  delta.square = data.input[4]
  
  theo.moment.1 = mu - sigma.square / 2
  theo.moment.2 = sigma.square + lambda * delta.square
  theo.moment.4 = 3 * ((sigma.square+lambda*delta.square)^2 + lambda*delta.square^2)
  theo.moment.6 = 15 * ((sigma.square+lambda*delta.square)^2 + 3*lambda*delta.square*(sigma.square+lambda*delta.square)+lambda*delta.square^3)
  
  least.square.obj = (theo.moment.1 - emp.moment.1)^2 + 100*(theo.moment.2 - emp.moment.2)^2 + 10000*(theo.moment.4 - emp.moment.4)^2 + 10000*(theo.moment.6 - emp.moment.6)^2
  return(least.square.obj)
}

# parameter calibration
output = optim(c(0, 0.006, 0.03, 0.005), moment.diff)
output$par

mu = output$par[1]
sigma.square = output$par[2]
lambda = output$par[3]
delta.square = output$par[4]

theo.moment.1 = mu - sigma.square / 2
theo.moment.2 = sigma.square + lambda * delta.square
theo.moment.4 = 3 * ((sigma.square+lambda*delta.square)^2 + lambda*delta.square^2)
theo.moment.6 = 15 * ((sigma.square+lambda*delta.square)^2 + 3*lambda*delta.square*(sigma.square+lambda*delta.square)+lambda*delta.square^3)

theo.out = c(theo.moment.1, theo.moment.2, theo.moment.4, theo.moment.6)
empi.out = c(emp.moment.1, emp.moment.2, emp.moment.4, emp.moment.6)
diff.out = empi.out - theo.out
perg.out = diff.out / theo.out

cbind(theo.out, empi.out, diff.out, perg.out)


# well specified
g=spx_index_values$Return

sim.returns = spx_index_values$Return
for (i in 3:length(sim.returns)){
  sim.returns[i] = sim.returns[i] + mu - 0.5*sigma.square + (sqrt(sigma.square)-lambda*sqrt(abs(delta.square)))*rnorm(1) + sum(runif(1)<lambda)*rnorm(1, 0, sqrt(abs(delta.square)))
}

p2<-hist(sim.returns, breaks=500, density=500) 

h<-hist(g, breaks=500, density=500, col="lightgray", xlab="SP500 Index Returns", main="SP500 Index Daily Returns vs. Estimated Normals",
        xlim=range(c(-0.05,0.05))) 
xfit<-seq(min(g),max(g),length=500) 
yfit<-dnorm(xfit,mean=mean(g),sd=sd(g)) 
yfit <- yfit*diff(h$mids[1:2])*length(g) 
lines(xfit, yfit, col="black", lwd=2)
plot( p2, col=rgb(1,0,0,1/4), xlim=c(-0.05,0.05), add=T)  # second
legend(-1, 1.9, c("a", "b", "c"))
