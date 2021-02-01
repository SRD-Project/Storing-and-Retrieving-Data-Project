use project;




select * from location;
select * from client;
select * from product;
select * from purchase;
select * from item_purchase;
select * from costs;
select * from stock;

/* LITERAL G */

/* 1 */
select c.client_name, pur.date_purchase, p.product_name
from client c
join purchase pur on pur.client_id = c.client_id
join item_purchase ip on ip.purchase_id = pur.purchase_id
join product p on p.product_id = ip.product_id
where pur.date_purchase between '2019-07-15' and '2020-12-31';



/* 2 */
/* best customers: the ones who spent the most*/

select c.client_name, sum(p.product_price*(1-ip.discount) * ip.number_items) as Total_Spent
from client c
join purchase pur on pur.client_id = c.client_id
join item_purchase ip on ip.purchase_id = pur.purchase_id
join product p on p.product_id = ip.product_id
group by c.client_id
order by Total_Spent desc
Limit 3;

/* 3 */
select concat(min(pur.date_purchase),' to ',max(pur.date_purchase)) as Sales_Period,
round(sum(ip.number_items * p.product_price*(1-ip.discount)),2) as TotalSales, 
round(sum(ip.number_items * p.product_price*(1-ip.discount)) / count(distinct year(pur.date_purchase)),2) as YearlyAverage,
round(sum(ip.number_items * p.product_price*(1-ip.discount))/timestampdiff(month, min(pur.date_purchase), max(pur.date_purchase)),2) as MonthlyAverage
from purchase pur
join item_purchase ip on ip.purchase_id = pur.purchase_id
join product p on p.product_id = ip.product_id;

/* 4 */
select l.city, round(sum(p.product_price*(1-ip.discount) * ip.number_items),2) as SpentByCity
from location l
join client c on c.location_id = l.location_id
join purchase pur on pur.client_id = c.client_id
join item_purchase ip on ip.purchase_id = pur.purchase_id
join product p on p.product_id = ip.product_id
group by l.city
order by SpentByCity desc;

/* 5 */
select l.city
from location l
join client c on c.location_id = l.location_id
join purchase pur on pur.client_id = c.client_id
join item_purchase ip on ip.purchase_id = pur.purchase_id
join product p on p.product_id = ip.product_id
where p.product_rating is not null
group by l.city;

/* Selecting cities where products with product ratings above 4 were bought */
select l.city
from location l
join client c on c.location_id = l.location_id
join purchase pur on pur.client_id = c.client_id
join item_purchase ip on ip.purchase_id = pur.purchase_id
join product p on p.product_id = ip.product_id
where p.product_rating>4.5
group by l.city;

/* Literal H */
/*View of the information on the INVOICE ( head and totals)*/
CREATE VIEW invoice_head_totals as
select purchase.invoice_number,
purchase.date_purchase as date_of_issue,
client.client_name,
location.street_address,
location.zip_code,
location.city,
sum(item_purchase.number_items * product.product_price) as subtotal,
sum(round(item_purchase.discount * item_purchase.number_items * product.product_price,2)) as discount,
'2.5' as Shipment_Cost,
/* Tax is included on each product's price - this line is just to inform the client how much he/she's paying in tax*/
round((sum(item_purchase.number_items * product.product_price)-sum(round(item_purchase.discount * item_purchase.number_items * product.product_price + 2.5 ,2)))*0.23,2) as tax,
sum(round(item_purchase.number_items * product.product_price - item_purchase.discount * item_purchase.number_items * product.product_price + 2.5 ,2)) as total
from client
join location on location.location_id=client.location_id
join purchase on purchase.client_id=client.client_id
join item_purchase on item_purchase.purchase_id=purchase.purchase_id
join product on product.product_id=item_purchase.product_id
group by purchase.invoice_number;

select * from invoice_head_totals;


/*View of the details of the invoice*/
CREATE VIEW invoice_details as
select purchase.invoice_number,
product.product_id,
concat(product.product_name, ' - ',product.product_description) as Product_description,
product.product_price as unit_cost,
item_purchase.number_items as quantity,
item_purchase.discount as discount,
round(product.product_price*item_purchase.number_items*(1-item_purchase.discount),2) as product_subtotal
from purchase
join item_purchase on item_purchase.purchase_id=purchase.purchase_id
join product on product.product_id=item_purchase.product_id
;

select * from invoice_details;

/* selection of the details of a specific invoice */
select * from invoice_details where invoice_details.invoice_number=202011;