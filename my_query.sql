-- for each customer top product? (what if there are more than 1)
-- for each product top client? (what if there are more than 1????)
-- for each pair client-product cnt of orders and then top-10 pairs (or more if equal)

with client_product_cnt as (
    select c.id as client_id, c.name as client_name, p.product_id as product_id,
           p.product_name as product_name, p.description as product_desc, count(o.order_id) as cnt
    from opt_clients c
    inner join opt_orders o on o.client_id = c.id
    inner join opt_products p on o.product_id = p.product_id
    group by c.id, p.product_id
    order by cnt
)
select concat(product_name, client_name) from client_product_cnt cpc limit 10 ;



(select concat(product_name, ": ", cnt) from cnt_products where cnt = (select min(cnt) as min_cnt from cnt_products) limit 1) as min_cnt,
(select concat(product_name, ": ", cnt) from cnt_products where cnt = (select max(cnt) as max_cnt from cnt_products) limit 1) as max_cnt