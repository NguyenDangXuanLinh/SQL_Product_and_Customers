# A Retailer of Classic Cars Scale Models Sales Performance and Customers Analysis 

Conducted product and customer analysis on SQL for a retailer of scale models of classic cars. The analysis helps:
- Prevent the best-selling products from out of stock.
- Understand current customers including VIP customers (who bring the most profits), and the less-engaged customers.
- Examine customer life value to create marketing communication strategies.

https://www.mysqltutorial.org/mysql-sample-database.aspx

# Key Metrics
Sales: best selling car models in low stock 
Plan Customer: most engaged, least engaged, and new customers
Plan Period: monthly and yearly plan

# Summary of Insights

## Plan re-stock:
 - The car models in the urgent need of restock would be those which `sum(quantityOrdered)/quantityInStock` is highest and overlapped it with the highest performing products. These are the products which are currently the most in need of restocking:

-- S10_1949	1952 Alpine Renault 1300

-- S18_1749	1917 Grand Touring Sedan

-- S18_2238	1998 Chrysler Plymouth Prowler

## Plan Period:
- The number of new customers has been decreasing since 2003, and in the 2004, the store had the lowest values.
- The store has not had new customers since September of 2004, because the year 2005, which is present in the data as well, did not show up
  
## Plan Customer:
- Melbourne, New York, California, Nantes, and Madrid are 5 cities which have the most engaged customers.
- Most of the least engaged customers seem to be from Europe - investigate further whether the store company should spend more money on existing customers or acquiring new customers.

# Recommendations
- It is recommended to spend money on acquiring new customers, because the store didn't have new customer since September of 2004.
- More advertisements and promotions in the top 5 cities would be recommended as well.
- Based on Customer Lifetime Value, if we want get 10 new customers next month, an average customer generates 390,395 dollars - based on this, the marketing and finance team can investigate further how much we should spend on acquiring new customers.
