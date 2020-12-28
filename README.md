# StockInformationBSHK
App for updating a users stocks to see their current amount of stock and the ability to check the cost of other stocks. Written in Swift. Authors, Bryan Sullivan, Henok Ketsela start date of project was december 18th, 2020


What we still have to do:

2)create a user input blocker that checks if their input is a proper Stock symbol - run a api request on the token then if error pops up handle with not allowing stock to be added to list work on idea ed sullivan showed  
-stock detection error message {"chart":{"result":null,"error":{"code":"Not Found","description":"No data found, symbol may be delisted"}}}
3)fix app icon for Bryan 
4)create a portfolio file which would be able to keep track of multiple stocks and how much the total price is. 
5) try and find proper data types to contain the data of a stock aka an array for the values for the past day which would be used to create a graph 
6) Try and optimize calls possibly using the comparison 
7)pretty print the layout of the app which would make it look more professional 
8) being able to select a Refresh rate and then have the price of the stock on the right of the stock symbol- recommended by ed sullivan
9) be able to get an image of a chart and then just show the image if not we would have to be able to grab the data and then code the chart itself and that would be time consuming 

important:
1)


ideas:
1)Think of what we can add to the page after selecting the stock aka more data, Graph, 52 week high and low, closing price from previous day
2)create a loading screen that looks 
3)create a portfolio and how many shares you own on its own page all of the amount of money. total cost of stocks. 
4) comparing stocks which would allow to see side by side a stock and its data aka graph, 52 high, 52 low etc...

Working on 
1) creating functions for more data such as closing price, company name, and stuff like that
2) create a user responce which would tell the user that the stock symbol he/she is tring to use is not a valid symbol 
3) fix resizing the labels to fit the text 

researching
1) the cause of the error messages popping up on the console


Links for Research;
https://www.youtube.com/watch?v=EvwSB80GGDA goes over how to parse through the JSON string and how we can recieve data. 

what we finished 
1)Add and delete functions
2)no duplicates -Henok and Bryan
3)a stock symbol lookup which return the stocks current market price and prints that value on the Stock viewer screen -Bryan Henok 
