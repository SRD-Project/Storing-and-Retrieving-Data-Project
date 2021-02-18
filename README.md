# Storing-and-Retrieving-Data-Project

## Fictitious online shop description:
  Maria Maria is an online shop that sells handmade clothes and accessories. Inspired by a family tradition of crochet, its business model also embraces sustainability as a main goal, using eco-friendly materials and reusing leftovers from clothing pieces that would otherwise be sent away. The product naming concept is simple: each product name starts with “Maria”, honoring one of the most common Portuguese first names, and is completed by a second name (for instance, “Maria do Carmo” or “Maria Teresa”).
  
## Operating Assumptions:
 - Each client needs to have an account in order to purchase any products. The client’s account has his/her personal details, such as address, phone number, e-mail or NIF(Portuguese tax number);
 
 - Each order can contain multiple products but must be paid all at once (consequently, only one invoice is issued per order). The delivery of each order is always made to the client’s address and only Portuguese addresses are accepted. The shipment cost is always the same regardless of the location;
 
 - The same models with different sizes are considered different products. For instance, the model “Maria João” of size S is considered different from the model “Maria João” of size L – both have different product ID’s and product names (‘Maria João – S’ and‘Maria João – L’). The same applies to models with different colours. Same models with different sizes may have different prices (since products are handmade and the difference in labour is significant from size to size). However, the price does not depend on the colour of the model;
 
 - Discounts may be applied to specific products and may either come from sales promotions or from clients’ discount coupons;
  - The payment method is chosen by the client.

## Entity Relationship Diagram:
![Captura de ecrã 2021-02-18 204913](https://user-images.githubusercontent.com/72451435/108420201-647ce900-722b-11eb-965a-c87bf25b9d66.png)
