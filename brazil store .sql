-- Customer Behavior Analysis
-- 1) Identify the top 5 cities with the highest number of unique customers.

select customer_city,count(customer_city) as no_of_cust_in_a_city from customers
group by 1
order by 2 desc
limit 5;

-- 2) Calculate the average number of orders per customer in each city.

select  customers.customer_city,avg(a.count) as average_no_of_orders from customers 

join ( select count(orders.order_id) as count,orders.customer_id from orders
join customers on 
customers.customer_id=orders.customer_id
group by 2) as a  on
customers.customer_id=a.customer_id 
group by 1
order by 2 desc;

-- Order Analysis
-- 1) Determine the percentage of orders delivered on time (i.e., delivered on or before the estimated delivery date).

with cte as (
select order_status from orders
where order_status="delivered"  and order_delivered_customer_date < order_estimated_delivery_date)
select((select count(*) from cte)*100/
(select count(order_status) from orders)) as percentage_orders_delivered_on_time;

-- 2) Identify the month with the highest sales and provide the total sales amount for that month in each year.

with   monthly_sales as (
 select year(orders.order_purchase_timestamp) as `year`,date_format(orders.order_purchase_timestamp, '%Y-%m') as sales_month,
 sum(orderitems.price) as totalsales from orders
 join  orderitems on
 orderitems.order_id=orders.order_id
 group by 1,2
 ) ,
 ranked as (
 select year,sales_month,totalsales ,
 row_number() over (partition by `year` order by totalsales desc) as rn
 from monthly_sales)
 select year,sales_month,totalsales from ranked
where rn=1;

--  Payment Analysis

-- 1) Find the most popular payment method and calculate its total sales value.
 
 select payment_type ,sum(payment_value) as total_sales from order_payments
 group by 1
 order by total_sales desc;
 
 -- 2) Analyze the relationship between payment type and the number of payment installments.
 
 select payment_type,sum(payment_installments) as total_installments from order_payments
 group by 1
 order by total_installments desc;
 
 -- Product Analysis
 
 -- 1)List the top 10 most sold products by quantity.
 
 select p.product_category_name_english ,temp.quantity from (
 select products.product_category_name, count(orderitems.product_id) as quantity from products
 join orderitems on
 orderitems.product_id=products.product_id
 group by 1
 order by quantity desc)temp 
 join product_category_name_translation p on
 p.product_category_name=temp.product_category_name
 limit 10;
 
 -- 2) Calculate the average product price in each product category.
 
 select p.product_category_name_english,temp.average_price from
 (Select products.product_category_name,avg(orderitems.price) as average_price from products
 join orderitems on
 orderitems.product_id=products.product_id
 group by 1)temp 
 join product_category_name_translation p on
 p.product_category_name=temp.product_category_name;
 
 
--  Seller Analysis

-- 1) Identify the top 5 sellers based on total sales value.

select sellers.seller_id,sum(orderitems.price) as total_sales from sellers
join orderitems on
orderitems.seller_id=sellers.seller_id
group by 1
order by total_sales desc
limit 5;

-- 2) Determine the average rating for each seller based on the reviews of the products they sold.

select temp.seller_id,avg(reviews.review_score) as average_rating from( select orderitems.seller_id,orders.order_id from orderitems
join orders on
orders.order_id=orderitems.order_id)temp
join reviews on
temp.order_id=reviews.order_id
group by 1;

-- Geographical anlalysis

-- 1) Map the distribution of orders across different geolocation states.

select customers.customer_state , count(orders.order_id) as num_of_orders from customers
join orders on
orders.customer_id=customers.customer_id
group by 1
order by 2 desc;

-- 2) Calculate the average delivery time for each state.

select customers.customer_state , 
avg( (date(orders.order_delivered_customer_date) - date(orders.order_purchase_timestamp))) as avg_delivery_time
 from customers
join orders on
orders.customer_id=customers.customer_id
group by 1;

-- Review Analysis

-- 1)Identify the Category of products with the highest number of reviews and calculate their average review score.

with cte as (
select reviews.review_id ,reviews.review_score ,orders.order_id from reviews
join orders on reviews.order_id=orders.order_id 
)
select products.product_category_name,count(bs.review_id) as num_of_reviews,avg(bs.review_score) as avg_review_score from products
join (select cte.review_id,cte.review_score,orderitems.product_id from cte
join orderitems on orderitems.order_id=cte.order_id) as bs on 
bs.product_id= products.product_id
group by 1
order by 2 desc;

-- Sales Analysis

-- 1) Compare the total sales for each product category.

select  round(sum(o.payment_value)) as total_sales,p.product_category_name from 
(select products.product_id,products.product_category_name ,orders.order_id from products
join orderitems on  products.product_id=orderitems.product_id
join orders on orders.order_id=orderitems.order_id)p
join order_payments o on o.order_id=p.order_id
group by 2
order by 1 desc;

