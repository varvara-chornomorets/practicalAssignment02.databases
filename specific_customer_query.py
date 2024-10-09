import mysql.connector
import uuid
from faker import Faker
from dotenv import load_dotenv
import random
from datetime import datetime, timedelta
import os

# Load environment variables
load_dotenv()

# Connection settings
HOST = os.getenv('host')
USER = os.getenv('user')
PASSWORD = os.getenv('password')
DATABASE = os.getenv('database')


# Connect to the MySQL database
connection = mysql.connector.connect(
    host=HOST,
    user=USER,
    password=PASSWORD,
    database=DATABASE,
    use_pure=True
)

cursor = connection.cursor()
fake = Faker()

specific_client_id = 54
# top products for specific customer
my_specific_customer_query = '''specific_client_id = 54;
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
),
top_entries as
(
select client_id, client_name, product_id, cnt
from ranked_products
where product_rank = 1
)
select client_id, client_name, product_id cnt
from top_entries
where client_id =%s
;'''

cursor.execute(my_specific_customer_query(specific_client_id))
results = cursor.fetchall()
for row in results:
    print(row)

# Close the cursor and connection
cursor.close()
connection.close()