-- for each customer [that bought more than 10 times] their top product (s)

-- table with all products that are top for some customer, grouped by customer

create index idx_orders_client_id on opt_orders(order_date);
drop index idx_orders_client_id on opt_orders;

with ranked_products as (
    select c.id as client_id,
           c.name as client_name,
           p.product_id as product_id,
           p.product_name as product_name,
           count(o.order_id) as cnt,
           rank() over (partition by c.id order by count(o.order_id) desc) as product_rank
    from opt_clients c
    left join opt_orders o on o.client_id = c.id
    inner join opt_products p on o.product_id = p.product_id
    where o.order_date > '2024-01-01'
    group by c.id, p.product_id
    order by client_id, cnt
)
select client_id, client_name, product_id, product_name, cnt
from ranked_products
where product_rank = 1;


-- unoptimised query
-- 4m 49s
select client_id, client_name, product_id, product_name, cnt
from (
    select c.id as client_id,
           c.name as client_name,
           p.product_id as product_id,
           p.product_name as product_name,
           count(o.order_id) as cnt,
           rank() over (partition by c.id order by count(o.order_id) desc) as product_rank
    from opt_clients c
    left join opt_orders o on o.client_id = c.id
    inner join opt_products p on o.product_id = p.product_id
    where o.order_date > '2024-01-01'
    group by c.id, p.product_id
    order by c.id, cnt desc
) as ranked_products
where product_rank = 1
and (select count(o2.order_id)
     from opt_orders o2
     where o2.client_id = ranked_products.client_id) > 3;


drop table opt_orders;
drop table opt_products;
drop table opt_clients;




