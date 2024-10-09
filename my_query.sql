-- for customers-product where this is top product for this client AND
-- either
-- 1) cnt is not lower than 3 from max cnt of the whole table
-- 2) cnt is min of the whole table (yet no zeros)
-- and year is 2024

-- unoptimized query
select
    q.client_id,
    q.client_name,
    q.product_id,
    q.product_name,
    q.cnt
from (
    select
        c.id as client_id,
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
) q
where
    q.product_rank = 1
    and (q.cnt >= (select max(q2.cnt) - 3
                    from (
                        select c2.id as client_id, count(o2.order_id) as cnt
                        from opt_clients c2
                        left join opt_orders o2 on o2.client_id = c2.id
                        inner join opt_products p2 on o2.product_id = p2.product_id
                        where o2.order_date > '2024-01-01'
                        group by c2.id, p2.product_id
                    ) q2)
         or q.cnt = (select min(q2.cnt)
                      from (
                          select c2.id as client_id, count(o2.order_id) as cnt
                          from opt_clients c2
                          left join opt_orders o2 on o2.client_id = c2.id
                          inner join opt_products p2 on o2.product_id = p2.product_id
                          where o2.order_date > '2024-01-01'
                          group by c2.id, p2.product_id
                      ) q2))
order by
    q.cnt desc, client_id;



create index idx_order_date on opt_orders(order_date);
-- optimized query
with ranked_products as (
    select
        c.id as client_id,
        c.name as client_name,
        p.product_id as product_id,
        p.product_name as product_name,
        count(o.order_id) as cnt,
        rank() over (partition by c.id order by count(o.order_id) desc) as product_rank
    from
        opt_clients c
    left join
        opt_orders o on o.client_id = c.id
    inner join
        opt_products p on o.product_id = p.product_id
    where
        o.order_date > '2024-01-01'
    group by
        c.id, p.product_id
)
select
    client_id,
    client_name,
    product_id,
    product_name,
    cnt
from
    ranked_products
where
    product_rank = 1
    and (cnt >= (select max(cnt) - 3 from ranked_products)
         or cnt = (select min(cnt) from ranked_products))
order by
    cnt desc, client_id;




drop table opt_orders;
drop table opt_products;
drop table opt_clients;






