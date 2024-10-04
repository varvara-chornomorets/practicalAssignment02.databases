-- for each customer top product? (what if there are more than 1)
-- for each product top client? (what if there are more than 1????)
-- for each pair client-product cnt of orders and then top-10 pairs (or more if equal)

with client_product_cnt as (
    select c.id as client_id, c.name as client_name, p.product_id as product_id,
           p.product_name as product_name, p.description as product_desc, count(o.order_id) as cnt
    from opt_clients c
    left join opt_orders o on o.client_id = c.id
    inner join opt_products p on o.product_id = p.product_id
    group by c.id, p.product_id
    order by cnt desc
),
ranked_products as (
    select client_id, client_name, product_id, cnt,
       rank() over (partition by client_id order by cnt desc) as product_rank
    from client_product_cnt
    order by client_id,cnt desc
)

select client_id, client_name, product_id, cnt
from ranked_products
where product_rank = 1
;


