# StockInformationBSHK
App for updating a users stocks to see their current amount of stock and the ability to check the cost of other stocks. Written in Swift. Authors, Bryan Sullivan, Henok Ketsela start date of project was december 18th, 2020


What we still have to do:

1) fix resizing the labels to fit the text aka pretty print
2) Try and optimize calls possibly using the comparison 
3) pretty print the layout of the app which would make it look more professional 
4) when in debugmode allow for the print statements else do not include print statements
5) be able to get an image of a chart and then just show the image if not we would have to be able to grab the data and then code the chart itself and that would be time consuming 
6) Fix the loading screen picture and the app icon using the "Company Logo"

important:
1)when running on an iphone the keyboard after typing in the Stock Symbol does not go away not allowing the user to see the labels/output.
2)going through the code and making sure we are utilizing functions and if code is being repeated turn it into a function
3) create a graph in stock information


ideas:
1)Think of what we can add to the page after selecting the stock aka more data, Graph, 52 week high and low, closing price from previous day
2)create a loading screen that looks interesting 
4) comparing stocks which would allow to see side by side a stock and its data aka graph, 52 high, 52 low etc...

Working on 
4)create a portfolio file which would be able to keep track of multiple stocks and how much the total price is. -Bryan
2) adding a test stock symbol to see the stock symbol's company name and such - Henok 



researching
1) the cause of the error messages popping up on the console


Links for Research;
https://www.youtube.com/watch?v=EvwSB80GGDA goes over how to parse through the JSON string and how we can recieve data. 

what we finished 
1)Add and delete functions
2)no duplicates -Henok and Bryan
3)a stock symbol lookup which return the stocks current market price and prints that value on the Stock viewer screen -Bryan Henok 
4)create a user input blocker that checks if their input is a proper Stock symbol - run a api request on the token then if error pops up handle with not allowing stock to be added to list work on idea ed sullivan showed  
-stock detection error message {"chart":{"result":null,"error":{"code":"Not Found","description":"No data found, symbol may be delisted"}}}
5) creating functions for more data such as closing price, company name, and stuff like that - Henok 
2) create a user responce which would tell the user that the stock symbol he/she is tring to use is not a valid symbol 
8) being able to select a Refresh rate and then have the price of the stock on the right of the stock symbol
Weds 30 ) errorhandeling for stock symbol entering, loading screen, getting data on stock which required a new function, started portfolio for the user. 
January 4) 
